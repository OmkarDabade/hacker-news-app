import 'package:get/get.dart';
import 'package:hackernews/Controllers/StoryViewController.dart';
import 'package:hackernews/Services/APIService.dart';
import 'package:hackernews/Services/StorageService.dart';

// To inject an Instances in memory upon builder() callback.
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    //Injects an Instance in memory.
    Get.put<APIService>(APIService(), permanent: true);
    Get.put<StorageService>(StorageService(), permanent: true);

    // Creates a new Instance lazily from the builder() callback.
    Get.lazyPut<StoryViewController>(() => StoryViewController());
  }
}
