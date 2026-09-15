import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/event_model.dart';
import '../models/firestore/comment_doc.dart';
import '../models/firestore/event_doc.dart';
import '../services/event_registration_service.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/banner_image.dart';
import '../widgets/shared_widgets.dart';
import 'events_hub_screen.dart' show formatEventDate;

/// Event detail: live seats, registration form, cancel, feedback comments,
/// and (for staff) the AI report and sentiment rollup.
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final _commentController = TextEditingController();
  final _registrations = EventRegistrationService();
  bool _submitting = false;
  bool _postingComment = false;
  bool _descExpanded = false;

  late final Stream<EventDoc?> _eventStream = EventDoc.docRef(widget.eventId)
      .snapshots()
      .map((doc) => doc.exists ? EventDoc.fromFirestore(doc) : null);

  late final Stream<bool> _registeredStream = EventDoc.registrationsRef(widget.eventId)
      .doc(FirebaseAuth.instance.currentUser?.uid ?? '_')
      .snapshots()
      .map((doc) => doc.exists);

  late final Stream<List<CommentDoc>> _commentsStream = EventDoc.commentsRef(widget.eventId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map(CommentDoc.fromFirestore).toList());

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(String label) =>
      _controllers.putIfAbsent(label, TextEditingController.new);

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ));
  }

  Future<void> _register(EventDoc event, String uid) async {
    if (event.formFields.isNotEmpty && !(_formKey.currentState?.validate() ?? false)) return;

    final responses = {
      for (final field in event.formFields)
        field.label: field.type == FieldType.dropdown
            ? (_dropdownValues[field.label] ?? '')
            : _controllerFor(field.label).text.trim(),
    };

    setState(() => _submitting = true);
    try {
      await _registrations.registerForEvent(
        eventId: event.id,
        studentUid: uid,
        formResponses: responses,
      );
      _snack("You're registered!");
    } catch (e) {
      _snack(friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _cancelRegistration(EventDoc event, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel registration?'),
        content: Text('Your seat for "${event.title}" will be released.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep seat')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel registration'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _registrations.cancelRegistration(eventId: event.id, studentUid: uid);
      _snack('Registration cancelled.');
    } catch (e) {
      _snack(friendlyError(e), error: true);
    }
  }

  Future<void> _postComment(UserDoc user) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (text.length > 1000) {
      _snack('Comments are limited to 1000 characters.', error: true);
      return;
    }

    setState(() => _postingComment = true);
    try {
      await EventDoc.commentsRef(widget.eventId).add(CommentDoc.newComment(
        userId: user.uid,
        userName: user.fullName,
        commentText: text,
      ));
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      _snack(friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _deleteComment(CommentDoc comment) async {
    try {
      await EventDoc.commentsRef(widget.eventId).doc(comment.id).delete();
    } catch (e) {
      _snack(friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;

    return StreamBuilder<EventDoc?>(
      stream: _eventStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _messageScaffold(friendlyError(snapshot.error!));
        }
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final event = snapshot.data;
        if (event == null) return _messageScaffold('This event no longer exists.');

        final canManage = user != null &&
            (user.role == UserRole.hod ||
                (user.role == UserRole.coordinator && event.createdBy == user.uid));
        final isStudent = user?.role == UserRole.student;

        return StreamBuilder<bool>(
          stream: _registeredStream,
          builder: (context, regSnapshot) {
            final registered = regSnapshot.data ?? false;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  _buildAppBar(event),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (!event.isPast) ...[
                          _Countdown(target: event.eventDate),
                          const SizedBox(height: AppSpacing.base),
                        ],
                        _buildInfoCard(event),
                        const SizedBox(height: AppSpacing.base),
                        _buildSeatsCard(event),
                        const SizedBox(height: AppSpacing.base),
                        _buildDescription(event),
                        const SizedBox(height: AppSpacing.base),
                        if (isStudent && registered) ...[
                          _buildRegisteredBanner(event, user!.uid),
                          const SizedBox(height: AppSpacing.base),
                        ],
                        if (isStudent && !registered && event.isRegistrationOpen && event.formFields.isNotEmpty) ...[
                          _buildFormCard(event),
                          const SizedBox(height: AppSpacing.base),
                        ],
                        if (user != null && user.role.isStaff) ...[
                          if (event.sentimentPercentages != null) ...[
                            _buildSentimentCard(event.sentimentPercentages!),
                            const SizedBox(height: AppSpacing.base),
                          ],
                          if (event.reportMarkdown != null) ...[
                            _buildReportCard(event.reportMarkdown!),
                            const SizedBox(height: AppSpacing.base),
                          ],
                        ],
                        if (user != null) _buildComments(user, canManage),
                      ]),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: user == null
                  ? null
                  : _buildBottomBar(event, user, registered: registered, canManage: canManage),
            );
          },
        );
      },
    );
  }

  Scaffold _messageScaffold(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: EmptyState(icon: Icons.event_busy_rounded, message: message),
    );
  }

  Widget _buildAppBar(EventDoc event) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            BannerImage(url: event.bannerUrl, fit: BoxFit.contain),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0E1B3D)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(label: event.tag, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard(EventDoc event) {
    return _card(
      child: Column(
        children: [
          _detailRow(Icons.calendar_today_outlined, 'When', formatEventDate(event.eventDate)),
          if (event.endDate != null) ...[
            const Divider(height: 20, color: AppColors.border),
            _detailRow(Icons.flag_outlined, 'Ends', formatEventDate(event.endDate!)),
          ],
          const Divider(height: 20, color: AppColors.border),
          _detailRow(Icons.location_on_outlined, 'Venue', event.venue),
          const Divider(height: 20, color: AppColors.border),
          _detailRow(Icons.event_busy_outlined, 'Registration closes',
              formatEventDate(event.registrationDeadline)),
          if (event.club != null) ...[
            const Divider(height: 20, color: AppColors.border),
            _detailRow(Icons.groups_outlined, 'Organised by', event.club!),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppColors.accentMuted, borderRadius: AppRadius.borderRadiusXs),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary)),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsCard(EventDoc event) {
    final color = event.isFull
        ? AppColors.error
        : event.isNearCapacity
            ? AppColors.warning
            : AppColors.accent;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seat availability',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              TagChip(
                label: event.isFull ? 'Full' : event.isNearCapacity ? 'Filling fast' : 'Available',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${event.filledSeats} / ${event.totalSeats} seats filled',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: LinearProgressIndicator(
              value: event.fillRatio.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(EventDoc event) {
    final isLong = event.description.length > 200;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this event', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            event.description.isEmpty ? 'No description provided.' : event.description,
            maxLines: _descExpanded || !isLong ? null : 4,
            overflow: _descExpanded || !isLong ? null : TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
          if (isLong)
            TextButton(
              onPressed: () => setState(() => _descExpanded = !_descExpanded),
              child: Text(_descExpanded ? 'Show less' : 'Read more'),
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard(EventDoc event) {
    return _card(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registration form', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Fill in the details below, then tap Register.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.base),
            for (final field in event.formFields) ...[
              _buildField(field),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(RegistrationField field) {
    final label = field.isRequired ? '${field.label} *' : field.label;
    String? requiredValidator(String? v) =>
        field.isRequired && (v == null || v.trim().isEmpty) ? 'Required' : null;

    if (field.type == FieldType.dropdown) {
      return DropdownButtonFormField<String>(
        initialValue: _dropdownValues[field.label],
        decoration: InputDecoration(labelText: label, hintText: field.hint),
        items: [for (final o in field.options) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) => _dropdownValues[field.label] = v ?? '',
        validator: requiredValidator,
      );
    }

    return TextFormField(
      controller: _controllerFor(field.label),
      maxLines: field.type == FieldType.multiline ? 3 : 1,
      keyboardType: switch (field.type) {
        FieldType.email => TextInputType.emailAddress,
        FieldType.phone => TextInputType.phone,
        FieldType.multiline => TextInputType.multiline,
        _ => TextInputType.text,
      },
      decoration: InputDecoration(labelText: label, hintText: field.hint),
      validator: (v) {
        final required = requiredValidator(v);
        if (required != null) return required;
        if (field.type == FieldType.email && v != null && v.isNotEmpty &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildRegisteredBanner(EventDoc event, String uid) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              "You're registered for this event.",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.success),
            ),
          ),
          if (!event.isPast)
            TextButton(
              onPressed: () => _cancelRegistration(event, uid),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(Map<String, int> percentages) {
    Widget bar(String label, Color color) {
      final value = percentages[label] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                label[0].toUpperCase() + label.substring(1),
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusFull,
                child: LinearProgressIndicator(
                  value: value / 100,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.12),
                  minHeight: 8,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text('$value%', textAlign: TextAlign.end, style: GoogleFonts.poppins(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Feedback sentiment', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              const AiBadge(),
            ],
          ),
          bar('positive', AppColors.success),
          bar('neutral', AppColors.warning),
          bar('negative', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildReportCard(String markdown) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Event report', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              const AiBadge(),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownBody(data: markdown),
        ],
      ),
    );
  }

  Widget _buildComments(UserDoc user, bool canManage) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feedback & comments', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLength: 1000,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your feedback...',
                    counterText: '',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Post comment',
                onPressed: _postingComment ? null : () => _postComment(user),
                icon: _postingComment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<CommentDoc>>(
            stream: _commentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(friendlyError(snapshot.error!), style: const TextStyle(color: AppColors.error));
              }
              final comments = snapshot.data ?? const [];
              if (comments.isEmpty) {
                return Text(
                  'No comments yet — be the first to share feedback.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textTertiary),
                );
              }
              return Column(
                children: [
                  for (final c in comments)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(color: AppColors.secondary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(
                        c.userName,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.commentText, style: GoogleFonts.poppins(fontSize: 13)),
                          if (c.createdAt != null)
                            Text(
                              timeago.format(c.createdAt!),
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                            ),
                        ],
                      ),
                      trailing: c.userId == user.uid || canManage
                          ? IconButton(
                              tooltip: 'Delete comment',
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textTertiary),
                              onPressed: () => _deleteComment(c),
                            )
                          : null,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(EventDoc event, UserDoc user, {required bool registered, required bool canManage}) {
    Widget action;

    if (user.role == UserRole.student) {
      if (registered) {
        action = OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text('Registered'),
          style: OutlinedButton.styleFrom(disabledForegroundColor: AppColors.success),
        );
      } else if (event.isPast) {
        action = const _BarNote('This event has ended');
      } else if (event.isFull) {
        action = const ElevatedButton(onPressed: null, child: Text('Event full'));
      } else if (!event.isRegistrationOpen) {
        action = const ElevatedButton(onPressed: null, child: Text('Registration closed'));
      } else {
        action = ElevatedButton(
          onPressed: _submitting ? null : () => _register(event, user.uid),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Register now'),
        );
      }
    } else if (canManage && event.isPast) {
      action = ElevatedButton.icon(
        onPressed: () => context.push('/admin/report', extra: event.id),
        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
        label: const Text('Generate report'),
      );
    } else if (canManage) {
      action = const _BarNote('You manage this event');
    } else {
      action = const _BarNote('Faculty view — registration not applicable');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                event.isFull ? 'No seats left' : '${event.seatsRemaining} seats left',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 48, child: action),
          ],
        ),
      ),
    );
  }
}

class _BarNote extends StatelessWidget {
  final String text;
  const _BarNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Live "starts in" countdown; owns its own timer so the page doesn't rebuild every second.
class _Countdown extends StatefulWidget {
  final DateTime target;
  const _Countdown({required this.target});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    Widget unit(int value, String label) => Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(label, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.accent)),
          ],
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: AppRadius.borderRadiusLg),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text('Starts in', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          const Spacer(),
          unit(remaining.inDays, 'D'),
          const SizedBox(width: 12),
          unit(remaining.inHours % 24, 'H'),
          const SizedBox(width: 12),
          unit(remaining.inMinutes % 60, 'M'),
          const SizedBox(width: 12),
          unit(remaining.inSeconds % 60, 'S'),
        ],
      ),
    );
  }
}
