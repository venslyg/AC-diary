import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../providers/job_provider.dart';
import '../theme/app_theme.dart';
import 'job_entry_screen.dart';

/// Shows a list of today's jobs filtered by a specific category.
class CategoryJobsScreen extends StatelessWidget {
  final String category;
  const CategoryJobsScreen({super.key, required this.category});

  static const _categoryIcons = {
    'Repair': Icons.build_rounded,
    'Service': Icons.home_repair_service_rounded,
    'Maintenance': Icons.engineering_rounded,
    'Installation': Icons.install_desktop_rounded,
  };

  static const _categoryColors = {
    'Repair': AppTheme.accent,
    'Service': AppTheme.success,
    'Maintenance': AppTheme.warning,
    'Installation': AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final jobProv = context.watch<JobProvider>();
    final uid = context.read<app.AuthProvider>().user?.uid;
    final jobs = jobProv.getJobsByCategory(category);
    final color = _categoryColors[category] ?? AppTheme.accent;
    final icon = _categoryIcons[category] ?? Icons.work;

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Jobs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64,
                      color: color.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'No $category jobs today',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Dismissible(
                  key: Key(job.id ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        color: AppTheme.danger, size: 28),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surfaceCard,
                        title: const Text('Delete Job'),
                        content: Text(
                            'Delete job for "${job.customerName}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete',
                                style: TextStyle(color: AppTheme.danger)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    if (uid != null && job.id != null) {
                      jobProv.deleteJob(uid, job.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Job deleted'),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobEntryScreen(editJob: job),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      color.withValues(alpha: 0.15),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        job.mobileNumber,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price + status
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'LKR ${job.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: job.isPaid
                                            ? AppTheme.success
                                                .withValues(alpha: 0.15)
                                            : AppTheme.danger
                                                .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        job.isPaid ? 'Paid' : 'Unpaid',
                                        style: TextStyle(
                                          color: job.isPaid
                                              ? AppTheme.success
                                              : AppTheme.danger,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Description
                            if (job.description.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                job.description,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            // Service type badge
                            if (job.category == 'Service' &&
                                job.serviceType != 'N/A') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${job.serviceType} Service',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            // Edit hint
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tap to edit',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  'Swipe left to delete',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
