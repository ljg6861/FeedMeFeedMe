import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';

import 'data_generator.dart';
import 'models/nation.dart';

void main() {
  var nation = setupEnvironment();
  beginSimulation(28, nation);
}

void beginSimulation(int daysToRun, Nation nation){
  //days to iterate (1 month)
  List<List<dynamic>> csvData = [['city', 'daily food production', 'daily food needs', 'current ration', 'current surplus of food', 'max survivable days', 'day']];
  for (int i = 0; i < daysToRun; i++) {
    print('starting day: ' + (i + 1).toString());
    nation.advanceDay();
    nation.children.forEach((city) {
      var collectedCityData = <dynamic>[city.id];
      var random = Random();
      int totalCalories = city.getChildCalories(1);
      if (i <= 5) { //First five days, give more than enough food with little variability
        city.dailyFoodProduction = (((totalCalories - (totalCalories * 0.15)) + random.nextInt((totalCalories * 0.5).round())).round());
      }
      else if (i > 5 && i <= 12) { //Indicate the start of a potential famine
        city.dailyFoodProduction = (((totalCalories - (totalCalories * 0.35)) + random.nextInt((totalCalories * 0.5).round())).round());
      }
      else if (i > 12 && i <= 24) { //Start a famine
        city.dailyFoodProduction = (((totalCalories - (totalCalories * 0.8)) + random.nextInt((totalCalories * 0.5).round())).round());
      }
      else{ //return to normal
        city.dailyFoodProduction = (((totalCalories - (totalCalories * 0.15)) + random.nextInt((totalCalories * 0.5).round())).round());
      }
      collectedCityData.add(city.dailyFoodProduction / 10000000);
      collectedCityData.add((city.neededCalories / city.daysToRation) / 10000000);
      collectedCityData.add(city.currentRatio);
      collectedCityData.add(city.surplusFood / 10000000);
      //calculate max survivable days
      var currentFood = city.surplusFood + city.totalCaloriesInSupermarkets;
      var totalDays = -1;
      while (currentFood > 0){
        currentFood -= (city.neededCalories / (city.daysToRation - 1)).round();
        currentFood += city.dailyFoodProduction;
        if (currentFood > 0)
          totalDays += 1;
        if (totalDays > 1000){
          break;
        }
      }
      collectedCityData.add(totalDays);
      collectedCityData.add(i + 1);
      csvData.add(collectedCityData);
    });
  }
  var input = new File('output.csv');
  input.delete();
  input.create();
  String csv = ListToCsvConverter().convert(csvData);
  input.writeAsStringSync(csv);
}

Nation setupEnvironment() {
  var nation = generateData();
  int totalCaloriesRequired = nation.getChildCalories(1);
  print('Total calories required in nation: ' + totalCaloriesRequired.toString());
  print('\nTotal amount of cities in nation: ' + nation.children.length.toString());
  print('\n');
  for (int i = 0; i < nation.children.length; i++) {
    print('Total number of supermarkets in city ' + (i + 1).toString() + ': ' + nation.children[i].supermarkets.length.toString());
    for (int j = 0; j < nation.children[i].supermarkets.length; j++) {
      print('Total number of families in supermarket ' + (j + 1).toString() + ' in city ' + (i + 1).toString() + ': ' + nation.children[i].supermarkets[j].children.length.toString());
    }
    print('\n');
  }
  print('Giving each City enough food for 5 days');
  nation.children.forEach((city) {
    var random = Random();
    int totalCalories = city.getChildCalories(1);
    city.surplusFood += totalCalories;
    city.dailyFoodProduction = ((totalCalories - (totalCalories * 0.3) + random.nextInt((totalCalories * 0.5).round())).round());
    city.supermarkets.forEach((element) {
      int totalCalories = element.neededCalories(1);
      element.availableCalories += totalCalories;
    });
    city.advanceDay(5);
  });
  return nation;
}

Nation generateData() {
  DataGenerator dataGenerator = DataGenerator();
  Nation nation = dataGenerator.generateData(5);
  nation.recordDataToFile('initial_national_data.json');
  return nation;
}
