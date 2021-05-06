import 'dart:math';
import 'models/person.dart';
import 'models/supermarket.dart';
import 'models/fridge.dart';
import 'models/nation.dart';
import 'models/city.dart';

class DataGenerator {
  final int idealCalories = 2000;

  Nation generateData(int numberOfCities) {
    final random = Random();
    final List<City> cities = [];
    for (int i = 0; i < numberOfCities; i++) {
      final citySizeRandom = 1 + random.nextInt(3).ceil();
      final List<Supermarket> superMarkets = [];
      int numberOfSupermarkets;
      switch (citySizeRandom) {
        case 1:
          numberOfSupermarkets = 3;
          break;
        case 2:
          numberOfSupermarkets = 7;
          break;
        case 3:
          numberOfSupermarkets = 12;
          break;
        default:
          numberOfSupermarkets = 12;
          break;
      }
      for (int i = 0; i < numberOfSupermarkets; i++) {
        Supermarket market = Supermarket();
        market.children = _generateFamilies(market);
        superMarkets.add(market);
      }
      cities.add(City(children: superMarkets));
    }
    return Nation(children: cities);
  }

  List<Fridge> _generateFamilies(Supermarket supermarket) {
    final random = Random();
    final numberOfFamilies = 250 + random.nextInt(250).ceil();
    final List<Fridge> returnData = [];
    if (numberOfFamilies < 50) {
      return _generateFamilies(supermarket);
    }
    for (int i = 0; i < numberOfFamilies; i++) {
      var num = random.nextInt(6).ceil();
      if (num == 0) {
        num = 1;
      }
      Fridge fridge = Fridge();
      fridge.children = _generatePeople(num, fridge);
      returnData.add(fridge);
    }
    return returnData;
  }

  List<Person> _generatePeople(int numberOfPeople, Fridge fridge) {
    final List<Person> returnData = [];
    final random = Random();
    for (int i = 0; i < numberOfPeople; i++) {
      final randomValue = random.nextInt(600);
      Person person;
      if (randomValue == 300) {
        person = Person(desiredCalories: null, fridge: fridge);
      } else if (randomValue < 300) {
        person = Person(desiredCalories: idealCalories - randomValue, fridge: fridge);
      } else {
        person = Person(desiredCalories: idealCalories + (randomValue / 2).ceil(), fridge: fridge);
      }
      returnData.add(person);
    }
    return returnData;
  }
}
