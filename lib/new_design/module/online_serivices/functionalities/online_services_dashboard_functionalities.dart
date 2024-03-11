import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../../views/dietJournal/activity/activity_detail.dart';
import '../../../../views/gamification/dateutils.dart';
import '../data/model/class_session_modle.dart';
import '../data/model/get_spec_class_list.dart';
import '../data/model/get_subscribtion_list.dart';

class OnlineServicesFunctions {
  DateTime currentDate = DateTime.now();
  List<String> mergeSpec(List<dynamic> docSpec, List<dynamic> classSpec) {
    List<String> specList = [];
    try {
      for (int i = 0; i <= 3; i++) {
        // Check if both docSpec and classSpec lists have enough elements
        if (i < docSpec.length && i < classSpec.length) {
          specList.add(docSpec[i].specialityName);
          specList.add(classSpec[i].specialityName);
        } else {
          // Handle the case where either docSpec or classSpec list is shorter
          // You might want to log a warning or handle it in a way that fits your application
          print("Warning: Index $i out of bounds in speciality lists.");
        }
      }
      return specList;
    } catch (e) {
      // Handle any other exceptions that might occur
      print("An error occurred: $e");
      specList = [];
      return specList;
    }
  }

  List<String> mergeFullSpec(List<dynamic> docSpec, List<dynamic> classSpec) {
    List<String> specList = [];

    try {
      // Merge both lists in a single loop
      int maxLength = docSpec.length > classSpec.length ? docSpec.length : classSpec.length;

      for (int i = 0; i < maxLength; i++) {
        // Add the specialityName from docSpec if available
        if (i < docSpec.length) {
          specList.add(docSpec[i].specialityName);
        }

        // Add the specialityName from classSpec if available
        if (i < classSpec.length) {
          specList.add(classSpec[i].specialityName);
        }
      }

      return specList;
    } catch (e) {
      // Handle any other exceptions that might occur
      print("An error occurred: $e");
      return [];
    }
  }

  filterExpiredClass(GetSpecClassList classList) {
    DateTime tempCurrentDate = DateTime.now();
    // DateTime currentDate = DateFormat("yyyy-MM-dd").parse(tempCurrentDate);
    classList.specialityClassList.removeWhere((SpecialityClassList element) {
      List<DateTime> dateRange = parseCourseDurationDDMMYY(element.courseDuration);
      if (dateRange.length == 2) {
        DateTime startDate = dateRange[0];
        DateTime endDate = dateRange[1];

        List<String> list1 = element.courseTime;

        // Sorting the list based on time
        list1.sort((a, b) {
          DateTime timeA = _parseTime(a);
          DateTime timeB = _parseTime(b);
          return timeA.compareTo(timeB);
        });

        String timeString = list1.last;

        // Extract the start time from the time range string
        String startTimeString = timeString.split(' - ')[0];
        // Format the DateTime object as a string
        String formattedDateString = DateFormat('yyyy-MM-dd').format(endDate);

        // Parse the time string into a DateTime object using the intl package
        DateTime parsedTime =
            DateFormat('yyyy-MM-dd h:mm a').parse('$formattedDateString $startTimeString');
        print(tempCurrentDate.isAfter(parsedTime));
        return tempCurrentDate.isAfter(parsedTime);
      } else {
        print("Invalid course duration format");
        return false;
      }
    });
    // classList.specialityClassList.removeWhere((SpecialityClassList element) {
    //
    // });
    return classList.specialityClassList;
  }

  DateTime _parseTime(String timeRange) {
    // Extract the start time from the time range string
    String startTimeString = timeRange.split(' - ')[0];

    // Parse the time string into a DateTime object
    DateTime parsedTime = DateFormat('h:mm a').parse(startTimeString);

    return parsedTime;
  }

  List<Subscription> filterExpiredSubscriptionClass(GetSubscriptionList classList) {
    DateTime currentDate = DateTime.now();

    classList.subscriptions.removeWhere((Subscription element) {
      List<DateTime> dateRange = parseCourseDurationYYMMDD(element.courseDuration);
      if (dateRange.length == 2) {
        DateTime startDate = dateRange[0];
        DateTime endDate = dateRange[1];
        print(currentDate.isSameDate(endDate));
        return currentDate.isSameDate(endDate) ? false : currentDate.isAfter(endDate);
      } else {
        print("Invalid course duration format");
        return false;
      }
    });

    return classList.subscriptions;
  }

  List<Subscription> getExpeiredClass(GetSubscriptionList classList) {
    DateTime currentDate = DateTime.now();

    classList.subscriptions.removeWhere((Subscription element) {
      List<DateTime> dateRange = parseCourseDurationYYMMDD(element.courseDuration);
      if (dateRange.length == 2) {
        DateTime startDate = dateRange[0];
        DateTime endDate = dateRange[1];
        print(currentDate.isSameDate(endDate));
        return currentDate.isSameDate(endDate) ? true : !(currentDate.isAfter(endDate));
      } else {
        print("Invalid course duration format");
        return false;
      }
    });

    return classList.subscriptions;
  }

