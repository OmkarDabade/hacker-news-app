import 'package:get/get.dart';
import 'package:hackernews/Views/StoryView.dart';

class Routes {
  static String storyView = 'story-view';

  static List<GetPage> routes = <GetPage>[
    GetPage(name: storyView, page: () => StoryView())
  ];
}
