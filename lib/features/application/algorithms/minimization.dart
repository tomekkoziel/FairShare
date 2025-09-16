// lib/core/settlement/greedy_min_cash_flow.dart
import 'dart:math' as math;

import 'package:fair_share/features/application/screens/groups/group_details_screen.dart';

class SettlementPair {
  final String from; // debtor
  final String to;   // creditor
  final double amount;
  SettlementPair(this.from, this.to, this.amount);
}

class _Party {
  final String name;
  double amount; // positive value
  _Party(this.name, this.amount);
}

/// Greedy Min-Cash-Flow from net balances.
/// members: netAmount > 0 => should RECEIVE; netAmount < 0 => OWES.
/// Returns debtor -> creditor transfers.
List<SettlementPair> greedyMinCashFlow(
  List<MemberDebt> members, {
  int decimals = 2,
}) {
  const eps = 1e-9;
  final creditors = <_Party>[];
  final debtors = <_Party>[];

  for (final m in members) {
    if (m.netAmount > eps) creditors.add(_Party(m.memberName, m.netAmount));
    else if (m.netAmount < -eps) debtors.add(_Party(m.memberName, -m.netAmount));
  }

  // Descending by amount
  int _cmp(_Party a, _Party b) => b.amount.compareTo(a.amount);
  creditors.sort(_cmp);
  debtors.sort(_cmp);

  double _round(double x) {
    final p = math.pow(10, decimals).toDouble();
    return (x * p).round() / p;
  }

  final res = <SettlementPair>[];

  while (creditors.isNotEmpty && debtors.isNotEmpty) {
    final c = creditors.first; // biggest creditor
    final d = debtors.first;   // biggest debtor

    final pay = d.amount < c.amount ? d.amount : c.amount; // exact math
    final payRounded = _round(pay);
    if (payRounded > eps) {
      res.add(SettlementPair(d.name, c.name, payRounded));
    }

    // Update running balances (keep high precision internally)
    d.amount -= pay;
    c.amount -= pay;

    // Remove settled parties
    if (d.amount <= eps) debtors.removeAt(0);
    if (c.amount <= eps) creditors.removeAt(0);

    // Resort only heads (simple & good enough for small n)
    creditors.sort(_cmp);
    debtors.sort(_cmp);
  }

  return res;
}
