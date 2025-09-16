import 'package:flutter/material.dart';
import 'package:fair_share/utils/constants/sizes.dart';

class AddExpenseScreen extends StatefulWidget {
  static const routeName = '/add-expense';

  final String groupId;
  /// Display names for members (replace with IDs+names in your app if needed)
  final List<String> members;
  final List<String> currencies;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.members,
    this.currencies = const ['PLN', 'EUR', 'USD', 'JPY', 'GBP'],
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late String _currency;
  late String _paidBy;
  late Set<String> _paidFor;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currency = widget.currencies.first;
    _paidBy = widget.members.isNotEmpty ? widget.members.first : '';
    _paidFor = widget.members.toSet(); // default: all members benefit
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paidFor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one person in “Paid for who”.')),
      );
      return;
    }

    setState(() { _isSubmitting = true; _error = null; });

    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();
    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));

    try {
      /// TODO: Persist to backend (groupId, title, amount, currency, description, paidBy, paidFor)
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
      Navigator.pop(context, true); // return true so parent can refresh
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
            top: TSizes.defaultSpace,
            bottom: MediaQuery.of(context).viewInsets.bottom + TSizes.defaultSpace,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 80,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: 'e.g. 123.45',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Amount is required';
                          final parsed = double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        items: widget.currencies
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _currency = v ?? _currency),
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 300,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                DropdownButtonFormField<String>(
                  value: _paidBy.isNotEmpty ? _paidBy : null,
                  items: widget.members
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _paidBy = v ?? _paidBy),
                  decoration: const InputDecoration(
                    labelText: 'Paid by who',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Select the payer' : null,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Paid for who', style: theme.textTheme.titleSmall),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: widget.members.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = widget.members[i];
                      final selected = _paidFor.contains(m);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _paidFor.add(m);
                            } else {
                              _paidFor.remove(m);
                            }
                          });
                        },
                        title: Text(m),
                        dense: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_isSubmitting ? 'Saving…' : 'Save expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
