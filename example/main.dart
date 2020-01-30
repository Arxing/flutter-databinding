import 'package:flutter_databinding/databinding.dart';

void main() async {
  /// Create instance of ObservableField
  ObservableInt timemillsField = ObservableInt(initValue: DateTime.now().millisecondsSinceEpoch);
  ObservableField<String> timestringField = ObservableField<String>();

  /// Observes field's stream
  timemillsField.stream.listen((mills) {
    print("mills: $mills");
  }, onError: (error) {
    print("mills error: $error");
  });
  timestringField.stream.listen((timestring) {
    print("timestring: $timestring");
  }, onError: (error) {
    print("timestring error: $error");
  });

  /// Linking and synchronizing
  String Function(int) transformer = (int timemills) {
    return DateTime.fromMillisecondsSinceEpoch(timemills).toString();
  };
  int Function(String) restorer = (String timeString) {
    return DateTime.parse(timeString).millisecondsSinceEpoch;
  };

  /// Use instance method
  timemillsField.linksTo(timestringField, transformer: transformer, restorer: restorer);

  /// Use static method
  ObservableField.link(timemillsField, timestringField, transformer: transformer, restorer: restorer);

  /// Getter
  var nowMills = timemillsField.get();
  nowMills = timemillsField.value;

  /// Setter
  timemillsField.set(nowMills + 60 * 1000);
  timemillsField.value = nowMills + 60 * 1000;

  /// Error handling
  timemillsField.throwError("An Error");
  timestringField.error = "An Error2";

  /// Field mapping
  var timeStringField2 = timemillsField.map(transformer: transformer, restorer: restorer);
  timeStringField2.stream.listen((timeString) {
    print("timeString2: $timeString");
  }, onError: (error) {
    print("timeString2 error: $error");
  });
  timemillsField.value = DateTime.parse("2020-01-01 00:00:00").millisecondsSinceEpoch;

  /// Create instance of ObservableList
  ObservableStringList stringsField = ObservableStringList();
  stringsField.stream.listen((list) {
    print("list: $list");
  }, onError: (error) {
    print("list error: $error");
  });
  stringsField.add("Apple");
  stringsField.add("Banana");
  stringsField.clear();
  stringsField.removeAt(0);
}
