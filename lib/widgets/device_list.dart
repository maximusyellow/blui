import 'package:blui/utils/selected_adapter.dart';
import 'package:flutter/material.dart';
import 'package:bluez/bluez.dart';

class DeviceListView extends StatefulWidget {
  SelectedAdapter selectedAdapter;
  // ignore: use_super_parameters
  DeviceListView({Key? key, required this.selectedAdapter}) : super(key: key);
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
        devices.add(event);
      });
    });
    client.deviceRemoved.listen((event) {
      setState(() {
        devices.remove(event);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBluetoothAdapters();
    fetchDevices(); // Fetch Bluetooth adapters on initialization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<ListTile> get deviceItems {
    var filteredDevices = devices.where((device) => device.adapter.alias == widget.selectedAdapter.selectedAdapter).toList();
    return filteredDevices.map((device) {
      return ListTile(
        title: Text(device.alias),
        subtitle: Text(device.adapter.alias),
        minVerticalPadding: 5,
        onTap: () {
          device.connect();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    client.connect();
    double dynamicWidth = MediaQuery.of(context).size.width; 
    return ListView.builder(
      itemCount: deviceItems.length,
      itemBuilder: (BuildContext context, int index) {
        var deviceTile = deviceItems.isNotEmpty ? deviceItems[index] : ListTile(title: Text('Please select an adapter'),);
        return deviceTile;
      },
    );
  }
}