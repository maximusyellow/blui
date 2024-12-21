import 'package:blui/theme/theme.dart';
import 'package:blui/utils/adapter_did_props_change.dart';
import 'package:blui/widgets/adapter_menu_anchor.dart';
import 'package:blui/widgets/device_list.dart';
import 'package:blui/widgets/scan_switch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blui/utils/selected_adapter.dart';
import 'package:bluez/bluez.dart';
import 'widgets/adapter_dropdown.dart';

void main() => runApp(const BluiApp());

class BluiApp extends StatelessWidget {
  const BluiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedAdapter = SelectedAdapter();
    final adapterDidPropsChange = AdapterDidPropsChange();
    return MaterialApp(
      theme: lightMode,
      darkTheme: darkMode,
      home: Scaffold(
        appBar: AppBar(title: const Text('Blui Bluetooth Manager')),
        body: SafeArea(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => selectedAdapter),
              ChangeNotifierProvider(create: (context) => adapterDidPropsChange)
            ],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Consumer<SelectedAdapter>(
                        builder: (context, selectedAdapter, child) => AdapterDropdown(selectedAdapter: selectedAdapter)
                      ) 
                    ),
                    Consumer2<SelectedAdapter, AdapterDidPropsChange>(
                      builder: (context, selectedAdapter, adapterDidPropsChange, child) {
                        if (selectedAdapter.selectedAdapter != "") {
                          return AdapterMenuAnchor(selectedAdapter: selectedAdapter, didPropsChange: adapterDidPropsChange); 
                        } else {
                          return Padding( padding: EdgeInsets.only(left: 8), child: Text('Please select an adapter'));
                        }
                      }    
                    ),
                    Consumer2<SelectedAdapter, AdapterDidPropsChange>(
                      builder: (context, selectedAdapter, adapterDidPropsChange, child) {
                        if (selectedAdapter.selectedAdapter != "") {
                          return ScanSwitch(selectedAdapter: selectedAdapter, didPropsChange: adapterDidPropsChange); 
                        } else {
                          return Padding( padding: EdgeInsets.only(left: 8), child: Text(''));
                        }
                      }
                    ),
                  ],
                ),
                Expanded(
                  child: Consumer<SelectedAdapter>(
                    builder: (context, selectedAdapter, child) => selectedAdapter.selectedAdapter != "" ? DeviceListView(selectedAdapter: selectedAdapter) : Padding( padding: EdgeInsets.only(left: 8), child: Text('Please select an adapter'))
                  )
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}