import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_databinding/databinding.dart';

typedef DataDispatchCallback<T> = void Function(T data, DataDispatcher<T> dispatcher);
typedef ValueChanged<T> = void Function(T value);
typedef Transformer<T, R> = R Function(T src);

class ObservableField<T> {
  final StreamController<T> _controller = StreamController<T>();
  T _value;
  DataDispatchCallback<T> _setterCallback;
  Stream<T> _broadcastCache;
  ValueChanged<T> _valueChanged;
  bool _changeFromLinked = false;
  ObservableField _linked;
  T _initValue;

  ObservableField({
    T initValue,
    DataDispatchCallback<T> setterCallback,
  }) {
    _setterCallback = setterCallback;
    this._initValue = initValue;
    if (initValue != null) set(initValue);
  }

  void _emitValue(T value) {
    this._value = value;
    _controller.add(value);
    if (_valueChanged != null) _valueChanged(value);
  }

  void _emitError(dynamic error, [StackTrace stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  /// Set value of [ObservableField], if has set [DataDispatchCallback] then it will trigger and you can control final value.
  void set(T value) {
    if (_setterCallback != null) {
      var dispatcher = _DefaultDataDispatcher<T>();
      _setterCallback(value, dispatcher);
      if (dispatcher.hasDispatched) {
        if (dispatcher.hasError) {
          Object error = dispatcher._error;
          StackTrace stackTrace = dispatcher._stackTrace;
          _emitError(error, stackTrace);
        } else {
          T product = dispatcher.produce(this.value, value);
          _emitValue(product);
        }
      } else {
        _emitError("UndispatchError");
      }
    } else {
      _emitValue(value);
    }
  }

  /// Get value of [ObservableField].
  T get() => _value;

  set setterCallback(DataDispatchCallback<T> value) => _setterCallback = value;

  /// Throws error manually.
  void throwError(dynamic error, [StackTrace stackTrace]) => _emitError(error, stackTrace);

  /// Same as void throwError().
  set error(dynamic error) => this.throwError(error);

  /// Same as void set().
  set value(T value) => this.set(value);

  /// Same as T get().
  T get value => this.get();

  /// Get stream of [ObservableField].
  Stream<T> get stream => _controller.stream;

  /// Get broadcast stream of [ObservableField].
  Stream<T> get broadcastStream {
    if (_broadcastCache == null) _broadcastCache = stream.asBroadcastStream();
    return _broadcastCache;
  }

  /// Close stream controller.
  Future<void> close() async => await _controller.close();

  /// Links to other [ObservableField] and synchronize both their values by transformer/restorer.
  static void link<T, R>(
    ObservableField<T> self,
    ObservableField<R> other, {
    @required Transformer<T, R> transformer,
    @required Transformer<R, T> restorer,
  }) {
    self._linked = other;
    other._linked = self;
    self._valueChanged = (value) {
      if (self._changeFromLinked) {
        self._changeFromLinked = false;
        return;
      }
      R transform = transformer(value);
      other._changeFromLinked = true;
      other.set(transform);
    };
    other._valueChanged = (value) {
      if (other._changeFromLinked) {
        other._changeFromLinked = false;
        return;
      }
      T restore = restorer(value);
      self._changeFromLinked = true;
      self.set(restore);
    };
  }

  /// Links to other [ObservableField] and synchronize both their values by transformer/restorer.
  void linksTo<R>(
    ObservableField<R> other, {
    @required Transformer<T, R> transformer,
    @required Transformer<R, T> restorer,
  }) =>
      link(this, other, transformer: transformer, restorer: restorer);

  /// Unlinks.
  void unlink() {
    _valueChanged = null;
    _linked?._valueChanged = null;
  }

  /// Links to a new [ObservableField] and synchronize both their values by transformer/restorer.
  ObservableField<R> map<R>({
    @required Transformer<T, R> transformer,
    @required Transformer<R, T> restorer,
  }) {
    ObservableField<R> result;
    if (_initValue != null) {
      R newInitValue = transformer(this._initValue);
      result = ObservableField(initValue: newInitValue);
    } else {
      result = ObservableField();
    }
    link(this, result, transformer: transformer, restorer: restorer);
    return result;
  }
}

/// Wrapped [ObservableField] for [int].
class ObservableInt extends ObservableField<int> {
  ObservableInt({
    int initValue,
    DataDispatchCallback<int> setterCallback,
  }) : super(
          initValue: initValue,
          setterCallback: setterCallback,
        );
}

/// Wrapped [ObservableField] for [double].
class ObservableDouble extends ObservableField<double> {
  ObservableDouble({
    double initValue,
    DataDispatchCallback<double> setterCallback,
  }) : super(
          initValue: initValue,
          setterCallback: setterCallback,
        );
}

/// Wrapped [ObservableField] for [bool].
class ObservableBool extends ObservableField<bool> {
  ObservableBool({
    bool initValue,
    DataDispatchCallback<bool> setterCallback,
  }) : super(
          initValue: initValue,
          setterCallback: setterCallback,
        );
}

/// Wrapped [ObservableField] for [String].
class ObservableString extends ObservableField<String> {
  ObservableString({
    String initValue,
    DataDispatchCallback<String> setterCallback,
  }) : super(
          initValue: initValue,
          setterCallback: setterCallback,
        );
}

/// Wrapped [ObservableField] for [DateTime].
class ObservableDateTime extends ObservableField<DateTime> {
  ObservableDateTime({
    DateTime initValue,
    DataDispatchCallback<DateTime> setterCallback,
  }) : super(
          initValue: initValue,
          setterCallback: setterCallback,
        );
}

class _DefaultDataDispatcher<T> implements DataDispatcher<T> {
  T _overridesValue;
  dynamic _error;
  StackTrace _stackTrace;
  DispatchStatus _status;

  bool get hasError => _status == DispatchStatus.throws;

  bool get hasDispatched => _status != null;

  @override
  void defaults() {
    _status = DispatchStatus.defaults;
  }

  @override
  void ignores() {
    _status = DispatchStatus.ignores;
  }

  @override
  void overrides(T value) {
    _status = DispatchStatus.overrides;
    _overridesValue = value;
  }

  @override
  void throws(dynamic error, [StackTrace stackTrace]) {
    _status = DispatchStatus.throws;
    _error = error;
    _stackTrace = stackTrace;
  }

  T produce(T oldValue, T newValue) {
    switch (_status) {
      case DispatchStatus.overrides:
        return _overridesValue;
      case DispatchStatus.defaults:
        return newValue;
      case DispatchStatus.ignores:
        return oldValue;
      case DispatchStatus.throws:
        break;
    }
    return null;
  }
}
