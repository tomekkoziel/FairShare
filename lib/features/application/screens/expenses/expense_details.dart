import 'package:flutter/material.dart';
import 'package:fair_share/utils/constants/sizes.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  static const routeName = '/expense-details';

  final String groupId;
  final String expenseId;

  const ExpenseDetailsScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // State
  List<String> _members = const []; // loaded with expense (replace with IDs in real app)
  List<String> _currencies = const ['PLN', 'EUR', 'USD', 'JPY', 'GBP'];
  String _currency = 'PLN';
  String _paidBy = '';
  Set<String> _paidFor = {};
  DateTime? _createdAt;

  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// TODO: Replace with real backend call
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Future.delayed(const Duration(milliseconds: 350));

      // Demo data — replace with your fetched DTO
      _members = ['JKowalski01', 'Kasiaaa5', 'Piotrek123'];
      _titleCtrl.text = 'Groceries';
      _amountCtrl.text = '129';
      _currency = 'PLN';
      _descCtrl.text = 'Biedronka: food, cleaning supplies, snacks';
      _paidBy = 'JKowalski01';
      _paidFor = {'JKowalski01', 'Kasiaaa5', 'Piotrek123'};
      _createdAt = DateTime.now().subtract(const Duration(hours: 3));

    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paidFor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one person in “Paid for who”.')),
      );
      return;
    }

    setState(() { _saving = true; _error = null; });
    try {
      final title = _titleCtrl.text.trim();
      final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      final desc = _descCtrl.text.trim();

      /// TODO: Update backend with (expenseId, groupId, title, amount, currency, desc, paidBy, paidFor)
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')));
      Navigator.pop(context, true); // return true so parent can refresh
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _deleting = true; _error = null; });
    try {
      /// TODO: Delete from backend (expenseId, groupId)
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted')));
      Navigator.pop(context, true); // return true to trigger refresh / removal
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  String _fmtDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = dt.toLocal();
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        // actions: [
        //   IconButton(
        //     tooltip: 'Delete',
        //     onPressed: _loading || _deleting ? null : _delete,
        //     icon: _deleting
        //         ? const Padding(
        //             padding: EdgeInsets.all(10),
        //             child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        //           )
        //         : const Icon(Icons.delete_rounded),
        //   ),
        // ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                      if (_createdAt != null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Created: ${_fmtDateTime(_createdAt!)}',
                              style: theme.textTheme.bodySmall),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                      ],
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
                              items: _currencies
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
                        items: _members.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
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
                          itemCount: _members.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final m = _members[i];
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
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save_rounded),
                          label: Text(_saving ? 'Saving…' : 'Save changes'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleting || _loading ? null : _delete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete expense'),
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
