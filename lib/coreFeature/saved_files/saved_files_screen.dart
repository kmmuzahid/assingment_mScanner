import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinlink/config/color/app_color.dart';
import 'package:pinlink/config/route/app_router.gr.dart';
import 'package:share_plus/share_plus.dart';

import 'cubit/saved_files_cubit.dart';
import 'cubit/saved_files_state.dart';
import 'package:pinlink/utils/formatters.dart';

@RoutePage()
class SavedFilesScreen extends StatelessWidget {
  const SavedFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedFilesCubit(),
      child: const _SavedFilesScreenView(),
    );
  }
}

class _SavedFilesScreenView extends StatelessWidget {
  const _SavedFilesScreenView();

  void _shareFile(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Check out my scan results');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SavedFilesCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved File List')),
      body: BlocBuilder<SavedFilesCubit, SavedFilesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.files.isEmpty) {
            return const Center(child: Text('No saved files found.'));
          }

          return ListView.builder(
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              final file = state.files[index];

              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MockupColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MockupColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_box,
                          color: MockupColors.mint,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inspection List',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MockupColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatTimeAMPM(file.lastModifiedSync()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MockupColors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _button(
                          title: 'View',
                          icon: Icons.remove_red_eye,
                          color: MockupColors.mint,
                          onTap: () {
                            context.pushRoute(SavedFileDetailRoute(file: file));
                          },
                        ),
                        const SizedBox(width: 10),
                        _button(
                          icon: Icons.delete,
                          title: 'Delete',
                          color: MockupColors.errorRed,
                          onTap: () => cubit.deleteFile(file),
                        ),
                        const SizedBox(width: 10),
                        _button(
                          title: 'Send',
                          icon: Icons.send,
                          color: MockupColors.mint,
                          onTap: () => _shareFile(file),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _button({
    required String title,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
