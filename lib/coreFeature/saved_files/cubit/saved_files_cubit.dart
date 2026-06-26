import 'dart:io';
import 'package:bloc/bloc.dart';
import '../../scanner/services/file_service.dart';
import 'saved_files_state.dart';

class SavedFilesCubit extends Cubit<SavedFilesState> {
  SavedFilesCubit() : super(SavedFilesState()) {
    loadFiles();
  }

  Future<void> loadFiles() async {
    emit(state.copyWith(isLoading: true));
    try {
      final files = await FileService.getSavedFiles();
      emit(state.copyWith(files: files, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteFile(File file) async {
    await FileService.deleteFile(file);
    await loadFiles();
  }
}
