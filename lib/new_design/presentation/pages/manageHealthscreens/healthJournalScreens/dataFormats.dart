class DateFmt {
  //check the given date is under the past week
  bool isWithinPastWeek(String dateString) {
    // Parse the input string into a DateTime object
    DateTime givenDate = DateTime.parse(dateString);

    // Get the current date and time
    DateTime currentDate = DateTime.now();

    // Calculate the difference in days
    int differenceInDays = currentDate.difference(givenDate).inDays;

    // Check if the difference is within the past week (less than 7 days)
    return differenceInDays >= 0 && differenceInDays < 7;
  }
}
