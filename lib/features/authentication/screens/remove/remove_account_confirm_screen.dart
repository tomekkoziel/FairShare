import 'package:flutter/material.dart';
import 'remove_account_success_screen.dart';

class RemoveAccountConfirmScreen extends StatefulWidget {
  static const routeName = '/remove-account';
  const RemoveAccountConfirmScreen({super.key});

  @override
  State<RemoveAccountConfirmScreen> createState() => _RemoveAccountConfirmScreenState();
}

class _RemoveAccountConfirmScreenState extends State<RemoveAccountConfirmScreen> {
  final _controller = TextEditingController();
  bool _ack = false;
  bool _isDeleting = false;
  String? _error;

  bool get _canDelete => _ack && _controller.text.trim().toUpperCase() == 'DELETE';

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RemoveAccountSuccessScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Remove account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(Icons.warning_amber_rounded, size: 72, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'This action is permanent',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Deleting your account will remove your profile and may delete your groups/expenses depending on ownership and app policy.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _ack,
              onChanged: (v) => setState(() => _ack = v ?? false),
              title: const Text('I understand this action cannot be undone'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to confirm',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: _isDeleting || !_canDelete ? null : _deleteAccount,
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete account'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
