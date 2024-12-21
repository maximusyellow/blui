import 'package:blui/utils/adapter_did_props_change.dart';
import 'package:blui/utils/device_did_props_change.dart';
import 'package:blui/utils/selected_adapter.dart';
import 'package:flutter/material.dart';
import 'package:bluez/bluez.dart';

class DeviceListView extends StatefulWidget {
  SelectedAdapter selectedAdapter;
  AdapterDidPropsChange adapterDidPropsChange;
  DeviceDidPropsChange deviceDidPropsChange;
  // ignore: use_super_parameters
  DeviceListView({Key? key, required this.selectedAdapter, required this.adapterDidPropsChange, required this.deviceDidPropsChange}) : super(key: key);
  @override
  State<DeviceListView> createState() => _DeviceListViewState();
}

class _DeviceListViewState extends State<DeviceListView> {
  List<BlueZDevice> devices = [];
  var client = BlueZClient();
  List<BlueZAdapter> adapters = [];
  late BlueZAdapter adapter;

  Future<void> fetchBluetoothAdapters() async {
    client.adapterAdded.listen((event) {
      setState(() {
        adapters.removeWhere((adapter) => adapter.address == event.address);
        adapters.add(event);
        adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
      });
    });
    client.adapterRemoved.listen((event) {
      setState(() {
        adapters.remove(event);
        if (adapters.isNotEmpty) {
          adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
        }
      });
    });
  }

  Future<void> fetchDevices() async {
    client.deviceAdded.listen((event) {
      setState(() {
        devices.removeWhere((d) => d.address == event.address);
        if (event.name != "") {
          devices.add(event);
        }
      });
    });
    client.deviceRemoved.listen((event) {
      setState(() {
        devices.removeWhere((d) => d.address == event.address);
      });
    });
  }

  @override
  void didUpdateWidget(covariant DeviceListView oldWidget) {
    client = BlueZClient();
    client.connect();
    fetchBluetoothAdapters();
    fetchDevices();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    client = BlueZClient();
    client.connect();
    fetchBluetoothAdapters();
    fetchDevices();
    super.didChangeDependencies();
  }

  List<ListTile> get deviceItems {
    var filteredDevices = devices.where((device) => device.adapter.alias == widget.selectedAdapter.selectedAdapter).toList();
    return filteredDevices.map((device) {
      return ListTile(
        title: Text(device.alias),
        subtitle: Text(device.icon),
        minVerticalPadding: 5,
        leading: device.icon == 'audio-headset' ? Icon(Icons.headset_mic) : device.icon == 'audio-headphones' ? Icon(Icons.headphones) : device.icon == 'phone' ? Icon(Icons.smartphone) : device.icon == 'input-gaming' ? Icon(Icons.sports_esports) : Icon(Icons.bluetooth),
        trailing: Wrap(
          spacing: 8.0,
          children: [
            Icon(device.paired ? Icons.link : Icons.link_off),
            Icon(device.trusted ? Icons.thumb_up : Icons.thumb_down),
            Icon(device.connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
          ],
        ),
        onTap: () {
          device.connect();
          widget.deviceDidPropsChange.propsChanged();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double dynamicWidth = MediaQuery.of(context).size.width; 
    return ListView.builder(
      itemCount: deviceItems.length,
      itemBuilder: (BuildContext context, int index) {
        var deviceTile = deviceItems.isNotEmpty ? deviceItems[index] : Text("");
        return deviceTile;
      },
    );
  }
}