import 'package:blui/utils/selected_adapter.dart';
import 'package:flutter/material.dart';
import 'package:bluez/bluez.dart';

class AdapterDropdown extends StatefulWidget {
  SelectedAdapter selectedAdapter;
  // ignore: use_super_parameters
  AdapterDropdown({Key? key, required this.selectedAdapter}) : super(key: key);

  @override
  State<AdapterDropdown> createState() => _AdapterDropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _AdapterDropdownState extends State<AdapterDropdown> {
  List<BlueZAdapter> adapters = [];
  var client = BlueZClient();
  
  Future<void> fetchBluetoothAdapters() async {
    client.connect();
    client.adapterAdded.listen((event) {
      setState(() {
        adapters.removeWhere((adapter) => adapter.address == event.address);
        adapters.add(event);
      });
    });
    client.adapterRemoved.listen((event) {
      setState(() {
        adapters.remove(event);
      });
    });
    client.close();
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
    return Padding(padding: EdgeInsets.only(left: 8),
      child: DropdownMenu<String>(
        width: dynamicWidth * 0.5,
        onSelected: (String? value) {
          setState(() {
            widget.selectedAdapter.updateSelectedAdapter(value!, client);
          });
        },
        dropdownMenuEntries: dropdownItems,
      )
    );
  }
}