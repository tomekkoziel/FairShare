import 'package:fair_share/features/application/screens/expenses/add_expense.dart';
import 'package:fair_share/features/application/screens/expenses/expense_details.dart';
import 'package:flutter/material.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:get/route_manager.dart';
import 'package:flutter/services.dart';

/// Algorithms (names in English as requested)
enum SettlementAlgorithm {
  minimizationOfNumberOfPayments,
  optimizedMinimizationOfNumberOfPayments,
}

String algorithmEnglishName(SettlementAlgorithm a) {
  switch (a) {
    case SettlementAlgorithm.minimizationOfNumberOfPayments:
      return 'Minimization of the Number of Payments';
    case SettlementAlgorithm.optimizedMinimizationOfNumberOfPayments:
      return 'Optimized Minimization of the Number of Payments';
  }
}

/// --- Models used by this screen (replace with your real ones) ---
class TransactionItem {
  final String title;
  final DateTime dateTime;
  final double amount;
  final String currency; // e.g., 'PLN'
  final String paidBy;
  final List<String> owes; // names of members who owe for this expense

  TransactionItem({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.owes,
  });
}

class MemberDebt {
  final String memberName;
  /// Net balance for the whole group context:
  /// > 0 => the member should receive this amount
  /// < 0 => the member owes this amount
  final double netAmount;

  MemberDebt({required this.memberName, required this.netAmount});
}

class GroupDetails {
  final String id;
  final String name;
  final String baseCurrency;
  final double totalExpenses; // total of all expenses in base currency
  final SettlementAlgorithm algorithm;
  final List<TransactionItem> transactions;
  final List<MemberDebt> memberDebts;

  GroupDetails({
    required this.id,
    required this.name,
    required this.baseCurrency,
    required this.totalExpenses,
    required this.algorithm,
    required this.transactions,
    required this.memberDebts,
  });

  GroupDetails copyWith({
    String? id,
    String? name,
    String? baseCurrency,
    double? totalExpenses,
    SettlementAlgorithm? algorithm,
    List<TransactionItem>? transactions,
    List<MemberDebt>? memberDebts,
  }) {
    return GroupDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      algorithm: algorithm ?? this.algorithm,
      transactions: transactions ?? this.transactions,
      memberDebts: memberDebts ?? this.memberDebts,
    );
  }
}

// Pairwise settlement produced from net balances (debtor -> creditor)
class _Settlement {
  final String from; // debtor
  final String to;   // creditor
  final double amount;
  _Settlement({required this.from, required this.to, required this.amount});
}


/// --- Screen ---
class GroupDetailsScreen extends StatefulWidget {
  static const routeName = '/group-details';

  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late Future<GroupDetails> _future;
  GroupDetails? _data; // keep the latest loaded data in memory (for quick UI updates)
  
  // NEW: turn manual IOUs on/off and store them here
  static const bool _useManualSettlements = true;
  List<_Settlement>? _manualSettlements;

  bool _working = false; // for algorithm change busy state

  @override
  void initState() {
    super.initState();
    _future = _loadGroup(widget.groupId);
  }

  List<_Settlement> _computeSettlements(List<MemberDebt> members) {
  final creditors = <MapEntry<String, double>>[];
  final debtors = <MapEntry<String, double>>[];

  for (final m in members) {
    if (m.netAmount > 0) {
      creditors.add(MapEntry(m.memberName, m.netAmount));
    } else if (m.netAmount < 0) {
      debtors.add(MapEntry(m.memberName, -m.netAmount)); // store as positive debt
    }
  }

  // Smallest-first greedy pairing is fine for display purposes
  creditors.sort((a, b) => a.value.compareTo(b.value));
  debtors.sort((a, b) => a.value.compareTo(b.value));

  final res = <_Settlement>[];
  var i = 0, j = 0;

  while (i < debtors.length && j < creditors.length) {
    final d = debtors[i];
    final c = creditors[j];
    final pay = d.value < c.value ? d.value : c.value;

    res.add(_Settlement(from: d.key, to: c.key, amount: pay));

    final dRemain = d.value - pay;
    final cRemain = c.value - pay;

    if (dRemain <= 1e-9) {
      i++;
    } else {
      debtors[i] = MapEntry(d.key, dRemain);
    }

    if (cRemain <= 1e-9) {
      j++;
    } else {
      creditors[j] = MapEntry(c.key, cRemain);
    }
  }

  return res;
}


