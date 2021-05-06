import 'package:uuid/uuid.dart';

import 'person.dart';

abstract class DataModel {
  List<DataModel> children;

  Map toJson();

  int getChildCalories() {
    int total = 0;
    children.forEach((element) {
      if (element is Person && element.desiredCalories == null) {
        total += 2000;
      } else {
        total += element.getChildCalories();
      }
    });
    return total;
  }

  void advanceDay();
}
