import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../providers/job_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.surfaceCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
    }
  }

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = context.read<app.AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _pickMonth,
              borderRadius: BorderRadius.circular(12),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: AppTheme.accent),
                          const SizedBox(width: 12),
                          Text(
                            '${_monthNames[_selectedMonth]} $_selectedYear',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down_rounded,
                          color: AppTheme.accent, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Report body
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: context
                  .read<JobProvider>()
                  .getMonthJobs(uid, _selectedYear, _selectedMonth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 64,
                            color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'No jobs found for this month',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate summaries
                final totalRevenue =
                    jobs.fold(0.0, (sum, j) => sum + j.price);
                final totalPaid =
                    jobs.where((j) => j.isPaid).fold(0.0, (sum, j) => sum + j.price);
                final totalOutstanding = totalRevenue - totalPaid;

                final repairs =
                    jobs.where((j) => j.category == 'Repair').length;
                final services =
                    jobs.where((j) => j.category == 'Service').length;
                final maintenance =
                    jobs.where((j) => j.category == 'Maintenance').length;
                final installations =
                    jobs.where((j) => j.category == 'Installation').length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      _ReportSummaryCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Total Revenue',
                        value: 'LKR ${totalRevenue.toStringAsFixed(0)}',
                        color: AppTheme.accent,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ReportSummaryCard(
                              icon: Icons.check_circle_rounded,
                              label: 'Total Paid',
                              value:
                                  'LKR ${totalPaid.toStringAsFixed(0)}',
                              color: AppTheme.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ReportSummaryCard(
                              icon: Icons.pending_rounded,
                              label: 'Outstanding',
                              value:
                                  'LKR ${totalOutstanding.toStringAsFixed(0)}',
                              color: AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Category breakdown
                      const Text(
                        'CATEGORY BREAKDOWN',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              _CategoryRow(
                                icon: Icons.build_rounded,
                                label: 'Repairs',
                                count: repairs,
                                total: jobs.length,
                                color: AppTheme.accent,
                              ),
                              const Divider(
                                  height: 1,
                                  color: AppTheme.dividerColor),
                              _CategoryRow(
                                icon: Icons.home_repair_service_rounded,
                                label: 'Services',
                                count: services,
                                total: jobs.length,
                                color: AppTheme.success,
                              ),
                              const Divider(
                                  height: 1,
                                  color: AppTheme.dividerColor),
                              _CategoryRow(
                                icon: Icons.engineering_rounded,
                                label: 'Maintenance',
                                count: maintenance,
                                total: jobs.length,
                                color: AppTheme.warning,
                              ),
                              const Divider(
                                  height: 1,
                                  color: AppTheme.dividerColor),
                              _CategoryRow(
                                icon: Icons.install_desktop_rounded,
                                label: 'Installations',
                                count: installations,
                                total: jobs.length,
                                color: AppTheme.danger,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total jobs
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Total Jobs: ${jobs.length}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ReportSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final Color color;

  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${pct.toStringAsFixed(0)}%',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
