import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/post_sorting.dart';
void main() {
  test('Test sortPostList', () {
    List postList = [
      ['Post 1', 'User1', '2023-01-01', null, 'user1@email.com', 'postId1', null, [1], {}],
      ['Post 2', 'User2', '2023-01-02', null, 'user2@email.com', 'postId2', null, [1,1], {}],
      ['Post 3', 'User3', '2023-01-03', null, 'user3@email.com', 'postId3', null, [1,1,1], {}],
      ['Post 4', 'User4', '2023-01-04', null, 'user4@email.com', 'postId4', null, [1], {}],
    ];

    // Test sorting by newest
    PostSorting.sortPostList(postList, PostSortOption.newest);
    expect(postList[0][2], equals('2023-01-04')); 

    // Test sorting by oldest
    PostSorting.sortPostList(postList, PostSortOption.oldest);
    expect(postList[0][2], equals('2023-01-01')); 

    // Test sorting alphabetically
    PostSorting.sortPostList(postList, PostSortOption.alphabetical);
    expect(postList[0][1], equals('User1')); 

    PostSorting.sortPostList(postList, PostSortOption.likes);
    expect(postList[0][1], equals('User3')); 



  });
}