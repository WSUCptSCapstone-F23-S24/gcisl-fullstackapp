import 'dart:collection';

enum PostSortOption { newest, oldest, alphabetical, likes }

class PostSorting {
  static void sortPostList(List<dynamic> postList, PostSortOption? sortOption) {
	switch (sortOption) {
		
		case PostSortOption.newest:
			_sortByNewest(postList);
			break;
		case PostSortOption.oldest:
			_sortByOldest(postList);
			break;
		case PostSortOption.alphabetical:
			_sortByAlphabetical(postList);
			break;
		case PostSortOption.likes:
			_sortByLikes(postList);
			break;
		default:
			_sortByNewest(postList);
			break;
	}
  }

  static void _sortByNewest(List<dynamic> postList) {
    postList.sort((a, b) => b[2].compareTo(a[2]));
  }

  static void _sortByOldest(List<dynamic> postList) {
    postList.sort((a, b) => a[2].compareTo(b[2]));
  }

  static void _sortByAlphabetical(List<dynamic> postList) {
    postList.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  }

  static void _sortByLikes(List<dynamic> postList) {
    postList.sort((a, b) => (-1 * a[7].length).compareTo(-1 * b[7].length));
  }
}