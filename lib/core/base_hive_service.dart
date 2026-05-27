import 'package:hive/hive.dart';

abstract class BaseHiveService<T> {
  final String _boxName;

  BaseHiveService(String boxName) : _boxName = boxName;

  Box get _box => Hive.box(_boxName);

  T? get(String key) => _box.get(key) as T?;

  Future<void> put(String key, T value) async {
    await _box.put(key, value);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  List<E> getTypedList<E>(String key) {
    final value = _box.get(key);
    if (value == null) return <E>[];
    if (value is List) return value.cast<E>();
    return <E>[];
  }
}
