import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/saved_file_detail_cubit.dart';
import 'cubit/saved_file_detail_state.dart';
import '../../utils/formatters.dart';

@RoutePage()
class SavedFileDetailScreen extends StatelessWidget {
  final File file;

  const SavedFileDetailScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedFileDetailCubit(file),
      child: _SavedFileDetailScreenView(fileName: file.path.split('/').last),
    );
  }
}

class _SavedFileDetailScreenView extends StatelessWidget {
  final String fileName;

  const _SavedFileDetailScreenView({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: BlocBuilder<SavedFileDetailCubit, SavedFileDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.csvData.isEmpty) {
            return const Center(child: Text('File is empty.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMaxHeight: double.infinity,
                dataRowMinHeight: 48,
                columns: state.csvData.first
                    .map(
                      (header) => DataColumn(
                        label: Text(
                          header.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
                rows: state.csvData.skip(1).map((row) {
                  return DataRow(
                    cells: row
                        .map((cell) => DataCell(
                              Container(
                                constraints: const BoxConstraints(maxWidth: 250),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ExpandableTextWidget(
                                  text: formatStringIfDate(cell.toString()),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
