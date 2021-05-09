import 'package:uuid/uuid.dart';
import 'data_model.dart';
import 'fridge.dart';

class Person{
  final int desiredCalories;
  final Fridge fridge;
  List<DataModel> children = null;
  final String id = Uuid().v4();

  Person({this.fridge, this.desiredCalories});

  Map toJson() {
    return {id: desiredCalories};
  }

  int getChildCalories(ratio) {
    if ((desiredCalories ?? 2000) * ratio < 1500){
      return 1500;
    }
    return ((desiredCalories ?? 2000) * ratio).round();
  }

}
