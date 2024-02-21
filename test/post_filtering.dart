import 'package:test/test.dart';
import 'package:gcisl_app/helper_functions/post_filtering.dart';
void main() {
  test('Test sortPostList', () {
    List<Map<String, dynamic>> postList = [
  {
    "post body": "Hey there. This is a test. Potato",
    "full name": "User1",
    "userType" : "student"
  },
  {
    "post body": "Unique Newyork",
    "full name": "User2",
    "userType" : "student"
  },
  {
    "post body": "Potato potato",
    "full name": "User3",
    "userType" : "student"
  },
  {
    "post body": "Post 4",
    "full name": "User4",
    "userType" : "student"
  }
];
    

    // Test sorting by newest
    List newPosts = PostFiltering.filterPosts(postList, "Hey");
    expect(newPosts.length,equals(1)); 

    // Test sorting by oldest
    newPosts = PostFiltering.filterPosts(postList, "");
    expect(newPosts.length, equals(4)); 

    newPosts = PostFiltering.filterPosts(postList, "4 ");
    expect(newPosts.length, equals(1)); 

    // Test sorting alphabetically
    newPosts = PostFiltering.filterPosts(postList, "Bonchitis");
    expect(newPosts.length, equals(0)); 

    newPosts = PostFiltering.filterPosts(postList, "Potato");
    expect(newPosts.length, equals(2)); 



  });
}