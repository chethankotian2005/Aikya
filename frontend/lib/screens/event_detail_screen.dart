import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_tokens.dart';
import '../models/event_model.dart';

/// Event Detail — banner, countdown, expandable description, dynamic
/// registration form, and sticky "Register" bottom bar with live seat count.
class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _descExpanded = false;
  bool _isRegistered = false;
  bool _isSubmitting = false;

  // Form state
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formValues = {};
  final Map<String, TextEditingController> _controllers = {};

  // Countdown
  late Timer _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  EventModel get event => widget.event;

  @override
  void initState() {
    super.initState();
    _isRegistered = event.isRegistered;

    // Initialize controllers for each field
    for (final field in event.registrationFields) {
      _controllers[field.label] = TextEditingController();
    }

    // Countdown
    _updateCountdown();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final now = DateTime.now();
    if (event.dateTime.isAfter(now)) {
      setState(() => _timeRemaining = event.dateTime.difference(now));
    } else {
      setState(() => _timeRemaining = Duration.zero);
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Collapsible banner ────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: _backButton(),
                actions: [_shareButton()],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(event.bannerAsset, fit: BoxFit.cover),
                      // Bottom gradient
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
                      // Bottom text overlay
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: event.tagBg,
                                borderRadius: AppRadius.borderRadiusXs,
                              ),
                              child: Text(
                                event.tag.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: event.tagColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Body ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Countdown timer
                    if (!event.isPast) _buildCountdown(),
                    if (!event.isPast) const SizedBox(height: AppSpacing.base),

                    // Info pills
                    _buildInfoSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // Seat progress
                    _buildSeatSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildDescription(),
                    const SizedBox(height: AppSpacing.lg),

                    // Registration form
                    if (!event.isPast &&
                        !_isRegistered &&
                        event.registrationFields.isNotEmpty) ...[
                      _buildFormSection(),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (_isRegistered) _buildRegisteredBanner(),
                  ]),
                ),
              ),
            ],
          ),

          // ─── Sticky bottom bar ─────────────────────────────────────
          if (!event.isPast) _buildBottomBar(),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // APP BAR BUTTONS
  // ═════════════════════════════════════════════════════════════════

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.6),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _shareButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.6),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child:
            const Icon(Icons.share_outlined, color: Colors.white, size: 20),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // COUNTDOWN
  // ═════════════════════════════════════════════════════════════════

  Widget _buildCountdown() {
    if (_timeRemaining == Duration.zero) return const SizedBox.shrink();

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final mins = _timeRemaining.inMinutes % 60;
    final secs = _timeRemaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.aiBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Starts in',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          _countdownUnit(days.toString(), 'D'),
          _countdownSep(),
          _countdownUnit(hours.toString().padLeft(2, '0'), 'H'),
          _countdownSep(),
          _countdownUnit(mins.toString().padLeft(2, '0'), 'M'),
          _countdownSep(),
          _countdownUnit(secs.toString().padLeft(2, '0'), 'S'),
        ],
      ),
    );
  }

  Widget _countdownUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _countdownSep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // INFO SECTION
  // ═════════════════════════════════════════════════════════════════

  Widget _buildInfoSection() {
    final endStr = event.endTime != null ? _formatTime(event.endTime!) : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _detailRow(Icons.calendar_today_outlined, 'Date',
              _formatFullDate(event.dateTime)),
          const Divider(height: 20, color: AppColors.border),
          _detailRow(Icons.access_time_rounded, 'Time',
              '${_formatTime(event.dateTime)}${endStr != null ? ' – $endStr' : ''}'),
          const Divider(height: 20, color: AppColors.border),
          _detailRow(Icons.location_on_outlined, 'Venue', event.venue),
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
          decoration: BoxDecoration(
            color: AppColors.accentMuted,
            borderRadius: AppRadius.borderRadiusXs,
          ),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
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

  // ═════════════════════════════════════════════════════════════════
  // SEATS
  // ═════════════════════════════════════════════════════════════════

  Widget _buildSeatSection() {
    final ratio = event.fillRatio.clamp(0.0, 1.0);
    final isNear = event.isNearCapacity;
    final isFull = event.isFull;
    final barColor =
        isFull ? AppColors.error : (isNear ? AppColors.warning : AppColors.accent);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event_seat_outlined, size: 16, color: barColor),
                  const SizedBox(width: 6),
                  Text(
                    'Seat Availability',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  isFull
                      ? 'FULL'
                      : isNear
                          ? 'FILLING FAST'
                          : 'AVAILABLE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Large numbers
          Row(
            children: [
              Text(
                '${event.filledSeats}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                ' / ${event.totalSeats}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'seats filled',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: barColor.withValues(alpha: 0.1),
              color: barColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFull
                ? 'Waitlist may open soon'
                : '${event.seatsRemaining} seats remaining',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // DESCRIPTION
  // ═════════════════════════════════════════════════════════════════

  Widget _buildDescription() {
    final isLong = event.description.length > 200;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this Event',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: Text(
              event.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            secondChild: Text(
              event.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            crossFadeState: _descExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _descExpanded ? 'Show less' : 'Read more',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _descExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // REGISTRATION FORM
  // ═════════════════════════════════════════════════════════════════

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Registration Form',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details below to register',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            ...event.registrationFields.map(_buildField),
          ],
        ),
      ),
    );
  }

  Widget _buildField(RegistrationField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (field.isRequired)
                Text(' *',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 6),
          if (field.type == FieldType.dropdown)
            _buildDropdown(field)
          else
            _buildTextField(field),
        ],
      ),
    );
  }

  Widget _buildTextField(RegistrationField field) {
    final controller = _controllers[field.label]!;
    return TextFormField(
      controller: controller,
      maxLines: field.type == FieldType.multiline ? 3 : 1,
      keyboardType: switch (field.type) {
        FieldType.email => TextInputType.emailAddress,
        FieldType.phone => TextInputType.phone,
        FieldType.multiline => TextInputType.multiline,
        _ => TextInputType.text,
      },
      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: field.hint,
        hintStyle:
            GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.primaryContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      validator: field.isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      onSaved: (v) => _formValues[field.label] = v ?? '',
    );
  }

  Widget _buildDropdown(RegistrationField field) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: field.hint,
        hintStyle:
            GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.primaryContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
      dropdownColor: AppColors.surfaceElevated,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textTertiary),
      items: field.options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => _formValues[field.label] = v ?? '',
      validator: field.isRequired
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // REGISTERED BANNER
  // ═════════════════════════════════════════════════════════════════

  Widget _buildRegisteredBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re registered!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'Check your email for confirmation details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // STICKY BOTTOM BAR
  // ═════════════════════════════════════════════════════════════════

  Widget _buildBottomBar() {
    final isFull = event.isFull && !_isRegistered;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Seat counter
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFull ? 'No seats' : '${event.seatsRemaining} seats left',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFull
                              ? AppColors.error
                              : event.isNearCapacity
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFull
                            ? 'Waitlist available'
                            : 'Live · updates in real-time',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // CTA
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: _isRegistered
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Registered'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                          disabledForegroundColor: AppColors.success,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: isFull
                            ? null
                            : _isSubmitting
                                ? null
                                : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.textTertiary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                isFull ? 'Join Waitlist' : 'Register Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (event.registrationFields.isNotEmpty) {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isRegistered = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Successfully registered!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusSm),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        ),
      );
    }
  }

  // ─── Formatters ───────────────────────────────────────────────────

  String _formatFullDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min $amPm';
  }
}
