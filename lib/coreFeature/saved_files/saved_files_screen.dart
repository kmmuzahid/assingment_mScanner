import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinlink/config/color/app_color.dart';
import 'package:pinlink/config/route/app_router.gr.dart';
import 'package:pinlink/coreFeature/saved_files/cubit/saved_files_cubit.dart';
import 'package:pinlink/coreFeature/saved_files/cubit/saved_files_state.dart';
import 'package:pinlink/utils/formatters.dart';
import 'package:share_plus/share_plus.dart';

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
      appBar: AppBar(
        title: const Text('Saved File List'),
        backgroundColor: const Color(0xff08586d),
        titleTextStyle: const TextStyle(
          color: Color(0xffa9cfd4),
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      body: BlocBuilder<SavedFilesCubit, SavedFilesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.files.isEmpty) {
            return const Center(child: Text('No saved files found.'));
          }

          return Column(
            children: [
              const Padding(
                padding: .symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.task, color: Colors.white, size: 24),
                    Text(
                      'Inspection List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];

                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
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
                                      formatSavedFileDate(
                                        file.lastModifiedSync(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
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
                              Expanded(
                                child: _button(
                                  title: 'View',
                                  color: const Color(0xff08586d),
                                  onTap: () {
                                    context.pushRoute(
                                      SavedFileDetailRoute(file: file),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _button(
                                  title: 'Delete',
                                  color: MockupColors.errorRed,
                                  onTap: () => cubit.deleteFile(file),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _button(
                                  title: 'Send',
                                  color: const Color(0xff08586d),
                                  onTap: () => _shareFile(file),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _button({
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
