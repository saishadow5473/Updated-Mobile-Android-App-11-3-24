class CaloriesCalc {
  // String servingType,
  num calculateCalories(num basicQuantity, num basicCaloreis, num updatedQuantity) {
    num res = (updatedQuantity / basicQuantity) * basicCaloreis;
    return res;
  }

  Map calculateNutrients(
      num carbs, num fiber, num fats, num protein, num basicQuantity, updatedQuantity) {
    Map<String, num> updatedNutrients = {};
    num carbsRes = (updatedQuantity / basicQuantity) * carbs;
    updatedNutrients.addAll({'carbs': carbsRes});
    num proteinRes = (updatedQuantity / basicQuantity) * protein;
    updatedNutrients.addAll({'protein': proteinRes});
    num fiberRes = (updatedQuantity / basicQuantity) * fiber;
    updatedNutrients.addAll({'fiber': fiberRes});
    num fatsRes = (updatedQuantity / basicQuantity) * fats;
    updatedNutrients.addAll({'fats': fatsRes});

    return updatedNutrients;
  }
}
