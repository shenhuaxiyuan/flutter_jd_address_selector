import 'package:flutter/material.dart';

import 'package:flutter_jd_address_selector/flutter_jd_address_selector.dart';
import 'package:flutter_jd_address_selector/result.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String address = '';

  Result _result = Result();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text('Plugin example app'), centerTitle: true),
        body: Center(child: Text('$address')),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _choiceAddressDialog();
            },
            child: Icon(Icons.location_on)));
  }

  void _choiceAddressDialog() async {
    print('======');
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,  //设为true，此时为全屏展示
        builder: (BuildContext context) {
          return JDAddressDialog(
              provinceName: _result.provinceName,
              cityName: _result.cityName,
              areaName: _result.areaName,
              onSelected: (Result result) {
                _result = result;
                address = '${result.provinceName}-${result.cityName}-${result.areaName}\n'+
                "${result.provinceId}-${result.cityId}-${result.areaId}";

                print('$address');
                setState(() {});
              },
              title: '选择地址',
              selectedColor: Colors.red,
              unselectedColor: Colors.black);
        });
  }
}
