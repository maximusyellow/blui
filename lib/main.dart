import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'utils/bluetooth.dart';
import 'package:bluez/bluez.dart';

void main() => runApp(const BluiApp());

class BluiApp extends StatelessWidget {
  const BluiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Blui Bluetooth Manager')),
        body: const SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: AdapterDropdown(),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AdapterDropdown extends StatefulWidget {
  const AdapterDropdown({super.key});

  @override
  State<AdapterDropdown> createState() => _AdapterDropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _AdapterDropdownState extends State<AdapterDropdown> {
  var bluetooth = Bluetooth();
  List<BlueZAdapter> adapters = [];
  String selectedAdapter = '';

  Future<void> fetchBluetoothAdapters() async {
    bluetooth.client.connect();
    bluetooth.client.adapterAdded.listen((event) {
      setState(() {
        adapters.add(event);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBluetoothAdapters(); // Fetch Bluetooth adapters on initialization
  }
  List<DropdownMenuEntry<String>> get dropdownItems {
    return adapters.map((adapter) {
      return DropdownMenuEntry(
        value: adapter.alias,
        label: adapter.alias,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double dynamicWidth = MediaQuery.of(context).size.width; 
    return DropdownMenu<String>(
      width: dynamicWidth * 0.5,
      onSelected: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          selectedAdapter = value!;
        });
      },
    
      dropdownMenuEntries: dropdownItems,
    );
  }
}
