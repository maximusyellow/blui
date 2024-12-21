import 'package:bluez/bluez.dart';
import 'package:blui/utils/adapter_did_props_change.dart';
import 'package:blui/utils/selected_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This is the type used by the popup menu below.
enum MenuItem { 
  powered('Powered: ', SingleActivator(LogicalKeyboardKey.keyO, control: true)),
  discoverable('Discoverable: ', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  pairable('Pairable: ', SingleActivator(LogicalKeyboardKey.keyP, control: true));

  const MenuItem(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;
}

class AdapterMenuAnchor extends StatefulWidget {
  String powered = '';
  String discoverable = '';
  String pairable = '';
  String scan = '';
  SelectedAdapter selectedAdapter;
  AdapterDidPropsChange didPropsChange;
  // ignore: use_super_parameters
  AdapterMenuAnchor({Key? key, required this.selectedAdapter, required this.didPropsChange}) : super(key: key);

  @override
  State<AdapterMenuAnchor> createState() => _AdapterMenuAnchorState();
}

class _AdapterMenuAnchorState extends State<AdapterMenuAnchor> {
  MenuItem? selectedMenu;
  var client = BlueZClient();
  List<BlueZAdapter> adapters = [];
  late BlueZAdapter adapter;

  Future<void> fetchBluetoothAdapters() async {
    client.adapterAdded.listen((event) {
      setState(() {
        adapters.removeWhere((adapter) => adapter.address == event.address);
        adapters.add(event);
      });
      adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
    });
    client.adapterRemoved.listen((event) {
      setState(() {
        adapters.remove(event);
      });
      if (adapters.isNotEmpty) {
          adapter = adapters.firstWhere((element) => element.alias == widget.selectedAdapter.selectedAdapter);
        }
    });
  }
  
  void fetchAdapterState(){
    setState(() {
      widget.powered = adapter.powered ? 'On' : 'Off';
      widget.discoverable = adapter.discoverable ? 'On' : 'Off';
      widget.pairable = adapter.pairable ? 'On' : 'Off';
    });
  }

   @override
   void didUpdateWidget(covariant AdapterMenuAnchor oldWidget) {
    client.close();
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
    client.close();
    client = BlueZClient();
    client.connect();
    fetchBluetoothAdapters();
    super.didChangeDependencies();
  }

  List<MenuItemButton> get adapterMenuItems {
    List<MenuItemButton> menuItems = [];
    menuItems.add(
      MenuItemButton(
          onPressed: () => {
            setState(() {
              adapter.powered ? adapter.setPowered(false) : adapter.setPowered(true);
              widget.didPropsChange.propsChanged();
            }),
          },
          shortcut: MenuItem.powered.shortcut,
          child: Text(MenuItem.powered.label + widget.powered),
        ));
    menuItems.add( 
        MenuItemButton(
          onPressed: () => {
            setState(() {
              adapter.discoverable ? adapter.setDiscoverable(false) : adapter.setDiscoverable(true);
              widget.didPropsChange.propsChanged();
            }),
            },
          shortcut: MenuItem.discoverable.shortcut,
          child: Text(MenuItem.discoverable.label + widget.discoverable),
        ));
    menuItems.add(
        MenuItemButton(
          onPressed: () => {
            setState(() {
              adapter.pairable ? adapter.setPairable(false) : adapter.setPairable(true);
              widget.didPropsChange.propsChanged();
            }),
            },
          shortcut: MenuItem.pairable.shortcut,
          child: Text(MenuItem.pairable.label + widget.pairable),
        ));
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              fetchAdapterState();
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Adapter options',
        );
      },
      menuChildren: adapterMenuItems,
    );
  }
}
