import 'dart:math';
import 'data_model.dart';
import 'person.dart';
import 'package:uuid/uuid.dart';

import 'supermarket.dart';

class Fridge extends DataModel{
  List<Person> children;
  final Supermarket supermarket;
  int availableCalories = 0;
  final String id = Uuid().v4();

  Fridge({this.children, this.supermarket});

  Map toJson() {
    final map = {id: []};
    children.forEach((person) {
      final currentArray = map[id];
      currentArray.add(person.toJson());
    });
    return map;
  }

  void advanceDay(double ratio) {
    children.forEach((person) {
      this.availableCalories -= (person.getChildCalories() * ratio).round();
    });
  }

  void generatePeople(int numberOfPeople) {
    final List<Person> returnData = [];
    final random = Random();
    for (int i = 0; i < numberOfPeople; i++) {
      final randomValue = random.nextInt(600);
      Person person;
      if (randomValue == 300) {
        person = Person(desiredCalories: null, fridge: this);
      } else if (randomValue < 300) {
        person = Person(desiredCalories: 2000 - randomValue, fridge: this);
      } else {
        person = Person(desiredCalories: 2000 + (randomValue / 2).ceil(), fridge: this);
      }
      returnData.add(person);
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
}