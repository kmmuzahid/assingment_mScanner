import 'dart:io';

class SavedFilesState {
  final List<File> files;
  final bool isLoading;

  SavedFilesState({
    this.files = const [],
    this.isLoading = false,
  });

  SavedFilesState copyWith({
    List<File>? files,
    bool? isLoading,
  }) {
    return SavedFilesState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
