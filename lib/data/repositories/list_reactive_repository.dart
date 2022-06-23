import 'package:rxdart/rxdart.dart';

abstract class ListReactiveRepository<T> {
  final updater = PublishSubject<Null>();

  Future<List<String>> getRawData();

  Future<bool> saveRawData(final List<String> items);

  T convertFromString(final String rawItem);

  String convertToString(final T item);

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
  Stream<List<T>> observeItems() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  Future<bool> addItem(final T item) async {
    final items = await getItems();
    items.add(item);
    return setItems(items);
  }

  Future<bool> removeItem(final T item) async {
    final items = await getItems();
    items.remove(item);
    return setItems(items);
  }
}
