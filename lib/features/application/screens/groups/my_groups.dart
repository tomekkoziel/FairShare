import 'package:fair_share/features/application/screens/groups/create_group.dart';
import 'package:fair_share/features/application/screens/groups/group_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class GroupSummary {
  final String id;
  final String name;
  final String description;
  final String baseCurrency;
  GroupSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCurrency,
  });
}

class MyGroupsScreen extends StatefulWidget {
  static const routeName = '/my-groups';
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  late Future<List<GroupSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadGroups();
  }

  Future<List<GroupSummary>> _loadGroups() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return <GroupSummary>[
    //   // Sample only; return [] to see the empty state
    //   GroupSummary(
    //     id: 'grp_123',
    //     name: 'Weekend Trip',
    //     description: 'Zakopane 2025 – cabin & food',
    //     baseCurrency: 'PLN',
    //   ),
      GroupSummary(
        id: 'grp_456',
        name: 'Flatmates',
        description: 'Rent, utilities and groceries',
        baseCurrency: 'PLN',
      ),
    ];
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadGroups());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Groups')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<GroupSummary>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Text('Failed to load groups: ${snap.error}'),
                  )
                ],
              );
            }
            final groups = snap.data ?? [];
            if (groups.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('You’re not in any groups yet.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final g = groups[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  leading: CircleAvatar(child: Text(g.name.isNotEmpty ? g.name[0] : '?')),
                  title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${g.baseCurrency} • ${g.description}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // TODO: Navigate to Group Details screen, pass g.id
                    // Navigator.pushNamed(context, GroupDetailsScreen.routeName, arguments: g.id);
                    Get.to(() => GroupDetailsScreen(groupId: "grp_456"));
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => CreateGroupScreen()),//=> Navigator.pushNamed(context, CreateGroupScreen.routeName).then((_) => _refresh()),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}

// // Forward declaration to avoid import loops in this snippet
// class CreateGroupScreen extends StatelessWidget {
//   static const routeName = '/create-group';
//   const CreateGroupScreen({super.key});

//   @override
//   Widget build(BuildContext context) => const SizedBox.shrink();
// }
