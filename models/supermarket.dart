import 'dart:math';
import 'package:uuid/uuid.dart';
import 'data_model.dart';
import 'fridge.dart';

class Supermarket extends DataModel{
  List<Fridge> children;
  int availableCalories = 0;
  int daysToRation = 5;
  final String id = Uuid().v4();

  int neededCalories(double ratio)=>this.getChildCalories(ratio) * (daysToRation);

  int dailyNeededCalories(ratio) => this.getChildCalories(ratio);

  Supermarket({this.children});

  Map toJson() {
    final map = {id: []};
    children.forEach((family) {
      final currentArray = map[id];
      currentArray.add(family.toJson());
    });
    return map;
  }

  void advanceDay(double ratio) {
    children.forEach((fridge) {
      fridge.availableCalories += (fridge.getChildCalories(ratio)).round();
      this.availableCalories -= (fridge.getChildCalories(ratio)).round();
      fridge.advanceDay(ratio);
    });
  }

  void generateFamilies() {
    final random = Random();
    final numberOfFamilies = 250 + random.nextInt(250).ceil();
    final List<Fridge> returnData = [];
    if (numberOfFamilies < 50) {
      this.generateFamilies();
      return;
    }
    for (int i = 0; i < numberOfFamilies; i++) {
      var num = random.nextInt(6).ceil();
      if (num == 0) {
        num = 1;
      }
      Fridge fridge = Fridge();
      fridge.generatePeople(num);
      returnData.add(fridge);
    }
    this.children = returnData;
  }

  int getChildCalories(double ratio) {
    int total = 0;
    children.forEach((element) {
      total += element.getChildCalories(ratio);
    });
    return total;
  }

  int getNumberOfPeopleDependent(){
    int total = 0;
    children.forEach((fridge) {
      total += fridge.children.length;
    });
    return total;
  }
}