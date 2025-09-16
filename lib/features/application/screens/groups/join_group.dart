import 'package:flutter/material.dart';
import 'package:fair_share/utils/constants/sizes.dart';

class JoinGroupScreen extends StatefulWidget {
  static const routeName = '/join-group';
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdCtrl = TextEditingController();
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _groupIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isJoining = true;
      _error = null;
    });

    final groupId = _groupIdCtrl.text.trim();

    try {
      /// TODO: Call your backend to join by ID (and handle perms/invite codes).
      /// await groupRepository.joinGroupById(groupId);
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined group $groupId')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupIdCtrl,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Group ID',
                  hintText: 'e.g., grp_123ABC',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Group ID is required' : null,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isJoining ? null : _join,
                  icon: _isJoining
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.group_add_rounded),
                  label: Text(_isJoining ? 'Joining…' : 'Join Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
