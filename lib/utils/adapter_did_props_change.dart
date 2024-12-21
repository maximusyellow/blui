import 'package:flutter/foundation.dart';

class AdapterDidPropsChange with ChangeNotifier {
  bool didPropsChange = false;
  
  void propsChanged() {
    didPropsChange = didPropsChange ? false : true;
    notifyListeners(); // Notify listeners that the state has changed
  }
}