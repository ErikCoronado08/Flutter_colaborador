import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UserInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const UserInfoCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(role, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