  List<DateTime> parseCourseDurationDDMMYY(String courseDuration) {
    List<DateTime> dateRange = [];

    try {
      List<String> dateStrings = courseDuration.split(' - ');

      if (dateStrings.length == 2) {
        DateFormat format = DateFormat("dd-MM-yyyy");

        DateTime startDate = format.parse(dateStrings[0]);
        DateTime endDate = format.parse(dateStrings[1]);

        dateRange = [startDate, endDate];
      }
    } catch (e) {
      print("Error parsing course duration: $e");
    }

    return dateRange;
  }

  List<DateTime> parseCourseDurationYYMMDD(String courseDuration) {
    List<DateTime> dateRange = [];

    try {
      List<String> dateStrings = courseDuration.split(' - ');

      if (dateStrings.length == 2) {
        DateFormat format = DateFormat("yyyy-MM-dd");

        DateTime startDate = format.parse(dateStrings[0]);
        DateTime endDate = format.parse(dateStrings[1]);

        dateRange = [startDate, endDate];
      }
    } catch (e) {
      print("Error parsing course duration: $e");
    }

    return dateRange;
  }

  String parseDateToText(String dateString) {
    List<String> splitedStrings = dateString.split(' - ');
    // Convert string to DateTime
    DateTime inputDate = DateTime.parse(splitedStrings[0]);

    // Format the date
    String formattedDate = DateFormat('dd MMM yyyy').format(inputDate);
    return formattedDate;
  }

  List<DateTime> parseDateRange(String dateString) {
    List<String> dateStrings = dateString.split(" - ");
    String startDateString = dateStrings[0];
    String endDateString = dateStrings[1];
    DateTime startDate;
    DateTime endDate;
    try {
      startDate = DateTime.parse(startDateString);
    } catch (e) {
      startDate = parseDate(startDateString);
    }
    try {
      endDate = DateTime.parse(endDateString);
    } catch (e) {
      endDate = parseDate(endDateString);
    }

    return [startDate, endDate];
  }

  DateTime parseDate(String input) {
    List<String> parts = input.split('-');
    if (parts.length == 3) {
      int year = int.tryParse(parts[0]) ?? 0;
      int month = int.tryParse(parts[1]) ?? 0;
      int day = int.tryParse(parts[2]) ?? 0;

      if (year > 0 && month > 0 && day > 0) {
        return DateTime(year, month, day);
      }
    }
    // Return null or handle invalid date as needed
    return DateTime(2000, 01, 01);
  }

  String adjustHourLength(String timeString) {
    List<String> times = timeString.split(" - ");
    String startTime = formatTime(times[0]);
    String endTime = formatTime(times[1]);

    return "$startTime - $endTime";
  }

  String formatTime(String time) {
    // Parse time string in "h:mm a" format
    DateTime parsedTime = DateFormat("h:mm a").parse(time);

    // Format parsed time in "hh:mm a" format
    String formattedTime = DateFormat("hh:mm a").format(parsedTime);

    return formattedTime;
  }

  bool checkCurrentDate(DateTime startDate, DateTime endDate) {
    bool isSameDay(DateTime date1, DateTime date2) =>
        date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;

    return isSameDay(startDate, currentDate) ||
        isSameDay(endDate, currentDate) ||
        (currentDate.isAfter(startDate) && currentDate.isBefore(endDate));
  }

  String getTimeOfDay(String time) {
    final DateTime dateTime = DateFormat.jm().parse(time);

    if (dateTime.hour < 12) {
      return "Morning";
    } else if (dateTime.hour < 17) {
      return "Afternoon";
    } else if (dateTime.hour < 20) {
      return "Evening";
    } else {
      return "Night";
    }
  }

  List<Session> splitSessions(List<String> timeIntervals) {
    List<Session> sessions = [];

    for (String interval in timeIntervals) {
      List<String> parts = interval.split(" - ");

      if (parts.length == 2) {
        String startTime = parts[0];
        String endTime = parts[1];
        String timeOfDay = getTimeOfDay(startTime);

        sessions.add(Session(startTime: startTime, endTime: endTime, timeOfDay: timeOfDay));
        print(sessions);
      } else {
        // Handle invalid time interval format
        print("Invalid time interval format: $interval");
      }
    }
    return sessions;
  }

  IconData getSessionIcon(String session) {
    switch (session) {
      case "Morning":
        return Icons.wb_sunny_outlined;
      case "Afternoon":
        return Icons.wb_sunny;
      case "Evening":
        return Icons.wb_twilight_sharp;
      case "Night":
        return Icons.nightlight_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  int getNoSessionsAvailable(Map sessionData) {
    int noSessionAvailble = 0;
    var keys = sessionData.keys;
    keys.forEach((element) {
      if (sessionData[element].length > 0) {
        noSessionAvailble += 1;
      }
    });
    print(noSessionAvailble);
    return noSessionAvailble;
  }
  // String
}
