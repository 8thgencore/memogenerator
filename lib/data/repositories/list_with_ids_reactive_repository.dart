import 'package:memogenerator/data/repositories/list_reactive_repository.dart';
import 'package:collection/collection.dart';

abstract class ListWithIdsReactiveRepository<T> extends ListReactiveRepository<T> {
  dynamic getId(final T item);

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
