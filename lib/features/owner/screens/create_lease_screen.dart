import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/owner_lease_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class CreateLeaseScreen extends ConsumerStatefulWidget {
  final Map<String, String>? extra;
  const CreateLeaseScreen({super.key, this.extra});

  @override
  ConsumerState<CreateLeaseScreen> createState() => _CreateLeaseScreenState();
}

class _CreateLeaseScreenState extends ConsumerState<CreateLeaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _tenantPhoneCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  int _rentDueDay = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _termsCtrl.dispose();
    _tenantPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(ownerLeaseProvider.notifier).createLease({
        'tenantPhone': _tenantPhoneCtrl.text.trim(),
        'propertyId': widget.extra?['propertyId'],
        'startDate': _startDate.toIso8601String().substring(0, 10),
        'endDate': _endDate.toIso8601String().substring(0, 10),
        'rentAmount': double.parse(_rentCtrl.text),
        'securityDeposit': double.parse(_depositCtrl.text),
        'rentDueDay': _rentDueDay,
        'terms': _termsCtrl.text.trim().isNotEmpty ? _termsCtrl.text.trim() : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lease created and sent to tenant!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lease')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Tenant Details'),
              TextFormField(
                controller: _tenantPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Tenant Phone Number *', prefixText: '+880 '),
                validator: (v) => v?.isEmpty == true ? 'Tenant phone is required' : null,
              ),
              const SizedBox(height: 20),

              _SectionTitle('Lease Period'),
              Row(
                children: [
                  Expanded(child: _DateButton(label: 'Start Date', date: _startDate, onTap: () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _DateButton(label: 'End Date', date: _endDate, onTap: () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 20),

              _SectionTitle('Financial Details'),
              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent (৳) *', prefixText: '৳ '),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _depositCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Security Deposit (৳) *', prefixText: '৳ '),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rent Due Day:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  DropdownButton<int>(
                    value: _rentDueDay,
                    items: List.generate(28, (i) => i + 1).map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('${d}th'),
                    )).toList(),
                    onChanged: (v) => setState(() => _rentDueDay = v!),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionTitle('Terms & Conditions (Optional)'),
              TextFormField(
                controller: _termsCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter lease terms, conditions, clauses...',
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Create & Send to Tenant',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
