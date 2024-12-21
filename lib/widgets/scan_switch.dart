import 'package:bluez/bluez.dart';
import 'package:blui/utils/adapter_did_props_change.dart';
import 'package:blui/utils/selected_adapter.dart';
import 'package:flutter/material.dart';

class ScanSwitch extends StatefulWidget {

  SelectedAdapter selectedAdapter;
  AdapterDidPropsChange didPropsChange;
  // ignore: use_super_parameters
  ScanSwitch({Key? key, required this.selectedAdapter, required this.didPropsChange}) : super(key: key);

  @override
  State<ScanSwitch> createState() => _ScanSwitchState();
}

class _ScanSwitchState extends State<ScanSwitch> {
  var client = BlueZClient();
  var isScanning = false;
  List<BlueZAdapter> adapters = [];
  late BlueZAdapter adapter;

  Future<void> fetchBluetoothAdapters() async {
    client.adapterAdded.listen((event) {
      setState(() {
        adapters.removeWhere((adapter) => adapter.address == event.address);
        adapters.add(event);
      });
      adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
      isScanning = adapter.discovering;
    });
    client.adapterRemoved.listen((event) {
      setState(() {
        adapters.remove(event);
      });
      if (adapters.isNotEmpty) {
          adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
          isScanning = adapter.discovering;
        }
    });
  }

   @override
   void didUpdateWidget(covariant ScanSwitch oldWidget) {
    client = BlueZClient();
    client.connect();
    fetchBluetoothAdapters();
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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isScanning,
      activeColor: Colors.white,
      onChanged: (bool value) {
        setState(() {
          value ? adapter.startDiscovery() : adapter.stopDiscovery();
          isScanning = value;
        });
      },
    );
  }
}