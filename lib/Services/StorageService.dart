import 'package:get/get.dart';
import 'package:hackernews/Models/Item.dart';
import 'package:hive/hive.dart';

class StorageService extends GetxService {
  // variables to control logic flow
  Box<Item> _storageBox;
  List<Item> _itemList;

  // custom getters to fetch logic variables
  List<Item> get itemList => _itemList;

  // control UI
  bool _isLoaded;
  RxBool _isLoading = RxBool(false), _isError = RxBool(false);
  String _errorMessage = '';

  //custom getters for UI components
  bool get isLoading => _isLoading.value;
  bool get isError => _isError.value;
  String get errorMessage => _errorMessage;

  Future<StorageService> initService() async {
    _isLoaded = false;
    _isError.value = false;
    _errorMessage = '';
    _isLoaded = false;

    await loadItems();
    return this;
  }

  Future<void> closeService() async => await _storageBox?.close();

  bool isItemSaved(int key) =>
      _storageBox != null ? _storageBox.containsKey(key) : false;

  // load items from Hive box which is stored locally to device
  Future<void> loadItems() async {
    _isError.value = false;
    _errorMessage = '';

    // if data is already loaded then return and dont load box again
    if (_isLoaded) return;
    _isLoading.value = true;

    // if data is not loaded then load data
    try {
      _storageBox = await Hive.openBox<Item>('storageBox');
      _itemList = <Item>[];

      if (_storageBox.isNotEmpty) {
        _itemList.addAll(_storageBox.values);
        _isLoaded = true;
        _isError.value = false;
        _isLoading.value = false;
        _errorMessage = '';
      } else {
        print('Box is Empty');

        _isLoaded = false;
        _errorMessage =
            'No favourites set\nPlease select your favourite url in Top Stories';
        _isError.value = true;
      }
    } catch (e) {
      _errorMessage = 'Failed to load urls from device';
      _isError.value = true;
      _isLoading.value = false;
    }
    _isLoading.value = false;
  }

  // put item in box and save it permanantly to device
  Future<void> saveItem(Item item) async {
    if (isItemSaved(item.id))
      return;
    else {
      if (_storageBox.isEmpty) {
        _errorMessage = '';
        _isError.value = false;
      }
      await _storageBox.put(item.id, item);
      _itemList.add(item);
    }
  }

  //delete item from device
  Future<void> deleteItem(int id) async {
    if (!isItemSaved(id))
      return;
    else {
      _itemList.removeWhere((element) => element.id == id);
      await _storageBox.delete(id);

      if (_storageBox.isEmpty) {
        _errorMessage =
            'No favourites set\nPlease select your favourite url in Top Stories';
        _isError.value = false;
      }
    }
  }
}
