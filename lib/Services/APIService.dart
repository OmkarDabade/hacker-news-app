import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hackernews/App/Constants.dart';
import 'package:hackernews/Models/Item.dart';
import 'package:http/http.dart' as http;

class APIService extends GetxService {
  // Variables to control logic
  int _lastIdCount, i;
  List _storyIds;
  Map<String, dynamic> _tempMap;
  http.Response _response;
  http.Client _client;
  List<Item> _itemList;
  Item _tempItem;

  // variables to control UI
  bool _isError;
  String _errorMessage;

  // Custom getters to control UI
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  Future<APIService> initService() async {
    _isError = false;
    _errorMessage = '';
    _client = http.Client();
    _itemList = [];

    return this;
  }

  void closeService() => _client?.close();

  Future<List<Item>> getTopStories(
      {@required int count, bool reload = false}) async {
    // initialise variables to remove previous error data
    _isError = false;
    _errorMessage = '';

    //whether user wants to forcefully reload top stories
    if (reload) {
      _lastIdCount = 0;
      try {
        // fetch items from API
        _response = await _client
            .get(Constants.fetchtopStoriesURL)
            .timeout(const Duration(seconds: 8));

        _storyIds = jsonDecode(_response.body);
      } on TimeoutException {
        _isError = true;
        _errorMessage = 'Server timedout';
        return [];
      } on SocketException {
        _isError = true;
        _errorMessage = 'There are issues with connectivity';
        return [];
      } catch (e) {
        print('APIService:' + e.toString());
        _isError = true;
        _errorMessage = 'Caught Some Error';
        return [];
      }

      for (i = 0; i < count; i++) {
        _tempItem = await _fetchItemFromAPI(id: '${_storyIds[i]}');
        if (_isError)
          break;
        else
          _itemList.add(_tempItem);
      }
      if (_isError) return [];

      // store count of previous fetched items so that next time this items will not be be fetched
      _lastIdCount = count;
      return _itemList;
    } else {
      for (i = _lastIdCount; i < _lastIdCount + count; i++) {
        _tempItem = await _fetchItemFromAPI(id: '${_storyIds[i]}');
        if (_isError)
          break;
        else
          _itemList.add(_tempItem);
      }
      if (_isError) return [];

      // store count of previous fetched items so that next time this items will not be be fetched
      _lastIdCount += count;
      return _itemList;

      // try {
      //   return Future.wait<Item>(
      //       _storyIds
      //           .skip(_lastIdCount - count)
      //           .take(count)
      //           .map((id) => _fetchItemFromAPI(id: '$id')),
      //       eagerError: true);
      // } on Error {
      //   _lastIdCount -= count;
      //   if (!_isError.value) _isError.value = true;
      //   if (_errorMessage == '') _errorMessage = 'Caught Some Error';
      //   return []
      // }
    }
  }

  Future<Item> _fetchItemFromAPI({@required String id}) async {
    try {
      _response = await _client
          .get(Constants.fetchItem(id))
          .timeout(const Duration(seconds: 8));

      // get request of url returns json object which needs to be converted from string
      _tempMap = jsonDecode(_response.body);
      return Item(
        id: _tempMap['id'],
        title: _tempMap['title'],
        url: _tempMap['url'],
        author: _tempMap['by'],
        kids: _tempMap['kids'] ?? [],
        time: _tempMap['time'],
        score: _tempMap['score'],
      );
      // Exception raised when server times out
    } on TimeoutException {
      _isError = true;
      _errorMessage = 'Server timedout';
      return null;
      // exception raised on socket exception
    } on SocketException {
      _isError = true;
      _errorMessage = 'There are issues with connectivity';
      return null;
      // return Future.error(e);
    } catch (e) {
      _isError = true;
      _errorMessage = 'Caught Some Error';
      return null;
    }
  }
}
