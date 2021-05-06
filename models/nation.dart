import 'dart:convert';
import 'dart:io';

import 'city.dart';
import 'data_model.dart';
import 'package:uuid/uuid.dart';

class Nation{
  final List<City> children;
  final String id = Uuid().v4();

  Nation({this.children});

  Map toJson() {
    final map = {id: []};
    children.forEach((city) {
      final currentArray = map[id];
      currentArray.add(city.toJson());
    });
    return map;
  }

  void recordDataToFile(String filename){
    File file = File(filename);
    file.delete();
    file.create();
    file.writeAsStringSync(jsonEncode(this.toJson()));
  }

  void advanceDay(int foodProducedYesterday) {
    
  }

  int getChildCalories() {
    int total = 0;
    children.forEach((element) {
      total += element.getChildCalories();
    });
    return total;
  }
}