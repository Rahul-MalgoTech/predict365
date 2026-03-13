// lib/ViewModel/BookmarkSeeder.dart
//
// Shared interface so WatchlistVM can seed BookmarkVM
// without creating a circular import.

abstract class BookmarkViewModelSeeder {
  void setBookmarks(List<String> eventIds);
}