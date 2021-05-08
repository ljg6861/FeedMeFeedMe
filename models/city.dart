import 'package:uuid/uuid.dart';
import 'data_model.dart';
import 'supermarket.dart';

class City extends DataModel {
  final List<Supermarket> supermarkets;
  int dailyFoodProduction = 3000000;
  int daysToRation = 5;
  int surplusFood = 0;
  final String id = Uuid().v4();

  int get neededCalories {
    return this.getChildCalories() * daysToRation;
  }

  int get totalCaloriesInSupermarkets {
    int total = 0;
    supermarkets.forEach((supermarket) {
      total += supermarket.availableCalories;
    });
    return total;
  }

  City({this.supermarkets});

  Map toJson() {
    final map = {id: []};
    supermarkets.forEach((supermarket) {
      final currentArray = map[id];
      currentArray.add(supermarket.toJson());
    });
    return map;
  }

  double advanceDay(int daysToRation) {
    var totalPeople = getNumberOfPeopleDependent();
    surplusFood += dailyFoodProduction;

    double ratio = 0;
    var marketsWithEnoughFood = {};
    var marketsWithoutEnoughFood = {};
    var calorieDeficit = 0;
    var surplusCalories = surplusFood;

    //Get initial state of markets
    supermarkets.forEach((market) {
      market.daysToRation = daysToRation;
      if (market.availableCalories >= market.neededCalories) {
        marketsWithEnoughFood[market] = (market.availableCalories - market.neededCalories);
        surplusCalories += (market.availableCalories - market.neededCalories);
      } else {
        marketsWithoutEnoughFood[market] = market.availableCalories - market.neededCalories;
        calorieDeficit += (market.neededCalories - market.availableCalories);
      }
    });

    //planning

    //if we have enough extra food within the city
    if (calorieDeficit < surplusCalories) {
      ratio = 1;
      supermarkets.forEach((supermarket) {
        var numberPerMarket = supermarket.getNumberOfPeopleDependent();

        //If supermarket already has enough food, do nothing
        if (marketsWithEnoughFood.containsKey(supermarket)) {
          print('market has enough food');
          supermarket.advanceDay(1);
        } else {
          print('market does not have enough food');
          var currentMarketCalorieDeficit = ((supermarket.neededCalories + supermarket.dailyNeededCalories) - supermarket.availableCalories);
          //shift food within city
          if (marketsWithEnoughFood.length != 0) {
            if (marketsWithEnoughFood[marketsWithEnoughFood.keys.last] != 0) {
              //supermarket food
              for (int i = 0; i < marketsWithEnoughFood.keys.length; i++) {
                //move around supermarket food first, then use city food
                var currentKey = marketsWithEnoughFood.keys.toList()[i];
                if (marketsWithEnoughFood[currentKey] >= currentMarketCalorieDeficit) {
                  supermarket.availableCalories += currentMarketCalorieDeficit;
                  marketsWithEnoughFood[currentKey] -= currentMarketCalorieDeficit;
                  currentMarketCalorieDeficit -= marketsWithEnoughFood[currentKey];
                  currentMarketCalorieDeficit -= marketsWithEnoughFood[currentKey];
                  break;
                } else {
                  supermarket.availableCalories += marketsWithEnoughFood[currentKey];
                  currentMarketCalorieDeficit -= marketsWithEnoughFood[currentKey];
                  marketsWithEnoughFood[currentKey] = 0;
                }
              }
            }
          } else {
            //city food
            supermarket.availableCalories += currentMarketCalorieDeficit;
            surplusFood -= currentMarketCalorieDeficit;
          }
        }
        supermarket.advanceDay(1);
      });
    } else {
      //not enough food, portion all supermarkets food by a set ratio
      supermarkets.forEach((market) {
        ratio = surplusCalories / calorieDeficit;
        print('not enough food in city, portioning by: ' + ratio.toString());
        market.availableCalories += (market.getChildCalories() * ratio).round();
        surplusFood -= (market.getChildCalories() * ratio).round();
        market.advanceDay(ratio);
      });
    }
    return ratio;
  }

  int getChildCalories() {
    int total = 0;
    supermarkets.forEach((element) {
      total += element.getChildCalories();
    });
    return total;
  }

  int getNumberOfPeopleDependent() {
    int total = 0;
    supermarkets.forEach((fridge) {
      total += fridge.getNumberOfPeopleDependent();
    });
    return total;
  }
}
