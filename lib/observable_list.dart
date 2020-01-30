import 'dart:async';
import 'dart:collection';

class ObservableList<T> extends ListBase<T> {
  final StreamController<List<T>> _controller = StreamController<List<T>>();
  List<T> _list = [];

  ObservableList({
    Iterable<T> initValue,
  }) {
    if (initValue != null && initValue.isNotEmpty) updateStruct(initValue);
  }

  void _notifyStructChange() {
    List<T> clone = List.of(_list);
    _controller.add(clone);
  }

  void _notifyError(dynamic error, [StackTrace stackTrace]) => _controller.addError(error, stackTrace);

  void updateStruct(List<T> list) {
    _list.clear();
    _list.addAll(list);
    _notifyStructChange();
  }

  /// Throws error manually.
  void throwError(dynamic error, [StackTrace stackTrace]) => this._notifyError(error, stackTrace);

  Stream<List<T>> get stream => _controller.stream;

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
    _notifyStructChange();
  }

  @override
  bool remove(Object element) {
    var result = _list.remove(element);
    _notifyStructChange();
    return result;
  }

  @override
  void add(T element) {
    _list.add(element);
    _notifyStructChange();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    _notifyStructChange();
  }

  @override
  void removeWhere(bool test(T element)) {
    _list.removeWhere(test);
    _notifyStructChange();
  }

  @override
  void retainWhere(bool test(T element)) {
    _list.retainWhere(test);
    _notifyStructChange();
  }

  @override
  T removeLast() {
    var result = _list.removeLast();
    _notifyStructChange();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    _notifyStructChange();
  }

  @override
  void fillRange(int start, int end, [T fill]) {
    _list.fillRange(start, end, fill);
    _notifyStructChange();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    _notifyStructChange();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    _list.replaceRange(start, end, newContents);
    _notifyStructChange();
  }

  @override
  void insert(int index, T element) {
    _list.insert(index, element);
    _notifyStructChange();
  }

  @override
  T removeAt(int index) {
    var result = _list.removeAt(index);
    _notifyStructChange();
    return result;
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _list.insertAll(index, iterable);
    _notifyStructChange();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    _list.setAll(index, iterable);
    _notifyStructChange();
  }

  @override
  void clear() {
    _list.clear();
    _notifyStructChange();
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
