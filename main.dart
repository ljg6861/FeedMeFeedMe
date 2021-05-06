import 'data_generator.dart';
import 'models/nation.dart';

void main() {
  setupEnvironment();
}

Nation setupEnvironment() {
  var nation = generateData();
  int totalCaloriesRequired = nation.getChildCalories();
  print('Total calories required in nation: ' + totalCaloriesRequired.toString());
  print('\nTotal amount of cities in nation: ' + nation.children.length.toString());
  print('\n');
  for (int i = 0; i < nation.children.length; i++) {
    print('Total number of supermarkets in city ' + (i + 1).toString() + ': ' + nation.children[i].children.length.toString());
    for (int j = 0; j < nation.children[i].children.length; j++) {
      print('Total number of families in supermarket ' + (j + 1).toString() + ' in city ' + (i + 1).toString() + ': ' + nation.children[i].children[j].children.length.toString());
    }
    print('\n');
  }
  print('Giving each City enough food for 5 days');
  nation.children.forEach((city) {
    int totalCalories = city.getChildCalories();
    city.children.forEach((supermarket) {
      supermarket.availableCalories = (totalCalories/city.children.length).round();
    });
  });
}

Nation generateData() {
  DataGenerator dataGenerator = DataGenerator();
  Nation nation = dataGenerator.generateData(5);
  nation.recordDataToFile('initial_national_data.json');
  return nation;
}