  /// TODO: Replace with real repo/service calls
  Future<GroupDetails> _loadGroup(String groupId) async {
    // Simulate load
    await Future.delayed(const Duration(milliseconds: 350));

    final now = DateTime.now();
    final tx = <TransactionItem>[
      // TransactionItem(title: 'Groceries', dateTime: now.subtract(const Duration(hours: 3)), amount: 129, currency: 'PLN', paidBy: 'JKowalski01', owes: ['JKowalski01', 'Kasiaaa5', 'Piotrek123'])
    TransactionItem(
      title: 'Expense1',
      dateTime: now.subtract(const Duration(minutes: 5)),
      amount: 30,
      currency: 'PLN',
      paidBy: 'Kasiaaa5', // creditor/receiver
      owes: ['JKowalski01'], // debtor
    ),

    // JKowalski01 → Piotrek123 $10
    TransactionItem(
      title: 'Expense2',
      dateTime: now.subtract(const Duration(minutes: 10)),
      amount: 10,
      currency: 'PLN',
      paidBy: 'Piotrek123',
      owes: ['JKowalski01'],
    ),

    // Kasiaaa5 → Piotrek123 $40
    TransactionItem(
      title: 'Expense3',
      dateTime: now.subtract(const Duration(minutes: 15)),
      amount: 40,
      currency: 'PLN',
      paidBy: 'Piotrek123',
      owes: ['Kasiaaa5'],
    ),

    // Piotrek123 → David $20
    TransactionItem(
      title: 'Expense4',
      dateTime: now.subtract(const Duration(minutes: 20)),
      amount: 20,
      currency: 'PLN',
      paidBy: 'David',
      owes: ['Piotrek123'],
    ),

    // David → Ema $50
    TransactionItem(
      title: 'Expense5',
      dateTime: now.subtract(const Duration(minutes: 25)),
      amount: 50,
      currency: 'PLN',
      paidBy: 'Ema',
      owes: ['David'],
    ),

    // Fred → Ema $10
    TransactionItem(
      title: 'Expense6',
      dateTime: now.subtract(const Duration(minutes: 30)),
      amount: 10,
      currency: 'PLN',
      paidBy: 'Ema',
      owes: ['Fred'],
    ),

    // Fred → David $10
    TransactionItem(
      title: 'Expense7',
      dateTime: now.subtract(const Duration(minutes: 35)),
      amount: 10,
      currency: 'PLN',
      paidBy: 'David',
      owes: ['Fred'],
    ),

    // Fred → Piotrek123 $30
    TransactionItem(
      title: 'Expense8',
      dateTime: now.subtract(const Duration(minutes: 40)),
      amount: 30,
      currency: 'PLN',
      paidBy: 'Piotrek123',
      owes: ['Fred'],
    ),

    // Fred → Kasiaaa5 $10
    TransactionItem(
      title: 'Expense9',
      dateTime: now.subtract(const Duration(minutes: 45)),
      amount: 10,
      currency: 'PLN',
      paidBy: 'Kasiaaa5',
      owes: ['Fred'],
    ),
    ];

    final members = <MemberDebt>[
      MemberDebt(memberName: 'Ema', netAmount: 60),
      MemberDebt(memberName: 'Fred', netAmount: -60),
      MemberDebt(memberName: 'JKowalski01', netAmount: -40),
      MemberDebt(memberName: 'Kasiaaa5', netAmount: 0),
      MemberDebt(memberName: 'Piotrek123', netAmount: 50),
      MemberDebt(memberName: 'David', netAmount: -10),
      MemberDebt(memberName: 'Alice', netAmount: 0),
    ];

    final total = tx.fold<double>(0.0, (sum, t) => sum + t.amount);

    final details = GroupDetails(
      id: 'oKNkvLjOp1MsdtIdygw3',
      name: 'Flatmates',
      baseCurrency: 'PLN',
      totalExpenses: total,
      algorithm: SettlementAlgorithm.minimizationOfNumberOfPayments,
      transactions: tx,
      memberDebts: members,
    );

    // NEW: hardcode who pays whom (debtor -> creditor)
  _manualSettlements = <_Settlement>[
      _Settlement(from: 'JKowalski01', to: 'Kasiaaa5', amount: 10),   // JKowalski01 pays Ema 40
      _Settlement(from: 'JKowalski01', to: 'David', amount: 30),   // JKowalski01 pays Ema 40
      _Settlement(from: 'Kasiaaa5', to: 'Piotrek123', amount: 10),   // JKowalski01 pays Ema 40
      
      _Settlement(from: 'Fred',        to: 'Ema', amount: 20),   // Fred pays Ema 20
      _Settlement(from: 'Fred',        to: 'Piotrek123', amount: 40), // Fred pays Piotrek123 40
      _Settlement(from: 'David',       to: 'Ema', amount: 40), // David pays Piotrek123 10
    ];

    _data = details;
    return details;
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadGroup(widget.groupId));
    await _future;
  }

  Future<void> _chooseAlgorithm() async {
    if (_data == null) return;

    final chosen = await showModalBottomSheet<SettlementAlgorithm>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      builder: (ctx) {
        final current = _data!.algorithm;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Debt-settlement algorithm',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              RadioListTile<SettlementAlgorithm>(
                value: SettlementAlgorithm.minimizationOfNumberOfPayments,
                groupValue: current,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: Text(algorithmEnglishName(
                    SettlementAlgorithm.minimizationOfNumberOfPayments)),
                // subtitle: const Text('Polish: Minimalizacja liczby płatności'),
              ),
              RadioListTile<SettlementAlgorithm>(
                value:
                    SettlementAlgorithm.optimizedMinimizationOfNumberOfPayments,
                groupValue: current,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: Text(algorithmEnglishName(
                    SettlementAlgorithm.optimizedMinimizationOfNumberOfPayments)),
                // subtitle:
                    // const Text('Polish: Zoptymalizowana minimalizacja liczby płatności'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (chosen != null && chosen != _data!.algorithm) {
      setState(() => _working = true);
      try {
        /// TODO: Persist algorithm choice for this group on backend.
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _data = _data!.copyWith(algorithm: chosen);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Algorithm changed to ${algorithmEnglishName(chosen)}')),
        );
      } finally {
        if (mounted) setState(() => _working = false);
      }
    }
  }

  void _addExpense() async {
    /// TODO: Navigate to your Add Expense screen and refresh on return
    /// final created = await Get.to(() => const AddExpenseScreen());
    /// if (created == true) _refresh();
    Get.to(() => const AddExpenseScreen(groupId: "oKNkvLjOp1MsdtIdygw3", members: ["JKowalski01"], currencies: ['PLN', 'EUR', 'USD', 'JPY', 'GBP']));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('TODO: implement Add Expense flow')),
    // );
  }

  String _fmtDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = dt.toLocal();
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  String _money(double v, String currency) {
    return '${v.toStringAsFixed(2)} $currency';
  }

  Color _amountColor(double v, ThemeData theme) {
    if (v > 0) return Colors.teal; // to receive
    if (v < 0) return theme.colorScheme.error;
    return theme.textTheme.bodyMedium?.color ?? Colors.grey;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_data?.name ?? 'Group Details'),
        actions: [
          IconButton(
            tooltip: 'Change algorithm',
            onPressed: _working ? null : _chooseAlgorithm,
            icon: _working
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<GroupDetails>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && _data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Text('Failed to load group: ${snap.error}'),
                  )
                ],
              );
            }

            final group = _data ?? snap.data!;
          final settlements = (_useManualSettlements &&
                              _manualSettlements != null &&
                              _manualSettlements!.isNotEmpty)
              ? _manualSettlements!
              : _computeSettlements(group.memberDebts);
              final theme = Theme.of(context);

            return ListView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              children: [
                _GroupIdTile(groupId: group.id),
                const SizedBox(height: TSizes.spaceBtwSections),
                // --- Summary cards ---
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total expenses',
                        value: _money(group.totalExpenses, group.baseCurrency),
                        icon: Icons.receipt_long_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Algorithm',
                        value: algorithmEnglishName(group.algorithm),
                        icon: Icons.schema_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // --- Members net balances ---
                Text('Members’ net balances', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: group.memberDebts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final md = group.memberDebts[i];
                      final color = _amountColor(md.netAmount, theme);
                      final sign = md.netAmount > 0 ? '+' : '';
                      final caption = md.netAmount > 0 ? 'to receive' : (md.netAmount < 0 ? 'owes' : 'settled');

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(child: Text(md.memberName.isNotEmpty ? md.memberName[0] : '?')),
                        title: Text(md.memberName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(caption),
                            _SettlementArrows(
                              memberName: md.memberName,
                              settlements: settlements,
                              currency: group.baseCurrency,
                            ),
                          ],
                        ),
                        trailing: Text(
                          '$sign${_money(md.netAmount, group.baseCurrency)}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // --- Transaction history ---
                Text('Transaction history', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (group.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No expenses yet. Tap “Add expense” to create one.',
                          style: theme.textTheme.bodyMedium),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: group.transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = group.transactions[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: const CircleAvatar(child: Icon(Icons.payments_rounded)),
                          title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fmtDateTime(t.dateTime)),
                              const SizedBox(height: 2),
                              Text('Paid by ${t.paidBy} • Owes: ${t.owes.join(', ')}',
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: Text(
                            _money(t.amount, t.currency),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            Get.to(() => ExpenseDetailsScreen(groupId: "123123", expenseId: "exp_123"));
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 88), // bottom padding for FAB
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Simple summary tile
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _SummaryCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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

class _GroupIdTile extends StatelessWidget {
  final String groupId;
  const _GroupIdTile({required this.groupId});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: groupId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group ID copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.key_rounded),
        title: const Text('Group ID'),
        subtitle: SelectableText(
          groupId,
          maxLines: 1,
          onTap: () => _copy(context),
        ),
        trailing: IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => _copy(context),
        ),
      ),
    );
  }
}

class _SettlementArrows extends StatelessWidget {
  final String memberName;
  final List<_Settlement> settlements;
  final String currency;
  const _SettlementArrows({
    required this.memberName,
    required this.settlements,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final outgoing = settlements.where((s) => s.from == memberName).toList(); // debtor -> creditor
    final incoming = settlements.where((s) => s.to == memberName).toList();   // payer -> this creditor

    if (outgoing.isEmpty && incoming.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final chips = <Widget>[];

    // Outgoing: member pays → X
    for (final s in outgoing) {
      chips.add(_ArrowChip(text: '→ ${s.to} ${s.amount.toStringAsFixed(2)} $currency'));
    }

    // Incoming: X pays → member
    for (final s in incoming) {
      chips.add(_ArrowChip(text: '${s.from} ${s.amount.toStringAsFixed(2)} $currency →'));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 6,
        runSpacing: -6,
        children: chips,
      ),
    );
  }
}

class _ArrowChip extends StatelessWidget {
  final String text;
  const _ArrowChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }
}
