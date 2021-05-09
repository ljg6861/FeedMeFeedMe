import 'package:uuid/uuid.dart';

import 'person.dart';

abstract class DataModel {
  int daysToRation = 5;

  int getChildCalories(double ratio);

}
