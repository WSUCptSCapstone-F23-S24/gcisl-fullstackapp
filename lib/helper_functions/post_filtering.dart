class PostFiltering
{
  static List<dynamic> filterPosts(List<dynamic> postList, String? searchBar) 
  {
    List<dynamic> returnList = [];

    if (searchBar == null || searchBar.isEmpty) 
    {
      return postList;
    } 
    
    List<String> keywords = searchBar.toLowerCase().split(' ');

    for (Map post in postList) 
    {
      bool matchFound = false;

      for (String keyword in keywords) 
      {
        if(keyword == " " || keyword == "\n" || keyword == "")
        {
          continue;
        }
        if (post["post body"].toLowerCase().contains(keyword) == true || post["full name"].toLowerCase().contains(keyword) == true || post["userType"].toLowerCase().contains(keyword) == true) 
        {
          matchFound = true;
          break; 
        }
      }
      if (matchFound) 
      {
        returnList.add(post);
      }
    }

    return returnList;
  }

}