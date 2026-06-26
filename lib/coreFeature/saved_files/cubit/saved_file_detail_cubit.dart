import 'dart:io';
import 'package:bloc/bloc.dart';
import '../../scanner/services/file_service.dart';
import 'saved_file_detail_state.dart';

class SavedFileDetailCubit extends Cubit<SavedFileDetailState> {
  SavedFileDetailCubit(File file) : super(SavedFileDetailState()) {
    loadData(file);
  }

  Future<void> loadData(File file) async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await FileService.readCsvFile(file);
      emit(state.copyWith(csvData: data, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
