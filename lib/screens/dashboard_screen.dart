import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'category_jobs_screen.dart';
import 'history_screen.dart';
import 'job_entry_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardBody(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const JobEntryScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Job'),
            )
          : null,
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final jobProv = context.watch<JobProvider>();
    final userProv = context.watch<UserProvider>();
    final target = userProv.dailyMarginTarget;
    final revenue = jobProv.todayRevenue;
    final progress = target > 0 ? (revenue / target).clamp(0.0, 1.0) : 0.0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('AC Diary'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    jobProv.currentDateKey,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Sales Progress ───
                  _SalesProgressCard(
                    revenue: revenue,
                    target: target,
                    progress: progress,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Today's Summary",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  // ─── Stat Cards Grid ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        icon: Icons.build_rounded,
                        label: 'Repairs',
                        count: jobProv.totalRepairs,
                        color: AppTheme.accent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryJobsScreen(
                                  category: 'Repair'),
                            ),
                          );
                        },
                      ),
                      _StatCard(
                        icon: Icons.home_repair_service_rounded,
                        label: 'Services',
                        count: jobProv.totalServices,
                        color: AppTheme.success,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryJobsScreen(
                                  category: 'Service'),
                            ),
                          );
                        },
                      ),
                      _StatCard(
                        icon: Icons.engineering_rounded,
                        label: 'Maintenance',
                        count: jobProv.totalMaintenance,
                        color: AppTheme.warning,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryJobsScreen(
                                  category: 'Maintenance'),
                            ),
                          );
                        },
                      ),
                      _StatCard(
                        icon: Icons.install_desktop_rounded,
                        label: 'Installations',
                        count: jobProv.totalInstallations,
                        color: AppTheme.danger,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryJobsScreen(
                                  category: 'Installation'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Unique customers card - full width
                  _StatCard(
                    icon: Icons.people_alt_rounded,
                    label: 'Unique Customers',
                    count: jobProv.totalUniqueCustomers,
                    color: AppTheme.accentLight,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 20),

                  // ─── Recent Jobs ───
                  if (jobProv.todayJobs.isNotEmpty) ...[
                    Text(
                      'Recent Jobs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),

          // Recent jobs list
          if (jobProv.todayJobs.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = jobProv.todayJobs[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _categoryColor(job.category).withValues(alpha: 0.2),
                          child: Icon(
                            _categoryIcon(job.category),
                            color: _categoryColor(job.category),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          job.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${job.category}${job.serviceType != 'N/A' ? ' • ${job.serviceType}' : ''}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'LKR ${job.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: job.isPaid
                                    ? AppTheme.success.withValues(alpha: 0.15)
                                    : AppTheme.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                job.isPaid ? 'PAID' : 'UNPAID',
                                style: TextStyle(
                                  color: job.isPaid
                                      ? AppTheme.success
                                      : AppTheme.danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: jobProv.todayJobs.length,
              ),
            ),

          // Empty state
          if (jobProv.todayJobs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No jobs recorded today',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + New Job to get started',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.accent),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Repair':
        return AppTheme.accent;
      case 'Service':
        return AppTheme.success;
      case 'Maintenance':
        return AppTheme.warning;
      case 'Installation':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Repair':
        return Icons.build_rounded;
      case 'Service':
        return Icons.home_repair_service_rounded;
      case 'Maintenance':
        return Icons.engineering_rounded;
      case 'Installation':
        return Icons.install_desktop_rounded;
      default:
        return Icons.work;
    }
  }
}

/// ─── Sales Progress Card ───
class _SalesProgressCard extends StatelessWidget {
  final double revenue;
  final double target;
  final double progress;

  const _SalesProgressCard({
    required this.revenue,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final Color barColor = progress >= 1.0
        ? AppTheme.success
        : progress >= 0.5
            ? AppTheme.accent
            : AppTheme.warning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Sales Target',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: AppTheme.surfaceInput,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenue',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'LKR ${revenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: barColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'LKR ${target.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Stat Card ───
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool fullWidth;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    this.fullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: card) : card;
  }
}
