class SavedFileDetailState {
  final List<List<dynamic>> csvData;
  final bool isLoading;

  SavedFileDetailState({
    this.csvData = const [],
    this.isLoading = false,
  });

  SavedFileDetailState copyWith({
    List<List<dynamic>>? csvData,
    bool? isLoading,
  }) {
    return SavedFileDetailState(
      csvData: csvData ?? this.csvData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
