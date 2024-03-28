class PostFiltering
{

  static bool containsWord(String text, String searchWord)
  {
    List<String> wordList = text.split(' ');
    return wordList.contains(searchWord);
  }
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
        if (containsWord(post["post body"].toLowerCase(),keyword) || containsWord(post["full name"].toLowerCase(),keyword) || containsWord(post["userType"].toLowerCase(),keyword))
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