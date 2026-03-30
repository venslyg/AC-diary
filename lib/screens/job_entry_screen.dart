import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart' as app;
import '../providers/job_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';

class JobEntryScreen extends StatefulWidget {
  final JobModel? editJob;
  const JobEntryScreen({super.key, this.editJob});

  @override
  State<JobEntryScreen> createState() => _JobEntryScreenState();
}

class _JobEntryScreenState extends State<JobEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Repair';
  String _serviceType = 'N/A';
  bool _isPaid = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editJob != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final job = widget.editJob!;
      _nameController.text = job.customerName;
      _mobileController.text = job.mobileNumber;
      _priceController.text = job.price.toStringAsFixed(0);
      _descController.text = job.description;
      _category = job.category;
      _serviceType = job.serviceType;
      _isPaid = job.isPaid;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final uid = context.read<app.AuthProvider>().user!.uid;
    final now = DateTime.now();
    final job = JobModel(
      customerName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      category: _category,
      serviceType: _category == 'Service' ? _serviceType : 'N/A',
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      isPaid: _isPaid,
      timestamp: _isEditing ? widget.editJob!.timestamp : now,
      dateKey: _isEditing
          ? widget.editJob!.dateKey
          : DateFormat('yyyy-MM-dd').format(now),
    );

    try {
      if (_isEditing) {
        context
            .read<JobProvider>()
            .updateJob(uid, widget.editJob!.id!, job);
      } else {
        context.read<JobProvider>().addJob(uid, job);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Job updated successfully!'
                : 'Job added successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.accent,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1,
      ),
    );
  }

  final _categories = const ['Repair', 'Service', 'Maintenance', 'Installation'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Job' : 'Add New Job'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info Section
              _sectionLabel('Customer Information'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppTheme.accent),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter customer name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppTheme.accent),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter mobile number' : null,
              ),
              const SizedBox(height: 24),

              // Job Details Section
              _sectionLabel('Job Details'),
              const SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                dropdownColor: AppTheme.surfaceCard,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon:
                      Icon(Icons.category_outlined, color: AppTheme.accent),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                    if (_category != 'Service') {
                      _serviceType = 'N/A';
                    } else {
                      _serviceType = 'Full';
                    }
                  });
                },
              ),
              const SizedBox(height: 14),

              // Service Type Sub-dropdown (only for Service category)
              if (_category == 'Service') ...[
                DropdownButtonFormField<String>(
                  initialValue: _serviceType == 'N/A' ? 'Full' : _serviceType,
                  dropdownColor: AppTheme.surfaceCard,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    prefixIcon: Icon(Icons.miscellaneous_services_outlined,
                        color: AppTheme.accent),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Full', child: Text('Full')),
                    DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  ],
                  onChanged: (val) {
                    setState(() => _serviceType = val!);
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (LKR)',
                  prefixIcon: Icon(Icons.payments_outlined,
                      color: AppTheme.accent),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter price';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 42),
                    child: Icon(Icons.notes_rounded, color: AppTheme.accent),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Status Toggle
              _sectionLabel('Payment Status'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isPaid
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color:
                                _isPaid ? AppTheme.success : AppTheme.danger,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isPaid ? 'Paid' : 'Unpaid',
                            style: TextStyle(
                              color: _isPaid
                                  ? AppTheme.success
                                  : AppTheme.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isPaid,
                        activeThumbColor: AppTheme.success,
                        inactiveTrackColor:
                            AppTheme.danger.withValues(alpha: 0.3),
                        onChanged: (val) {
                          setState(() => _isPaid = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryDark,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save_rounded : Icons.save),
                  label: Text(_isEditing ? 'Update Job' : 'Save Job'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
