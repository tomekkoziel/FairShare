import 'package:flutter/material.dart';

class GroupActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GroupActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}