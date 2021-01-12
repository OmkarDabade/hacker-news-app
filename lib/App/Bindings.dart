import 'package:get/get.dart';
import 'package:hackernews/Controllers/StoryViewController.dart';
import 'package:hackernews/Services/APIService.dart';
import 'package:hackernews/Services/StorageService.dart';

// To inject an Instances in memory upon builder() callback.
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Creates a new Instance lazily from the builder() callback.
    Get.lazyPut<StoryViewController>(() => StoryViewController());
  }
}

Future<void> initServices() async {
  //Injects an Instance of service in memory.
  await Get.putAsync<APIService>(() async => await APIService().initService());
  await Get.putAsync<StorageService>(
      () async => StorageService().initService());
}
