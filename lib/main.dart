import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hackernews/App/Bindings.dart';
import 'package:hackernews/App/Routes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Models/Item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive storage and register an adapter to save custom object locally
  await Hive.initFlutter();
  Hive.registerAdapter<Item>(ItemAdapter());

  runApp(HackerNews());
}

class HackerNews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: Theme.of(context)
            .textTheme
            .apply(bodyColor: Colors.green, displayColor: Colors.green),
      ),
      initialRoute: Routes.storyView,
      getPages: Routes.routes,
      navigatorKey: Get.key,
      initialBinding: InitialBindings(),
      debugShowCheckedModeBanner: false,
    );
  }
}
