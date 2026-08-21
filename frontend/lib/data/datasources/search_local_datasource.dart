import '../../core/storage/hive_service.dart';

class SearchLocalDataSource {
  static const _searchKey = 'recent_searches';

  List<String> loadSearches() {
    final searches = HiveService.searchBox.get(_searchKey) as List?;
    return searches?.cast<String>() ?? [];
  }

  Future<void> saveSearches(List<String> searches) async {
    await HiveService.searchBox.put(_searchKey, searches);
  }
}
