import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:hackernews/App/Constants.dart';
import 'package:hackernews/Controllers/StoryViewController.dart';
import 'package:hackernews/Models/Item.dart';

class StoryView extends GetView<StoryViewController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [_appBar(), _storiesList()],
        ),
        extendBody: true,
        bottomNavigationBar: _lazyLoader(context),
        floatingActionButton: _fab(),
      ),
    );
  }

  // custom appBar
  Widget _appBar() => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
            // widget to control state management
            child: GetBuilder<StoryViewController>(
              // unique id to update data
              // only specific widget's data can be updated using this id
              id: 'pageTitle',
              builder: (c) => Text(
                c.pageTitle,
                style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            height: 40.0,
            width: 40.0,
            margin: const EdgeInsets.only(right: 20.0),
            padding: const EdgeInsets.all(4.0),
            child: const Center(
              child: Text(
                'HN',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ],
      );

  // Widget to show stories in UI
  Widget _storiesList() => Expanded(
        child: GetBuilder<StoryViewController>(
            id: 'storiesList',
            builder: (c) => RefreshIndicator(
                  notificationPredicate: (notification) {
                    if (controller.pageTitle == PageTitle.topStories)
                      // refresh only when topStories page is being rendered
                      return true;
                    else
                      // if other page is being rendered then dont do anything
                      return false;
                  },
                  onRefresh: controller.reFetchStories,
                  color: Colors.green,
                  backgroundColor: Colors.white24,
                  child: controller.isLoading
                      // if data is being loaded show circular progress indicator
                      ? const Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green)),
                        )
                      // Deal with errors related to storage and favourites page
                      : (controller.isStorageError &&
                              controller.pageTitle == PageTitle.favourites)
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(
                                child: Text(controller.storageErrorMessage,
                                    style: TextStyle(fontSize: 17.0)),
                              ),
                            )
                          // Deal with errors related to history and history page
                          : (controller.pageTitle == PageTitle.history &&
                                  controller.isHistoryAvailable)
                              ? Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text(controller.noHistoryMessage,
                                        style: TextStyle(fontSize: 17.0)),
                                  ),
                                )
                              // Deal with errors related to API and topStories page
                              : (controller.isAPIServiceError &&
                                      controller.pageTitle ==
                                          PageTitle.topStories)
                                  //use scrollView so that we can refresh the content
                                  ? SingleChildScrollView(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: Container(
                                        height: Get.height - 80.0,
                                        width: Get.width,
                                        child: Center(
                                            child: Text(
                                                controller.apiErrorMessage)),
                                      ),
                                    )
                                  // display the content ie Stories
                                  : ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      controller: controller.scrollController,
                                      itemCount:
                                          controller.currentViewItems.length,
                                      itemBuilder: (c, index) => _itemCard(
                                          controller.currentViewItems[index],
                                          controller.isItemSaved(controller
                                              .currentViewItems[index].id))),
                )),
      );

  Widget _itemCard(Item item, bool isItemSaved) => InkWell(
        onTap: () {
          if (controller.pageTitle == PageTitle.topStories)
            controller.addToHistory(item);

          controller.launchURL(item.url);
        },
        child: Container(
          width: Get.width - 24.0,
          margin: EdgeInsets.all(4.0),
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                      '/${item.author} • ' + controller.timeElapsed(item.time)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 16.0),
                        softWrap: true,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      icon: isItemSaved
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.white24,
                            ),
                      onPressed: () => isItemSaved
                          ? controller.removeFromFavourites(item.id)
                          : controller.addToFavourites(item),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Spacer(),
                  _iconTab(Icons.keyboard_arrow_up, item.score),
                  _iconTab(Icons.comment_bank_outlined, item.kids.length)
                ],
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      );

  // Tabs to show on bottom right side of each card
  Widget _iconTab(IconData icon, int no) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white24,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.0,
              color: Colors.green[200],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text('$no'),
            )
          ],
        ),
      );

  // show loading indicator when new stories are being fetched
  Widget _lazyLoader(BuildContext context) => GetBuilder<StoryViewController>(
      id: 'showLazyLoader',
      builder: (c) => controller.showLazyLoading
          ? Theme(
              isMaterialAppTheme: true,
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  )),
                ),
              ),
            )
          : Offstage());

  // Custom floating action button
  Widget _fab() => SpeedDial(
        tooltip: 'Speed Dial',
        curve: Curves.bounceIn,
        shape: CircleBorder(),
        closeManually: false,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        marginBottom: 20.0,
        marginRight: 18.0,
        foregroundColor: Colors.green,
        backgroundColor: Colors.white24,
        overlayColor: Colors.black12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.fiber_new),
            label: PageTitle.topStories,
            labelBackgroundColor: Colors.black45,
            backgroundColor: Colors.green,
            onTap: controller.loadNewStories,
          ),
          SpeedDialChild(
            child: Icon(Icons.history),
            label: PageTitle.history,
            labelBackgroundColor: Colors.black45,
            backgroundColor: Colors.orange,
            onTap: controller.loadStoriesClickedByUser,
          ),
          SpeedDialChild(
            child: Icon(Icons.favorite),
            label: PageTitle.favourites,
            labelBackgroundColor: Colors.black45,
            backgroundColor: Colors.red,
            onTap: controller.loadFavourites,
          )
        ],
      );
}
