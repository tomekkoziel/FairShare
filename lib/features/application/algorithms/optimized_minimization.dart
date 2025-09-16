// lib/core/settlement/dinic_simplifier.dart
import 'dart:collection';

class Transfer {
  final int from; // index in people[]
  final int to;
  final double amount;
  Transfer(this.from, this.to, this.amount);
}

class _Edge {
  final int from, to;
  double cap;
  double flow = 0.0;
  _Edge? rev;
  _Edge(this.from, this.to, this.cap);
  double get remaining => cap - flow;
  void augment(double f) {
    flow += f;
    rev!.flow -= f;
  }
}

class _Dinic {
  final int n;
  late List<List<_Edge>> g;
  late List<int> level, it;
  int s = 0, t = 0;

  _Dinic(this.n) {
    g = List.generate(n, (_) => <_Edge>[]);
    level = List.filled(n, 0);
    it = List.filled(n, 0);
  }

  void addEdge(int u, int v, double cap) {
    final a = _Edge(u, v, cap);
    final b = _Edge(v, u, 0.0);
    a.rev = b; b.rev = a;
    g[u].add(a);
    g[v].add(b);
  }

  void addEdges(Iterable<Transfer> edges) {
    for (final e in edges) {
      addEdge(e.from, e.to, e.amount);
    }
  }

  void setST(int source, int sink) { s = source; t = sink; }

  bool _bfs() {
    level.fillRange(0, n, -1);
    final q = Queue<int>();
    level[s] = 0; q.addLast(s);
    while (q.isNotEmpty) {
      final u = q.removeFirst();
      for (final e in g[u]) {
        if (level[e.to] == -1 && e.remaining > 1e-12) {
          level[e.to] = level[u] + 1;
          q.addLast(e.to);
        }
      }
    }
    return level[t] != -1;
  }

  double _dfs(int u, double f) {
    if (u == t) return f;
    for (var i = it[u]; i < g[u].length; i++, it[u] = i) {
      final e = g[u][i];
      if (e.remaining > 1e-12 && level[e.to] == level[u] + 1) {
        final pushed = _dfs(e.to, f < e.remaining ? f : e.remaining);
        if (pushed > 1e-12) {
          e.augment(pushed);
          return pushed;
        }
      }
    }
    return 0.0;
  }

  double maxFlow() {
    double flow = 0.0;
    while (_bfs()) {
      it.fillRange(0, n, 0);
      for (;;) {
        final pushed = _dfs(s, 1e100);
        if (pushed <= 1e-12) break;
        flow += pushed;
      }
    }
    return flow;
  }

  /// Export only FORWARD edges with remaining capacity (fixed vs Java).
  Iterable<Transfer> exportRemainingForwards() sync* {
    for (final adj in g) {
      for (final e in adj) {
        if (e.cap > 1e-12) { // forward edge
          final remaining = e.cap - (e.flow > 0 ? e.flow : 0.0);
          if (remaining > 1e-12) yield Transfer(e.from, e.to, remaining);
        }
      }
    }
  }
}

/// Heuristic “simplify debts with Dinic” (edge-by-edge routing).
/// people: list of names (indices are used in transfers)
/// edges: original directed debts (u -> v with amount)
List<Transfer> simplifyDebtsWithDinic({
  required List<String> people,
  required List<Transfer> edges,
}) {
  final n = people.length;
  // Work graph
  var solver = _Dinic(n)..addEdges(edges);
  final visited = <int>{};

  int? _pickUnvisited() {
    for (var i = 0; i < edges.length; i++) {
      final key = edges[i].from * 1000003 + edges[i].to; // hash
      if (!visited.contains(key)) return i;
    }
    return null;
  }

  while (true) {
    final idx = _pickUnvisited();
    if (idx == null) break;

    final src = edges[idx].from, snk = edges[idx].to;
    solver.setST(src, snk);
    final mf = solver.maxFlow();

    // mark visited (src, snk)
    visited.add(src * 1000003 + snk);

    // rebuild graph from remaining capacities (FORWARD edges only)
    final remaining = solver.exportRemainingForwards().toList();

    // plus the consolidated direct edge src -> snk with capacity = maxFlow
    if (mf > 1e-12) remaining.add(Transfer(src, snk, mf));

    solver = _Dinic(n)..addEdges(remaining);
  }

  // Whatever edges remain now are the simplified debts.
  // Merge parallel edges (just in case).
  final map = <int, double>{};
  for (final e in solver.exportRemainingForwards()) {
    final key = e.from * 1000003 + e.to;
    map.update(key, (v) => v + e.amount, ifAbsent: () => e.amount);
  }
  return map.entries
      .map((kv) {
        final k = kv.key;
        final u = k ~/ 1000003;
        final v = k % 1000003;
        return Transfer(u, v, kv.value);
      })
      .where((t) => t.amount > 1e-12)
      .toList();
}
