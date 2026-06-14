import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

double? resetCounter(
  double? sumTotal,
  DateTime? time,
) {
  // Reset variable to zero every 24 hours
  if (time == null) {
    return null;
  }
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(Duration(days: 1));
  final DateTime tomorrow = today.add(Duration(days: 1));
  if (time.isBefore(yesterday)) {
    return 0;
  } else if (time.isAfter(tomorrow)) {
    return 0;
  } else {
    return sumTotal;
  }
}

dynamic saveChatHistory(
  dynamic chatHistory,
  dynamic newChat,
) {
  // If chatHistory isn't a list, make it a list and then add newChat
  if (chatHistory is List) {
    chatHistory.add(newChat);
    return chatHistory;
  } else {
    return [newChat];
  }
}

double? bMICalculator(
  double weight,
  double height,
) {
  // Body mass index calculator with weight in kilograms and meters in height
  double bmi = weight / math.pow(height, 2);
  return bmi;
}

String? bmidata(double? data) {
  // 3 way if else conditional statement bmi
  if (data == null) {
    return null;
  } else if (data < 18.5) {
    return 'Underweight';
  } else if (data >= 18.5 && data <= 24.9) {
    return 'Normal';
  } else if (data >= 25 && data <= 29.9) {
    return 'Overweight';
  } else if (data >= 30) {
    return 'Obese';
  } else {
    return null;
  }
}

dynamic convertToJSON(String prompt) {
  // take the prompt and return a JSON with form [{"role": "user", "content": prompt}]
  return json.decode('{"role": "user", "content": "$prompt"}');
}

int? transanctionGenerator() {
  // random number generator
  final _random = math.Random();
  return _random.nextInt(1000000000);
}

int? drugstally(String? total) {
  // Calculating the total number of elements in a firebase
  if (total == null) {
    return null;
  }
  final List<String> list = total.split(',');
  return list.length;
}

DateTime? paymentOneMonth(DateTime? signUpDate) {
  // Payment successful extend time by one month
  if (signUpDate == null) {
    return null;
  }
  return signUpDate.add(Duration(days: 30));
}

List<int>? totalProducts(int? products) {
  // Calculate the total products sold from string records
  if (products == null) {
    return null;
  }
  final List<int> result = [];
  final List<String> productsString = products.toString().split('');
  for (int i = 0; i < productsString.length; i++) {
    result.add(int.parse(productsString[i]));
  }
  return result;
}

int totalPrice(
  int quantity,
  double price,
) {
  // quantity of products multipled by the number of products
  return quantity * price.toInt();
}

DateTime newDate(
  int noOfDays,
  DateTime cutDate,
) {
  // Add number of days to a given date defined
  return cutDate.add(Duration(days: noOfDays));
}

String? collectionFinance(String documentId) {
  // Loop throug a documents sub collection adding each doc called income returing the total
  FirebaseFirestore.instance
      .collection("users")
      .doc(documentId!)
      .collection('StockItems')
      .get()
      .then((snapshot) {
    double total = 0.0;
    snapshot.docs.forEach((doc) {
      total += doc.data()['Income'];
    });
    return total.toStringAsFixed(2);
  }).catchError((error) => 'Error getting finance collection: $error');
}

double cartTotal(
  List<double> amount,
  List<int> quantity,
) {
  // loops through two lists multiplying the amount and quantity values returning the sum total
  double sum = 0;
  for (int i = 0; i < amount.length; i++) {
    sum += amount[i] * quantity[i];
  }
  return sum;
}

String blankSpaceRemoval(String webUrl) {
  // removes blank spaces from a string and returns the results
  return webUrl.replaceAll(' ', '');
}

String jsonToString(dynamic json) {
  // gets json and converts to string
  return json.toString();
}

double incomeSum(List<double> amountList) {
  // returns the sum of all the values in the list
  double sum = 0;
  for (double amount in amountList) {
    sum += amount;
  }
  return sum;
}

double grossProfit(
  double? revenue,
  double? costOfGoodsSold,
) {
  // returns revenue - costofgoods, returns costofgoods if revenue is null, return 0 if both null
  if (revenue == null && costOfGoodsSold == null) {
    return 0;
  } else if (revenue == null) {
    return -1 * costOfGoodsSold!;
  } else {
    return revenue - (costOfGoodsSold ?? 0);
  }
}

double progressPercent(
  double? revenues,
  double goal,
) {
  // returns 0 if revenue is null or 0, returns revenue/goal*100
  if (revenues == null || revenues == 0) {
    return 0;
  } else {
    return (revenues / goal);
  }
}

int barChartLimit(double num) {
  if (num <= 0) {
    return 10; // Minimum value of 10
  }

  int maxPowerOf10 = 1;
  while (maxPowerOf10 <= num) {
    maxPowerOf10 *= 10;
  }

  return maxPowerOf10;
}

String? firstLetter(String name) {
  // takes in a string and gets the first returns the first letter of the string in uppercase
  if (name.isEmpty) {
    return "U";
  } else {
    return name[0].toUpperCase();
  }
}

DateTime unixConverter(String unixcode) {
  // unix time converter
  return DateTime.fromMillisecondsSinceEpoch(int.parse(unixcode) * 1000);
}

String encryptt(String email) {
  // encrypt a string
// Here is a simple implementation of encrypting a string using the base64 encoding technique
  final bytes = utf8.encode(email);
  final encoded = base64.encode(bytes);
  return encoded;
}

String decryptt(String email) {
  // decrypt a string and return results
// Add your code here
  final List<int> bytes = base64.decode(email);
  final String decrypted = utf8.decode(bytes);
  return decrypted;
}
