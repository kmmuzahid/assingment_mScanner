import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pinlink/config/color/app_color.dart';
import 'package:pinlink/config/route/app_router.gr.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            _MenuButton(
              icon: Icons.qr_code_scanner,
              label: 'Scanner',
              onTap: () => context.pushRoute(const ScannerRoute()),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.folder,
              label: 'Saved File List',
              onTap: () => context.pushRoute(const SavedFilesRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MockupColors.mint,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: MockupColors.pageBackground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MockupColors.pageBackground,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: MockupColors.pageBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
