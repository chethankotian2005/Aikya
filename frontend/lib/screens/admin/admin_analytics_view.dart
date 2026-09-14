import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/firestore/event_doc.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';
import '../events_hub_screen.dart' show formatEventDate;
import 'admin_manage_events_view.dart' show manageableEventsProvider;

/// Analytics + Feedback Sentiment Rollup (HOD: all events, coordinators: own).
class AdminAnalyticsView extends ConsumerStatefulWidget {
  const AdminAnalyticsView({super.key});

  @override
  ConsumerState<AdminAnalyticsView> createState() => _AdminAnalyticsViewState();
}

class _AdminAnalyticsViewState extends ConsumerState<AdminAnalyticsView> {
  final Set<String> _running = {};

  Future<void> _runRollup(EventDoc event) async {
    setState(() => _running.add(event.id));
    try {
      final result = await ref.read(renderApiServiceProvider).sentimentRollup(eventId: event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Analysed ${result['totalComments']} comments for "${event.title}".'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _running.remove(event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(manageableEventsProvider);

    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(icon: Icons.insights_outlined, message: 'No events to analyse yet.');
        }

        final registrations = list.fold<int>(0, (sum, e) => sum + e.filledSeats);
        final capacity = list.fold<int>(0, (sum, e) => sum + e.totalSeats);
        final analysed = list.where((e) => e.sentimentPercentages != null).toList();
        final avgPositive = analysed.isEmpty
            ? null
            : (analysed.fold<int>(0, (s, e) => s + (e.sentimentPercentages!['positive'] ?? 0)) / analysed.length).round();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Analytics & insights', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _summary('Events', '${list.length}'),
                _summary('Registrations', '$registrations'),
                _summary('Fill rate', capacity == 0 ? '–' : '${(registrations * 100 / capacity).round()}%'),
                _summary('Avg. positive', avgPositive == null ? '–' : '$avgPositive%', ai: true),
              ],
            ),
            const SizedBox(height: 24),
            for (final e in list) _eventCard(e),
          ],
        );
      },
    );
  }

  Widget _summary(String label, String value, {bool ai = false}) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary))),
                  if (ai) ...[const SizedBox(width: 4), const AiBadge()],
                ],
              ),
              Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard(EventDoc event) {
    final sentiment = event.sentimentPercentages;
    final running = _running.contains(event.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push('/events/${event.id}'),
              child: Text(event.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            Text(
              '${formatEventDate(event.eventDate)} · ${event.filledSeats}/${event.totalSeats} registered',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (sentiment != null) ...[
              Row(children: [
                Text('Feedback sentiment', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                const AiBadge(),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusFull,
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      for (final (key, color) in [
                        ('positive', AppColors.success),
                        ('neutral', AppColors.warning),
                        ('negative', AppColors.error),
                      ])
                        if ((sentiment[key] ?? 0) > 0)
                          Expanded(flex: sentiment[key]!, child: Container(color: color)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${sentiment['positive'] ?? 0}% positive · ${sentiment['neutral'] ?? 0}% neutral · ${sentiment['negative'] ?? 0}% negative',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: running ? null : () => _runRollup(event),
                icon: running
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded, size: 16),
                label: Text(sentiment == null ? 'Run sentiment rollup' : 'Refresh sentiment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
