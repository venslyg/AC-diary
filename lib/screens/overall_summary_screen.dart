import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../providers/job_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';

class OverallSummaryScreen extends StatelessWidget {
  const OverallSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<app.AuthProvider>().user?.uid;
    if (uid == null) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Summary'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: context.read<JobProvider>().getAllJobs(uid),
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
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No jobs found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Calculate overall stats
          final totalRevenue = jobs.fold(0.0, (sum, j) => sum + j.price);
          final totalRepairs = jobs.where((j) => j.category == 'Repair').length;
          final totalServices = jobs.where((j) => j.category == 'Service').length;
          final totalMaintenance = jobs.where((j) => j.category == 'Maintenance').length;
          final totalInstallations = jobs.where((j) => j.category == 'Installation').length;
          final totalUniqueCustomers = jobs.map((j) => j.mobileNumber).toSet().length;
          final totalPaid = jobs.where((j) => j.isPaid).fold(0.0, (sum, j) => sum + j.price);
          final totalOutstanding = totalRevenue - totalPaid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Overview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Revenue',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LKR ${totalRevenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${totalPaid.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Outstanding',
                                    style: TextStyle(
                                      color: AppTheme.danger,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${totalOutstanding.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppTheme.danger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "All-Time Stats",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Stat Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _OverallStatCard(
                      icon: Icons.work_rounded,
                      label: 'Total Jobs',
                      count: jobs.length,
                      color: AppTheme.accent,
                    ),
                    _OverallStatCard(
                      icon: Icons.people_alt_rounded,
                      label: 'Unique Customers',
                      count: totalUniqueCustomers,
                      color: AppTheme.accentLight,
                    ),
                    _OverallStatCard(
                      icon: Icons.build_rounded,
                      label: 'Repairs',
                      count: totalRepairs,
                      color: AppTheme.accent,
                    ),
                    _OverallStatCard(
                      icon: Icons.home_repair_service_rounded,
                      label: 'Services',
                      count: totalServices,
                      color: AppTheme.success,
                    ),
                    _OverallStatCard(
                      icon: Icons.engineering_rounded,
                      label: 'Maintenance',
                      count: totalMaintenance,
                      color: AppTheme.warning,
                    ),
                    _OverallStatCard(
                      icon: Icons.install_desktop_rounded,
                      label: 'Installations',
                      count: totalInstallations,
                      color: AppTheme.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _OverallStatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
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
