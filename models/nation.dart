import 'dart:convert';
import 'dart:io';
import 'city.dart';
import 'package:uuid/uuid.dart';

class Nation {
  final List<City> children;
  int daysToRation = 5;
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

  void recordDataToFile(String filename) {
    File file = File(filename);
    file.delete();
    file.create();
    file.writeAsStringSync(jsonEncode(this.toJson()));
  }

  void advanceDay() {
    //city to available food
    var citiesWithEnoughFood = {};
    //city to
    var citiesWithoutEnoughFood = {};

    var averageRatio = 0.0;
    var totalRatio = 0;

    //Get initial state of cities
    children.forEach((city) {
      var currentRatio = city.advanceDay(daysToRation);
      totalRatio += currentRatio.round();
      if (currentRatio == 1) {
        citiesWithEnoughFood[city] = city.surplusFood;
      } else {
        //we need to make some adjustments, some cities don't have enough food
        citiesWithoutEnoughFood[city] = (city.surplusFood - city.neededCalories);
      }
    });

    averageRatio = totalRatio / children.length;

    //see if there is enough food in the nation
    var totalFood = getAllCitiesAvailableFood();
    var neededFood = this.getChildCalories() * (daysToRation - 1);

    children.forEach((city) {
      if (citiesWithEnoughFood.containsKey(city)) {
        print('city has enough food');
      } else {
        print('city does not have enough food');
        var currentMarketCalorieDeficit = ((city.neededCalories + city.dailyFoodProduction) - city.totalCaloriesInSupermarkets);
        //shift food within city
        if (citiesWithEnoughFood.length != 0) {
          if (citiesWithEnoughFood[citiesWithEnoughFood.keys.last] != 0) {
            //supermarket food
            for (int i = 0; i < citiesWithEnoughFood.keys.length; i++) {
              City currentKey = citiesWithEnoughFood.keys.toList()[i];
              if (citiesWithEnoughFood[currentKey] >= currentMarketCalorieDeficit) {
                city.surplusFood += currentMarketCalorieDeficit;
                citiesWithEnoughFood[currentKey] -= currentMarketCalorieDeficit;
                currentKey.surplusFood -= currentMarketCalorieDeficit;
                break;
              } else {
                city.surplusFood += citiesWithEnoughFood[currentKey];
                currentMarketCalorieDeficit -= citiesWithEnoughFood[currentKey];
                currentKey.surplusFood -= citiesWithEnoughFood[currentKey];
                citiesWithEnoughFood[currentKey] = 0;
              }
            }
          }
        }
      }
    });
    //need to begin rationing
    if (totalFood < neededFood) {
      if (daysToRation > 0) {
        print('FAMINE DETECTED');
        daysToRation -= 1;
        print('Current amount of days to ration reduced to: ' + daysToRation.toString());
        this.advanceDay();
      } else {
        print('SIMULATION FAILED');
      }
    }
  }

  int getAllCitiesAvailableFood() {
    var total = 0;
    children.forEach((element) {
      total += element.totalCaloriesInSupermarkets;
    });
    return total;
  }

  int getChildCalories() {
    int total = 0;
    children.forEach((element) {
      total += element.getChildCalories();
    });
    return total;
  }
}
