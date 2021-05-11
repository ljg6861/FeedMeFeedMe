import 'package:uuid/uuid.dart';
import 'data_model.dart';
import 'supermarket.dart';

class City extends DataModel {
  final List<Supermarket> supermarkets;
  int dailyFoodProduction = 9000000;
  int daysToRation = 5;
  double currentRatio = 1;
  List<double> historyRatios = [];
  int surplusFood = 0;
  final String id;

  int get neededCalories {
    return this.getChildCalories(currentRatio) * (daysToRation - 1);
  }

  int get totalCaloriesInSupermarkets {
    int total = 0;
    supermarkets.forEach((supermarket) {
      total += supermarket.availableCalories;
    });
    return total;
  }

  City(this.id, {this.supermarkets});

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

    double ratio = currentRatio;
    var marketsWithEnoughFood = {};
    var marketsWithoutEnoughFood = {};
    var calorieDeficit = 0;

    //Get initial state of markets
    supermarkets.forEach((market) {
      market.daysToRation = daysToRation;
      if (market.availableCalories >= market.neededCalories(currentRatio)) {
        marketsWithEnoughFood[market] = (market.availableCalories - market.neededCalories(currentRatio));
      } else {
        marketsWithoutEnoughFood[market] = market.availableCalories - market.neededCalories(currentRatio);
        calorieDeficit += (market.neededCalories(ratio) - market.availableCalories);
      }
    });

    //planning

    //if we have enough extra food within the city
    if (calorieDeficit <= dailyFoodProduction && ((surplusFood + totalCaloriesInSupermarkets + dailyFoodProduction) > neededCalories)) {
      ratio = 1;
      var computedNewRatio = 1.0;
      for (int i = 0; i < historyRatios.length; i++){
        computedNewRatio += historyRatios[i];
      }
      computedNewRatio = computedNewRatio / (historyRatios.length + 1);
      this.currentRatio = computedNewRatio;
      supermarkets.forEach((supermarket) {
        //If supermarket already has enough food, do nothing
        if (marketsWithEnoughFood.containsKey(supermarket)) {
        } else {
          var currentMarketCalorieDeficit = (supermarket.neededCalories(ratio) - supermarket.availableCalories);
          //city food
          supermarket.availableCalories += currentMarketCalorieDeficit;
          surplusFood -= currentMarketCalorieDeficit;
        }
        supermarket.advanceDay(currentRatio);
      });
    } else {
      //not enough food, portion all supermarkets food by a set ratio
      print('Not enough food in city detected, rationing while waiting for supplies');
      supermarkets.forEach((market) {
        ratio = (dailyFoodProduction / calorieDeficit);
        var computedNewRatio = ratio;
        for (int i = 0; i < historyRatios.length; i++){
          computedNewRatio += historyRatios[i];
        }
        computedNewRatio = computedNewRatio / (historyRatios.length + 1);
        this.currentRatio = computedNewRatio;
        market.availableCalories += (market.getChildCalories(ratio)).round();
        surplusFood -= (market.getChildCalories(ratio)).round();
        if (surplusFood < 0){ //remove negative errors from rounding
          surplusFood = 0;
        }
        market.advanceDay(ratio);
      });
      print('Amount to ratio by: ' + this.currentRatio.toString());
    }
    historyRatios.add(ratio);
    if (historyRatios.length == 11){ //only use last 10 days as analysis
      historyRatios.removeAt(0);
    }
    return ratio;
  }

  int getChildCalories(ratio) {
    int total = 0;
    supermarkets.forEach((element) {
      total += element.getChildCalories(ratio);
    });
    return total;
  }

  int getNumberOfPeopleDependent() {
    int total = 0;
    supermarkets.forEach((supermarket) {
      total += supermarket.getNumberOfPeopleDependent();
    });
    return total;
  }
}
