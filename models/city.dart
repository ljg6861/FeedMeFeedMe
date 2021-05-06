import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'data_model.dart';
import 'person.dart';
import 'supermarket.dart';

class City{
  final List<Supermarket> children;
  int availableFood = 0;
  final String id = Uuid().v4();

  int get neededCalories{
    return this.getChildCalories();
  }

  int get totalCaloriesInSupermarkets{
    int total = 0;
    children.forEach((supermarket) {
      total += supermarket.availableCalories;
    });
    return total;
  }

  City({this.children});

  Map toJson() {
    final map = {id: []};
    children.forEach((supermarket) {
      final currentArray = map[id];
      currentArray.add(supermarket.toJson());
    });
    return map;
  }

  void advanceDay() {
    var totalPeople = getNumberOfPeopleDependent();
    children.forEach((supermarket) {
      var numberPerMarket = supermarket.getNumberOfPeopleDependent();
      var foodToGive = (availableFood*(numberPerMarket/totalPeople)).round();
      supermarket.availableCalories += foodToGive;
      availableFood -= foodToGive;
    });
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
      total += fridge.getNumberOfPeopleDependent();
    });
    return total;
  }
}