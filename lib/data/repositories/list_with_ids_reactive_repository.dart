import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

abstract class ListWithIdsReactiveRepository<T> {
  final updater = PublishSubject<Null>();

  Future<List<String>> getRawData();

  Future<bool> saveRawData(final List<String> items);

  T convertFromString(final String rawItem);

  String convertToString(final T item);

  dynamic getId(final T item);

  // from Shared Preference to List
  Future<List<T>> getItems() async {
    final rawItems = await getRawData();
    return rawItems.map((rawItem) => convertFromString(rawItem)).toList();
  }

  // List to jsonString
  Future<bool> setItems(final List<T> items) {
    final rawItems = items.map((item) => convertToString(item)).toList();
    return _setRawItems(rawItems);
  }

  // jsonString to Shared Preference
  Future<bool> _setRawItems(final List<String> rawItems) {
    updater.add(null);
    return saveRawData(rawItems);
  }

  // dynamic get List
  Stream<List<T>> observeMemes() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  Future<bool> addItems(final T item) async {
    final items = await getItems();
    items.add(item);
    return setItems(items);
  }

  Future<bool> removeItems(final T item) async {
    final items = await getItems();
    items.remove(item);
    return setItems(items);
  }

  // from Shared Preference to jsonString. Add new element to jsonString
  Future<bool> addItemOrReplaceById(final T newItem) async {
    final items = await getItems();
    final itemIndex = items.indexWhere((item) => getId(item) == getId(newItem));
    if (itemIndex == -1) {
      items.add(newItem);
    } else {
      items[itemIndex] = newItem;
    }
    return setItems(items);
  }

  // delete from list
  Future<bool> removeFromItemsById(final dynamic id) async {
    final items = await getItems();
    items.removeWhere((item) => getId(item) == id);
    return setItems(items);
  }

  // get object by id
  Future<T?> getItemById(final String id) async {
    final items = await getItems();
    return items.firstWhereOrNull((item) => getId(item) == id);
  }
}
