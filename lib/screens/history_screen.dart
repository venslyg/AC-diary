import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart' as app;
import '../providers/job_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';
import 'job_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

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
    final uid = context.read<app.AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job History'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or phone...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accent),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: context.read<JobProvider>().getAllJobs(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }

                final allJobs = snapshot.data ?? [];
                
                // Filter jobs based on search query
                final filteredJobs = allJobs.where((job) {
                  return job.customerName.toLowerCase().contains(_searchQuery) ||
                         job.mobileNumber.contains(_searchQuery);
                }).toList();

                if (filteredJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No job history yet' 
                              : 'No jobs found matching "$_searchQuery"',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    final color = _categoryColors[job.category] ?? AppTheme.accent;
                    final icon = _categoryIcons[job.category] ?? Icons.work;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              // Top row: Avatar + Name/Phone + Price/Status
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _makePhoneCall(job.mobileNumber),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.phone_rounded, size: 14, color: AppTheme.accent),
                                              const SizedBox(width: 6),
                                              Text(
                                                job.mobileNumber,
                                                style: const TextStyle(
                                                  color: AppTheme.accent,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'LKR ${job.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: job.isPaid
                                              ? AppTheme.success.withValues(alpha: 0.15)
                                              : AppTheme.danger.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          job.isPaid ? 'Paid' : 'Unpaid',
                                          style: TextStyle(
                                            color: job.isPaid ? AppTheme.success : AppTheme.danger,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(height: 1, color: AppTheme.dividerColor),
                              ),
                              // Bottom row: Date & Category info
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                  const SizedBox(width: 6),
                                  Text(
                                    job.dateKey,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceInput,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      job.category == 'Service' && job.serviceType != 'N/A'
                                          ? '${job.category} (${job.serviceType})'
                                          : job.category,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
