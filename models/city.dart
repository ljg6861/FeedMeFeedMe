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
    return this.getChildCalories() * (daysToRation - 1);
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
    this.daysToRation = daysToRation;
    this.surplusFood += dailyFoodProduction;

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
      } else {
        marketsWithoutEnoughFood[market] = market.availableCalories - market.neededCalories;
        calorieDeficit += (market.neededCalories - market.availableCalories);
      }
    });

    //planning

    print('Beginning planning phase, current deficit: ' + calorieDeficit.toString());
    print('Current surplus: ' + surplusCalories.toString());

    //if we have enough extra food within the city
    if (calorieDeficit <= surplusCalories) {
      ratio = 1;
      supermarkets.forEach((supermarket) {
        var numberPerMarket = supermarket.getNumberOfPeopleDependent();

        //If supermarket already has enough food, do nothing
        if (marketsWithEnoughFood.containsKey(supermarket)) {
        } else {
          print('market does not have enough food');
          var currentMarketCalorieDeficit = (supermarket.neededCalories - supermarket.availableCalories);
          print('current deficit of: ' + currentMarketCalorieDeficit.toString());
          //city food
          print('Using city food to achieve calorie goal\nStarting city surplus: ' + surplusFood.toString());
          supermarket.availableCalories += currentMarketCalorieDeficit;
          surplusFood -= currentMarketCalorieDeficit;
          print('Ending city surplus: ' + surplusFood.toString());
        }
        supermarket.advanceDay(1);
      });
    } else {
      //not enough food, portion all supermarkets food by a set ratio
      supermarkets.forEach((market) {
        ratio = surplusCalories / calorieDeficit;
        print('not enough food in city, portioning by: ' + ratio.toString());
        market.availableCalories += (market.getChildCalories() * ratio).round();
        print('surplus before ration: ' + surplusFood.toString());
        surplusFood -= (market.getChildCalories() * ratio).round();
        print('surplus after ration: ' + surplusFood.toString());
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
