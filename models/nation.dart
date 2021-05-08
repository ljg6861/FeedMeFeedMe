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

    averageRatio = totalRatio/children.length;

    if (citiesWithoutEnoughFood.length > 0) {
      //see if there is enough food in the nation
      var totalFood = getAllCitiesAvailableFood();
      var neededFood = this.getChildCalories();

      if (totalFood > neededFood) {
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
                  //move around supermarket food first, then use city food
                  var currentKey = citiesWithEnoughFood.keys.toList()[i];
                  if (citiesWithEnoughFood[currentKey] >= currentMarketCalorieDeficit) {
                    city.surplusFood += currentMarketCalorieDeficit;
                    citiesWithEnoughFood[currentKey] -= currentMarketCalorieDeficit;
                    break;
                  } else {
                    city.surplusFood += citiesWithEnoughFood[currentKey];
                    currentMarketCalorieDeficit -= citiesWithEnoughFood[currentKey];
                    citiesWithEnoughFood[currentKey] = 0;
                  }
                }
              }
            }
          }
        });
      }
      //need to begin rationing
      else{
        if (daysToRation > -1){
          print('Reducing days of rationing');
        }
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
