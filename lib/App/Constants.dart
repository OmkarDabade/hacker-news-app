class Constants {
  static int topStoriesCount = 10;

  // Url to fetch
  static String fetchtopStoriesURL =
      'https://hacker-news.firebaseio.com/v0/topstories.json';
  static String fetchNewStoriesURL =
      'https://hacker-news.firebaseio.com/v0/newstories.json';

  // Url to fetch specific item
  static String fetchItem(String id) =>
      'https://hacker-news.firebaseio.com/v0/item/$id.json';
}

// Page Titles
class PageTitle {
  static const String topStories = 'Top Stories';
  static const String history = 'History';
  static const String favourites = 'Favourites';
}
