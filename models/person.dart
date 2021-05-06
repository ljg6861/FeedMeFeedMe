import 'package:uuid/uuid.dart';
import 'data_model.dart';
import 'fridge.dart';

class Person extends DataModel{
  final int desiredCalories;
  final Fridge fridge;
  List<DataModel> children = null;
  final String id = Uuid().v4();

  Person({this.fridge, this.desiredCalories});

  @override
  Map toJson() {
    return {id: desiredCalories};
  }

  @override
  int getChildCalories() {
    return desiredCalories ?? 2000;
  }

  @override
  void advanceDay() {
    this.fridge.availableCalories -= desiredCalories;
  }

}
