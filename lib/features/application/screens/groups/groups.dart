import 'package:fair_share/features/application/screens/groups/create_group.dart';
import 'package:fair_share/features/application/screens/groups/join_group.dart';
import 'package:fair_share/features/application/screens/groups/my_groups.dart';
import 'package:fair_share/features/application/screens/groups/widgets/group_button.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GroupActionButton(
              label: 'My Groups',
              onPressed: () => Get.to(() => const MyGroupsScreen()),
            ),
            const SizedBox(height: 16),
            GroupActionButton(
              label: 'Create Group',
              onPressed: () => Get.to(() => const CreateGroupScreen()),
            ),
            const SizedBox(height: 16),
            GroupActionButton(
              label: 'Join Group',
              onPressed: () => Get.to(() => const JoinGroupScreen()),
            ),
          ],
        ),
      ),
    );
  }
}