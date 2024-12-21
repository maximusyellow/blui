import 'package:bluez/bluez.dart';
import 'package:flutter/material.dart';

class DeviceDialog extends StatelessWidget {
  BlueZDevice device;
  // ignore: use_super_parameters
  DeviceDialog({Key? key, required this.device}) : super(key: key);

  List<Text> get deviceInfo {
    List<Text> deviceInfo = [];
    deviceInfo = [
      Text('Name: ${device.name}'),
      Text('Alias: ${device.alias}'),
      Text('Type: ${device.icon == 'audio-headset' ? 'Headset' : device.icon == 'audio-headphones' ? 'Headphones' : device.icon == 'phone' ? 'Phone' : device.icon == 'input-gaming' ? 'Controller' : 'Unknown'}'),
      Text('MAC Address: ${device.address}'),
      Text('Adapter: ${device.adapter.alias}'),
      Text('Connected: ${device.connected}'),
      Text('Paired: ${device.paired}'),
      Text('Trusted: ${device.trusted}'),
      Text('Blocked: ${device.blocked}'),
      Text('Modalias: ${device.modalias}'),
      Text('Battery: ${device.txPower}'),
      Text('Signal: ${device.rssi}'),
    ];
    return deviceInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(direction: Axis.vertical, children: deviceInfo),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
