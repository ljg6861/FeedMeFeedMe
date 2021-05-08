import 'data_generator.dart';
import 'models/nation.dart';

void main() {
  var nation = setupEnvironment();
  for (int i = 0; i < 10; i++) {
    nation.advanceDay();
    nation.children.forEach((element) {
      print('surplus: ' + element.surplusFood.toString());
    });
  }
}

Nation setupEnvironment() {
  var nation = generateData();
  int totalCaloriesRequired = nation.getChildCalories();
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
    int totalCalories = city.getChildCalories();
    city.surplusFood += totalCalories;
    city.supermarkets.forEach((element) {
      int totalCalories = element.neededCalories;
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
