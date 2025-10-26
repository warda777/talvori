import 'package:flutter/material.dart';
import 'package:talvori/ui/common/mini_badge.dart';

/// Beispiele für verschiedene MiniBadge-Varianten
class MiniBadgeExamples extends StatelessWidget {
  const MiniBadgeExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MiniBadge Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Standard Badges:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
                MiniBadge(icon: Icons.star, label: 'Top 10'),
                MiniBadge(icon: Icons.new_releases, label: 'Neu'),
                MiniBadge(icon: Icons.trending_up, label: 'Trending'),
                MiniBadge(label: 'Text Only'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Custom Colors:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MiniBadge(
                  icon: Icons.star,
                  label: 'Premium',
                  color: Colors.amber.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.error,
                  label: 'Error',
                  color: Colors.red.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.check_circle,
                  label: 'Success',
                  color: Colors.green.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.info,
                  label: 'Info',
                  color: Colors.blue.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Custom Margins:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                MiniBadge(
                  icon: Icons.cloud_off,
                  label: 'Offline',
                  margin: EdgeInsets.only(bottom: 6),
                ),
                MiniBadge(
                  icon: Icons.star,
                  label: 'Featured',
                  margin: EdgeInsets.symmetric(horizontal: 4),
                ),
                MiniBadge(
                  icon: Icons.new_releases,
                  label: 'New',
                  margin: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
