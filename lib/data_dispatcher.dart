import 'package:flutter_databinding/databinding.dart';

/// Dispatcher for [ObservableField] that can control data value.
abstract class DataDispatcher<T> {
  /// If old value is 5 and new value is 10, call overrides(8) then value will be 8.
  void overrides(T value);

  /// If old value is 5 and new value is 10, call defaults() then value will be 10.
  void defaults();

  /// If old value is 5 and new value is 10, call ignores() then value will be 5.
  void ignores();

  /// Call throws will emit error event.
  void throws(dynamic error, [StackTrace stackTrace]);
}

enum DispatchStatus {
  overrides,
  defaults,
  ignores,
  throws,
}
