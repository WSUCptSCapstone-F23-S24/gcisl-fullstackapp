import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/post_sorting.dart';
void main() {
  test('Test sortPostList', () {
    List<Map<String, dynamic>> postList = [
  {
    "post body": "Post 1",
    "full name": "User1",
    "timestamp": "2023-01-01",
    "image": null,
    "email": "user1@email.com",
    "post id": "postId1",
    "image id": null,
    "likes": [1],
    "comments": {},
    "userType" : "student"
  },
  {
    "post body": "Post 2",
    "full name": "User2",
    "timestamp": "2023-01-02",
    "image": null,
    "email": "user2@email.com",
    "post id": "postId2",
    "image id": null,
    "likes": [1, 1],
    "comments": {},
    "userType" : "student"
  },
  {
    "post body": "Post 3",
    "full name": "User3",
    "timestamp": "2023-01-03",
    "image": null,
    "email": "user3@email.com",
    "post id": "postId3",
    "image id": null,
    "likes": [1, 1, 1],
    "comments": {},
    "userType" : "student"
  },
  {
    "post body": "Post 4",
    "full name": "User4",
    "timestamp": "2023-01-04",
    "image": null,
    "email": "user4@email.com",
    "post id": "postId4",
    "image id": null,
    "likes": [1],
    "comments": {},
    "userType" : "student"
  }
];
    

    // Test sorting by newest
    PostSorting.sortPostList(postList, PostSortOption.newest);
    expect(postList[0]["timestamp"], equals('2023-01-04')); 

    // Test sorting by oldest
    PostSorting.sortPostList(postList, PostSortOption.oldest);
    expect(postList[0]["timestamp"], equals('2023-01-01')); 

    // Test sorting alphabetically
    PostSorting.sortPostList(postList, PostSortOption.alphabetical);
    expect(postList[0]["full name"], equals('User1')); 

    PostSorting.sortPostList(postList, PostSortOption.likes);
    expect(postList[0]["full name"], equals('User3')); 



  });
}