import 'dart:async';
import 'dart:collection';

class ObservableList<T> extends ListBase<T> {
  final StreamController<List<T>> _controller = StreamController<List<T>>();
  List<T> _list = [];
  Stream<List<T>> _broadcastCache;

  ObservableList({
    Iterable<T> initValue,
  }) {
    if (initValue != null && initValue.isNotEmpty) updateStruct(initValue);
  }

  void _notifyError(dynamic error, [StackTrace stackTrace]) => _controller.addError(error, stackTrace);

  /// Trigger stream with current list struct.
  void notifyStructChange() {
    List<T> clone = List.of(_list);
    _controller.add(clone);
  }

  /// Replace elements with a new list.
  void updateStruct(List<T> list) {
    _list.clear();
    _list.addAll(list);
    notifyStructChange();
  }

  /// Throws error manually.
  void throwError(dynamic error, [StackTrace stackTrace]) => this._notifyError(error, stackTrace);

  /// Stream of list.
  Stream<List<T>> get stream => _controller.stream;

  /// Get broadcast stream of [ObservableField].
  Stream<List<T>> get broadcastStream {
    if (_broadcastCache == null) _broadcastCache = stream.asBroadcastStream();
    return _broadcastCache;
  }

  /// Close stream controller.
  Future<void> close() async {
    await _controller.close();
  }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    notifyStructChange();
  }

  @override
  bool remove(Object element) {
    var result = _list.remove(element);
    notifyStructChange();
    return result;
  }

  @override
  void add(T element) {
    _list.add(element);
    notifyStructChange();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    notifyStructChange();
  }

  @override
  void removeWhere(bool test(T element)) {
    _list.removeWhere(test);
    notifyStructChange();
  }

  @override
  void retainWhere(bool test(T element)) {
    _list.retainWhere(test);
    notifyStructChange();
  }

  @override
  T removeLast() {
    var result = _list.removeLast();
    notifyStructChange();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    notifyStructChange();
  }

  @override
  void fillRange(int start, int end, [T fill]) {
    _list.fillRange(start, end, fill);
    notifyStructChange();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    notifyStructChange();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    _list.replaceRange(start, end, newContents);
    notifyStructChange();
  }

  @override
  void insert(int index, T element) {
    _list.insert(index, element);
    notifyStructChange();
  }

  @override
  T removeAt(int index) {
    var result = _list.removeAt(index);
    notifyStructChange();
    return result;
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _list.insertAll(index, iterable);
    notifyStructChange();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    _list.setAll(index, iterable);
    notifyStructChange();
  }

  @override
  void clear() {
    _list.clear();
    notifyStructChange();
  }
}

/// Wrapped [ObservableList] for [int].
class ObservableIntList extends ObservableList<int> {
  ObservableIntList({
    Iterable<int> initValue,
  }) : super(
          initValue: initValue,
        );
}

/// Wrapped [ObservableList] for [double].
class ObservableDoubleList extends ObservableList<double> {
  ObservableDoubleList({
    Iterable<double> initValue,
  }) : super(
          initValue: initValue,
        );
}

/// Wrapped [ObservableList] for [bool].
class ObservableBoolList extends ObservableList<bool> {
  ObservableBoolList({
    Iterable<bool> initValue,
  }) : super(
          initValue: initValue,
        );
}

/// Wrapped [ObservableList] for [String].
class ObservableStringList extends ObservableList<String> {
  ObservableStringList({
    Iterable<String> initValue,
  }) : super(
          initValue: initValue,
        );
}
