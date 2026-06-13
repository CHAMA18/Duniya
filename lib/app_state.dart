import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  double _Weight = 0.0;
  double get Weight => _Weight;
  set Weight(double value) {
    _Weight = value;
  }

  double _Height = 0.0;
  double get Height => _Height;
  set Height(double value) {
    _Height = value;
  }

  double _BMI = 0.0;
  double get BMI => _BMI;
  set BMI(double value) {
    _BMI = value;
  }

  String _SelectedPage = 'Home';
  String get SelectedPage => _SelectedPage;
  set SelectedPage(String value) {
    _SelectedPage = value;
  }

  String _Gender = 'Male';
  String get Gender => _Gender;
  set Gender(String value) {
    _Gender = value;
  }

  CartItemsStruct _Cart = CartItemsStruct();
  CartItemsStruct get Cart => _Cart;
  set Cart(CartItemsStruct value) {
    _Cart = value;
  }

  void updateCartStruct(Function(CartItemsStruct) updateFn) {
    updateFn(_Cart);
  }

  int _LoopCounter = 0;
  int get LoopCounter => _LoopCounter;
  set LoopCounter(int value) {
    _LoopCounter = value;
  }

  GraphDataStruct _GraphData = GraphDataStruct();
  GraphDataStruct get GraphData => _GraphData;
  set GraphData(GraphDataStruct value) {
    _GraphData = value;
  }

  void updateGraphDataStruct(Function(GraphDataStruct) updateFn) {
    updateFn(_GraphData);
  }

  String _SubscriptionName = '';
  String get SubscriptionName => _SubscriptionName;
  set SubscriptionName(String value) {
    _SubscriptionName = value;
  }

  String _EndDate = '';
  String get EndDate => _EndDate;
  set EndDate(String value) {
    _EndDate = value;
  }

  String _Pharm = '';
  String get Pharm => _Pharm;
  set Pharm(String value) {
    _Pharm = value;
  }

  String _SelectedPharmacy = '';
  String get SelectedPharmacy => _SelectedPharmacy;
  set SelectedPharmacy(String value) {
    _SelectedPharmacy = value;
  }

  String _SelectedOutlet = '';
  String get SelectedOutlet => _SelectedOutlet;
  set SelectedOutlet(String value) {
    _SelectedOutlet = value;
  }
}
