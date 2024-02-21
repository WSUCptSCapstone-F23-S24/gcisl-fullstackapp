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
    postList.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
  }

  static void _sortByOldest(List<dynamic> postList) {
    postList.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));
  }

  static void _sortByAlphabetical(List<dynamic> postList) {
    postList.sort((a, b) => (a["post body"] as String).compareTo(b["post body"] as String));
  }

  static void _sortByLikes(List<dynamic> postList) {
    postList.sort((a, b) => (-1 * a["likes"].length).compareTo(-1 * b["likes"].length));
  }
}