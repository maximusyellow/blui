import 'package:bluez/bluez.dart';
import 'package:blui/utils/device_did_props_change.dart';
import 'package:blui/widgets/device_dialog.dart';
import 'package:flutter/material.dart';

// This is the type used by the popup menu below.
enum MenuItem { 
  paired(''),
  trusted(''),
  blocked(''),
  disconnect(''),
  info('Info');

  const MenuItem(this.label);
  final String label;
}

class DeviceMenuAchor extends StatefulWidget {
  String paired = '';
  String trusted = '';
  String blocked = '';
  String disconnect = '';
  DeviceDidPropsChange deviceDidPropsChange;
  BlueZDevice device;
  // ignore: use_super_parameters
  DeviceMenuAchor({Key? key, required this.deviceDidPropsChange, required this.device}) : super(key: key);

  @override
  State<DeviceMenuAchor> createState() => _DeviceMenuAchorState();
}

class _DeviceMenuAchorState extends State<DeviceMenuAchor> {
  MenuItem? selectedMenu;
  var client = BlueZClient();
  
  void fetchDeviceState(){
    setState(() {
      widget.paired = widget.device.paired ? 'Unpair' : 'Pair';
      widget.trusted = widget.device.trusted ? 'Untrust' : 'Trust';
      widget.blocked = widget.device.blocked ? 'Unblock' : 'Block';
      widget.disconnect = widget.device.connected ? 'Disconnect' : 'Connect';
    });
  }

   @override
   void didUpdateWidget(covariant DeviceMenuAchor oldWidget) {
    client.close();
    client = BlueZClient();
    client.connect();
    fetchDeviceState();
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
    fetchDeviceState();
    super.didChangeDependencies();
  }

  List<MenuItemButton> get deviceMenuItems {
    List<MenuItemButton> menuItems = [];
    menuItems.add(
      MenuItemButton(
          onPressed: () => {
            setState(() {
              widget.device.paired == false ? widget.device.pair() : null;
              widget.deviceDidPropsChange.propsChanged();
            }),
          },
          child: Text(MenuItem.paired.label + widget.paired),
        ));
    menuItems.add( 
        MenuItemButton(
          onPressed: () => {
            setState(() {
              widget.device.trusted ? widget.device.setTrusted(false) : widget.device.setTrusted(true);
              widget.deviceDidPropsChange.propsChanged();
            }),
            },
          child: Text(MenuItem.trusted.label + widget.trusted),
        ));
    menuItems.add(
        MenuItemButton(
          onPressed: () => {
            setState(() {
              widget.device.blocked ? widget.device.setBlocked(false) : widget.device.setBlocked(true);
              widget.deviceDidPropsChange.propsChanged();
            }),
            },
          child: Text(MenuItem.blocked.label + widget.blocked),
        ));
    menuItems.add(
        MenuItemButton(
          onPressed: () async => {
            widget.device.connected ? await widget.device.disconnect() : await widget.device.connect(),
            setState(() {
              widget.deviceDidPropsChange.propsChanged();
            }),
            },
          child: Text(MenuItem.disconnect.label + widget.disconnect),
        ));
    menuItems.add(
        MenuItemButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => DeviceDialog(device: widget.device)
          ),
          child: Text(MenuItem.info.label),
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
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Device options',
        );
      },
      menuChildren: deviceMenuItems,
    );
  }
}
