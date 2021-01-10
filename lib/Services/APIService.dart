import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hackernews/App/Constants.dart';
import 'package:hackernews/Models/Item.dart';
import 'package:http/http.dart' as http;

class APIService extends GetxService {
  // Variables to control logic
  int _lastIdCount;
  Iterable _storyIds;
  http.Response _response;

  // variables to control UI
  bool _isError;
  String _errorMessage;

  // Custom getters to control UI
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  // Called when service is put in memory for first time
  @override
  void onInit() {
    _isError = false;
    _errorMessage = '';
    super.onInit();
  }

  Future<List<Item>> getTopStories(
      {@required int count, bool reload = false}) async {
    // initialise variables to remove previous error data
    _isError = false;
    _errorMessage = '';

    // whether user wants to forcefully reload top stories
    if (reload) {
      _lastIdCount = 0;
      try {
        // fetch items from internet
        _response = await http.get(Constants.fetchtopStoriesURL);
      } on SocketException {
        _isError = true;
        _errorMessage = 'There are issues with connectivity';
        return [];
      } catch (e) {
        _isError = true;
        _errorMessage = 'Caught Some Error';
        return [];
      }

      // store count of previous fetched items so that next time this items will not be be fetched
      _lastIdCount = count;
      try {
        return Future.wait<Item>(
            _storyIds.take(count).map((id) => _fetchItemFromAPI(id: '$id')),
            eagerError: true);
      } on Error catch (e) {
        _isError = true;
        _errorMessage = 'Caught Some Error';
        return Future.error(e);
      }
    } else {
      // add this items to previously fetched items and increase count value
      _lastIdCount += count;
      try {
        return Future.wait<Item>(
            _storyIds
                .skip(_lastIdCount - count)
                .take(count)
                .map((id) => _fetchItemFromAPI(id: '$id')),
            eagerError: true);
      } on Error catch (e) {
        _isError = true;
        _errorMessage = 'Caught Some Error';
        return Future.error(e);
      }
    }
  }

  Future<Item> _fetchItemFromAPI({@required String id}) async {
    try {
      _response = await http.get(Constants.fetchItem(id));

      // get request of url returns json object which needs to be converted from string
      Map<String, dynamic> item = jsonDecode(_response.body);
      return Item(
        id: item['id'],
        title: item['title'],
        url: item['url'],
        author: item['by'],
        kids: item['kids'] ?? [],
        time: item['time'],
        score: item['score'],
      );
    } on SocketException catch (e) {
      _isError = true;
      _errorMessage = 'There are issues with connectivity';
      return Future.error(e);
    } catch (e) {
      _isError = true;
      _errorMessage = 'Caught Some Error';
      return Future.error(e);
    }
  }
}
