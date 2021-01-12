import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hackernews/App/Constants.dart';
import 'package:hackernews/Models/Item.dart';
import 'package:hackernews/Services/APIService.dart';
import 'package:hackernews/Services/StorageService.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryViewController extends GetxController {
  // Variables to control UI
  bool _isLoading, _showLazyLoading;

  // Services
  APIService _apiService = Get.find<APIService>();
  StorageService _storageService = Get.find<StorageService>();

  // Custom getters to control UI
  bool get showLazyLoading => _showLazyLoading;
  bool get isLoading => _isLoading || _storageService.isLoading;

  bool get isHistoryAvailable => _historyItems.isEmpty;
  bool get isStorageError => _storageService.isError;
  bool get isAPIServiceError => _apiService.isError;

  String get storageErrorMessage => _storageService.errorMessage;
  String get apiErrorMessage => _apiService.errorMessage;

  String get noHistoryMessage =>
      'No websites visited by you\nPlease visit few websites then check history in this page.';

  // Variables to control Logic
  String _pageTitle;
  int maxLoadCount = 0;
  List<Item> _currentViewItems, _historyItems, _tempItems;
  double lastScrollExtent = 0.0;
  Duration _tempDuration;
  ScrollController scrollController = ScrollController();

  // Custom getters to access data and code logic
  List<Item> get currentViewItems => _currentViewItems;
  String get pageTitle => _pageTitle;
  int get historyItemsLength => _historyItems.length ?? 0;

  // Called when controller is initialised
  @override
  void onInit() async {
    // Initialise UI controlling variables
    _isLoading = true;
    _showLazyLoading = false;

    _historyItems = [];
    _pageTitle = PageTitle.topStories;

    // Update specific widgets in UI by passing id's
    update(['pageTitle', 'storiesList']);

    // Load top stories when app is started
    await _loadTopStories(reloadCompletely: true);

    if (_currentViewItems != null) _isLoading = false;
    update(['pageTitle', 'storiesList']);

    // Add listener to scroll controller to load new stories when reached at last item in list
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          _pageTitle == PageTitle.topStories) {
        // load more stories when reached to bottom of screen
        _showLazyLoading = true;
        lastScrollExtent = scrollController.position.pixels;
        update(['showLazyLoader']);

        await _loadTopStories();

        if (_apiService.isError) {
          _showLazyLoading = false;
          update(['showLazyLoader']);

          Get.showSnackbar(GetBar(
            title: 'Error',
            message: _apiService.errorMessage,
            margin: EdgeInsets.all(15.0),
            duration: const Duration(seconds: 2),
            borderRadius: 15.0,
          ));
        } else {
          _showLazyLoading = false;
          update(['storiesList', 'showLazyLoader']);
        }

        scrollController.jumpTo(lastScrollExtent);
      }
    });
    super.onInit();
  }

  Future<void> closeServices() async {
    // Close services when app is closed
    await _storageService.closeService();
    _apiService.closeService();
  }

  // Reload new stories
  Future<void> reFetchStories() async {
    _currentViewItems = await _apiService.getTopStories(
        count: Constants.topStoriesCount, reload: true);

    if (_apiService.isError) {
      Get.showSnackbar(GetBar(
        title: 'Error',
        message: _apiService.errorMessage,
        margin: EdgeInsets.all(15.0),
        duration: const Duration(seconds: 2),
        borderRadius: 15.0,
      ));
    } else {
      _tempItems = _currentViewItems;
      update(['storiesList']);
    }
  }

  // open url in Webview/Browser of mobile
  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void loadStoriesClickedByUser() {
    _pageTitle = PageTitle.history;
    _currentViewItems = _historyItems;
    update(['pageTitle', 'storiesList']);
  }

  void loadFavourites() {
    _pageTitle = PageTitle.favourites;
    _currentViewItems = _storageService.itemList;
    update(['pageTitle', 'storiesList']);
  }

  void loadTempItems() async {
    _isLoading = true;

    _pageTitle = PageTitle.topStories;
    update(['pageTitle', 'storiesList']);

    _currentViewItems = _tempItems;

    if (_currentViewItems != null) _isLoading = false;
    update(['storiesList']);
  }

  void addToHistory(Item item) => _historyItems.add(item);

  Future<void> _loadTopStories({bool reloadCompletely = false}) async {
    if (reloadCompletely)
      _tempItems = _currentViewItems = await _apiService.getTopStories(
          count: Constants.topStoriesCount, reload: reloadCompletely);
    else
      _tempItems = _currentViewItems = _currentViewItems
          .followedBy(
              await _apiService.getTopStories(count: Constants.topStoriesCount))
          .map<Item>((e) => e)
          .toList();
  }

  void addToFavourites(Item item) async {
    await _storageService.saveItem(item);
    update(['storiesList']);
  }

  void removeFromFavourites(int id) async {
    await _storageService.deleteItem(id);
    update(['storiesList']);
  }

  bool isItemSaved(int id) => _storageService.isItemSaved(id);

  String timeElapsed(int unixTime) {
    _tempDuration = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    if (_tempDuration.inMinutes < 60)
      return '${_tempDuration.inMinutes}m';
    else if (_tempDuration.inHours < 23)
      return '${_tempDuration.inHours}h';
    else
      return '${_tempDuration.inDays}d';
  }
}
