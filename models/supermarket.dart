import 'dart:math';
import 'package:uuid/uuid.dart';
import 'fridge.dart';

class Supermarket{
  List<Fridge> children;
  int availableCalories = 0;
  final String id = Uuid().v4();

  Supermarket({this.children});

  Map toJson() {
    final map = {id: []};
    children.forEach((family) {
      final currentArray = map[id];
      currentArray.add(family.toJson());
    });
    return map;
  }

  void advanceDay() {
    if (availableCalories > getChildCalories()){
      children.forEach((fridge) {
        var desiredCalories = fridge.getChildCalories();
        fridge.availableCalories += desiredCalories;
        availableCalories -= desiredCalories;
      });
    } else{
      var totalPeople = getNumberOfPeopleDependent();
      children.forEach((fridge) {
        var totalCaloriesToGive = ((availableCalories/totalPeople)* fridge.children.length).floor();
        fridge.availableCalories += totalCaloriesToGive;
        availableCalories -= totalCaloriesToGive;
      });
    }
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

  int getChildCalories() {
    int total = 0;
    children.forEach((element) {
      total += element.getChildCalories();
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