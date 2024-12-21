import 'package:bluez/bluez.dart';
import 'package:flutter/foundation.dart';

class SelectedAdapter with ChangeNotifier {
  var selectedAdapter = '';
  
  void updateSelectedAdapter(String newValue, BlueZClient client) {
    selectedAdapter = newValue;
    notifyListeners(); // Notify listeners that the state has changed
  }
}