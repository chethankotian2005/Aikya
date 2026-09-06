import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

class AdminAnalyticsView extends StatefulWidget {
  const AdminAnalyticsView({super.key});

  @override
  State<AdminAnalyticsView> createState() => _AdminAnalyticsViewState();
}

class _AdminAnalyticsViewState extends State<AdminAnalyticsView> {
  // Mock data for sentiments
  final List<Map<String, dynamic>> _sentiments = [
    {
      'event': 'Introduction to GenAI & RAG',
      'positive': 82,
      'neutral': 12,
      'negative': 6,
      'isExpanded': false,
      'comments': [
        {'text': 'Absolutely loved building the RAG pipeline!', 'type': 'pos'},
        {'text': 'Good content but the pacing was a bit fast.', 'type': 'neu'},
        {'text': 'Couldn\'t connect to the local server.', 'type': 'neg'},
      ],
    },
    {
      'event': 'Alumni Talk: Career Paths in ML',
      'positive': 90,
      'neutral': 8,
      'negative': 2,
      'isExpanded': false,
      'comments': [
        {'text': 'Very inspiring talk by Priya.', 'type': 'pos'},
        {'text': 'Helped clarify my doubts about MLOps.', 'type': 'pos'},
      ],
    },
    {
      'event': 'Neural Hack 2026',
      'positive': 65,
      'neutral': 20,
      'negative': 15,
      'isExpanded': false,
      'comments': [
        {'text': 'Great energy and mentoring!', 'type': 'pos'},
        {'text': 'Food arrangements could be better next time.', 'type': 'neg'},
        {'text': 'Wi-Fi kept dropping during the final hours.', 'type': 'neg'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildKPIs(),
          const SizedBox(height: 48),
          _buildTurnoutChart(),
          const SizedBox(height: 48),
          _buildFeedbackSentiment(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'HOD Dashboard — Even Semester 2026',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ─── KPIs ─────────────────────────────────────────────────────────
  Widget _buildKPIs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple responsiveness
        int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _kpiCard('Total Events', '14', true, '↑ 2 from last sem'),
            _kpiCard('Active Students', '312', true, '↑ 12% engagement'),
            _kpiCard('Alumni Mentors', '42', true, '↑ 5 joined this week'),
            _kpiCard('Pending Approvals', '18', false, 'Requires attention'),
          ],
        );
      },
    );
  }

  Widget _kpiCard(String title, String value, bool isPositiveTrend, String trendText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1),
              ),
              const SizedBox(width: 8),
              if (trendText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      if (isPositiveTrend) const Icon(Icons.arrow_upward_rounded, size: 12, color: AppColors.success)
                      else if (title != 'Pending Approvals') const Icon(Icons.arrow_downward_rounded, size: 12, color: AppColors.error),
                      const SizedBox(width: 2),
                      Text(
                        trendText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositiveTrend ? AppColors.success : (title == 'Pending Approvals' ? AppColors.warning : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Chart ────────────────────────────────────────────────────────
  Widget _buildTurnoutChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Turnout Over Time',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text('Attendance figures for the last 6 major department events.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          // Mock Bar Chart
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bar(0.4, 'Mar 10', '120'),
                _bar(0.6, 'Apr 02', '180'),
                _bar(0.3, 'May 15', '90'),
                _bar(0.7, 'Jul 05', '210'),
                _bar(0.8, 'Aug 10', '240'),
                _bar(0.5, 'Sep 15', '150'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double heightFactor, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
          width: 40,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.accent.withValues(alpha: 0.5),
                AppColors.accent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ─── Feedback Sentiment ───────────────────────────────────────────
  Widget _buildFeedbackSentiment() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback Sentiment Analysis',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text('Auto-analyzed from post-event student surveys.', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    gradient: AppColors.aiBadgeGradient,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('AI-ANALYZED', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: _sentiments.map((s) => _buildSentimentRow(s)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentRow(Map<String, dynamic> data) {
    final bool isExpanded = data['isExpanded'];
    final int pos = data['positive'];
    final int neu = data['neutral'];
    final int neg = data['negative'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                data['isExpanded'] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      data['event'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: pos, child: Container(height: 8, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.horizontal(left: const Radius.circular(4), right: Radius.circular(neu == 0 && neg == 0 ? 4 : 0))))),
                            if (neu > 0) Expanded(flex: neu, child: Container(height: 8, color: AppColors.warning)),
                            if (neg > 0) Expanded(flex: neg, child: Container(height: 8, decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.horizontal(right: const Radius.circular(4), left: Radius.circular(pos == 0 && neu == 0 ? 4 : 0))))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$pos% Pos', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                            if (neu > 0) Text('$neu% Neu', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
                            if (neg > 0) Text('$neg% Neg', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              color: AppColors.primaryContainer,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: (data['comments'] as List).map((c) {
                  IconData icon;
                  Color color;
                  if (c['type'] == 'pos') {
                    icon = Icons.sentiment_very_satisfied_rounded;
                    color = AppColors.success;
                  } else if (c['type'] == 'neg') {
                    icon = Icons.sentiment_very_dissatisfied_rounded;
                    color = AppColors.error;
                  } else {
                    icon = Icons.sentiment_neutral_rounded;
                    color = AppColors.warning;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"${c['text']}"',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
