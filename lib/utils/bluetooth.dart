import 'package:bluez/bluez.dart';

class Bluetooth {
  var client = BlueZClient();
  void connectClient() async{
    await client.connect();
  }
  void updateAdapters() async{
    await for (final adapter in client.adapterAdded.asBroadcastStream()) {
        client.adapters.add(adapter);
    }
  }
}