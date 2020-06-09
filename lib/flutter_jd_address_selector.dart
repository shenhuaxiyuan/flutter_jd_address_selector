library flutter_jd_address_selector;

import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jd_address_selector/province.dart';
import 'package:flutter_jd_address_selector/result.dart';
import 'package:lpinyin/lpinyin.dart';

import 'dart:ui' as ui show window;

import 'entity_info_model.dart';

class JDAddressDialog extends StatefulWidget {
  final String title;
  final Function(Result) onSelected;

  final Color unselectedColor;
  final Color selectedColor;

  final double itemTextFontSize;

  final TextStyle titleTextStyle;

  final String provinceName;
  final String cityName;
  final String areaName;

  JDAddressDialog(
      {Key key,
        @required this.onSelected,
        this.title,
        this.unselectedColor: Colors.grey,
        this.selectedColor: Colors.blue,
        this.itemTextFontSize: 14.0,
        this.provinceName,
        this.cityName,
        this.areaName,
        this.titleTextStyle: const TextStyle(
            fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold)})
      : super(key: key);

  @override
  createState() => _JDAddressDialogState();
}

class _JDAddressDialogState extends State<JDAddressDialog>
    with TickerProviderStateMixin {
  int _index = 0;

  TabController _tabController;
  ScrollController _controller;

  /// TabBar不能动态加载，所以初始化3个，其中两个文字置空，点击事件拦截住。
  List<Tab> myTabs = <Tab>[Tab(text: '请选择'), Tab(text: ''), Tab(text: '')];

  List<Province> provinces = [];

//  List cities = [];
//  List counties = [];

  /// 当前列表数据
  List<EntityInfo> mList = [];

  /// 三级联动选择的position
  var _positions = [0, 0, 0];

  double _itemHeight = 48.0;
  int _suspensionHeight = 20;
  String _suspensionTag = "";
  double headerHeight = 170;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();

    _tabController = TabController(vsync: this, length: myTabs.length);

    _initData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: Container(
            height:
            MediaQueryData.fromWindow(ui.window).size.height * 11.0 / 16.0,
            child: Column(children: <Widget>[
              Stack(children: <Widget>[
                Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child:
                    Text("${widget.title}", style: widget.titleTextStyle)),
                Positioned(
                    right: 0,
                    child: IconButton(
                        icon: Icon(Icons.close, size: 22),
                        onPressed: () => Navigator.maybePop(context)))
              ]),
              _line,
              Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      onTap: (index) {
                        if (myTabs[index].text.isEmpty) {
                          _tabController.animateTo(_index);
                          return;
                        }
                        setState(() {
                          _index = index;
                          _initData();
                        });
                        Future.delayed(Duration(milliseconds: 100)).then((value) {
                          var height = _positions[_index] * _itemHeight;
                          if(height>0){
                            if(_index==0)
                              height+=headerHeight-10;//index==0的时候顶部有header，其它没有
                            for(int i=0;i<_positions[_index];i++){
                              if(mList[i].isShowSuspension){
                                height+=_suspensionHeight;
                              }
                            }
                            _controller.animateTo(
                                height,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.ease);
                          }

                        });

                      },
                      indicatorSize: TabBarIndicatorSize.label,
                      unselectedLabelColor: Colors.black,
                      labelColor: widget.selectedColor,
                      tabs: myTabs)),
              _line,
              Expanded(
                  child: provinces.length > 0
                      ? _buildListView()
                      : CupertinoActivityIndicator(animating: false))
            ])));
  }


  void _initData() async {
    if (provinces.length == 0) {
      var value = await rootBundle.loadString(
          'packages/flutter_jd_address_selector/assets/chinese_cities.json');
//      provinces = json.decode(value);
      provinces = (json.decode(value) as List).map((e) => Province.fromJson(e)).toList();
      try{
        if(widget.provinceName!=null){
          var province = provinces
              .firstWhere((province) => province.name == widget.provinceName);
          _index=0;
          myTabs[_index] = Tab(text: province.name);
          _positions[_index] = provinces.indexOf(province);
          if(widget.cityName!=null){
            var city = province.cityList
                .firstWhere((city) => city.name == widget.cityName);
            _index=1;
            myTabs[_index] = Tab(text: city.name);
            _positions[_index] = province.cityList.indexOf(city);
            _tabController = TabController(vsync: this, length: myTabs.length,initialIndex: _index);
            if(widget.areaName!=null){
              var area = city.countyList
                  .firstWhere((area) => area.name == widget.areaName);
              _index=2;
              myTabs[_index] = Tab(text: area.name);
              _positions[_index] = city.countyList.indexOf(area);
              _tabController = TabController(vsync: this, length: myTabs.length,initialIndex: _index);
            }
          }
        }
      }catch(e){}
    }

    mList.clear();
    switch (_index) {
      case 0:
        provinces.forEach((province) {
          mList.add(EntityInfo(name: province.name));
        });

        break;
      case 1:
        var province = provinces.firstWhere((province) {
          return province.name == myTabs[0].text;
        });
        province.cityList.forEach((city) {
          mList.add(EntityInfo(name: city.name));
        });
        break;
      case 2:
        var province = provinces
            .firstWhere((province) => province.name == myTabs[0].text);
        var city = province.cityList
            .firstWhere((city) => city.name == myTabs[1].text);
        city.countyList.forEach((county) {
          mList.add(EntityInfo(name: county.name));
        });
        break;
    }
    _handleList(mList);
    if(mList.isEmpty){
      return;
    }

    //排序完毕后处理移动
    getPositions();

    _suspensionTag = mList[0].getSuspensionTag();
    setState(() {});
  }

  getPositions(){
    List.generate(mList.length, (index){
      if(mList[index].name==myTabs[_index].text){
        _positions[_index] = index;
      }
    });
  }


  clickTop(String name){
    _index=2;
    if(name=="北京市"||name=="上海市"||name=="天津市"){
      myTabs[0] = Tab(text: name);
      myTabs[1] = Tab(text: name);
      myTabs[2] = Tab(text: "请选择");
    }
    else{
      provinces.forEach((province) {
        province.cityList.forEach((city){
          if(city.name==name){
            myTabs[0] = Tab(text: province.name,);
          }
        });
      });
      myTabs[1] = Tab(text: name);
      myTabs[2] = Tab(text: "请选择");
    }
    _initData();
    setState(() {});
    _tabController.animateTo(_index);

  }

  clickItem(String name) {
    myTabs[_index] = Tab(text: name);
    EntityInfo info = mList.firstWhere((element) => element.name==name);
    _positions[_index] = mList.indexOf(info);
    _index++;
    _initData();
    switch (_index) {
      case 1:
        myTabs[1] = Tab(text: "请选择");
        myTabs[2] = Tab(text: "");
        break;
      case 2:
        myTabs[2] = Tab(text: "请选择");
        break;
      case 3:
        _index = 2;
        //查找id
        var province = provinces.firstWhere((province) => province.name==myTabs[0].text);
        var city = province.cityList.firstWhere((city) => city.name==myTabs[1].text);
        var county = city.countyList.firstWhere((county) => county.name==myTabs[2].text);
        widget.onSelected(Result(
            provinceName:province.name,
            cityName: city.name ,
            areaName: county.name ,
            provinceId: province.no,
            cityId: city.no,
            areaId: county.no
        ));
        Navigator.maybePop(context);
        break;
    }
    setState(() {});
    _tabController.animateTo(_index);
  }

  Widget _buildHeader() {
    List<EntityInfo> hotCityList = List();
    hotCityList.addAll([
      EntityInfo(name: "北京市"),
      EntityInfo(name: "上海市"),
      EntityInfo(name: "广州市"),
      EntityInfo(name: "杭州市"),
      EntityInfo(name: "南京市"),
      EntityInfo(name: "苏州市"),
      EntityInfo(name: "天津市"),
      EntityInfo(name: "武汉市"),
      EntityInfo(name: "长沙市"),
      EntityInfo(name: "重庆市"),
      EntityInfo(name: "成都市"),
    ]);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 10,right: 20,top: 5,bottom: 5),
          color: Color(0xfff3f4f5),
          child: Text("热门城市",style: TextStyle(
            fontSize: 14.0,
            color: Color(0xff999999),
          )),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 0,right: 20,top: 5,bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.center,
            children: hotCityList.map((e) {
              return InkWell(
                onTap: (){
                  clickTop(e.name);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/4.5,
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  alignment: Alignment.center,
                  child: Text(e.name,style: TextStyle(fontSize: 14,color: Colors.black87),),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  Widget _buildListItem(EntityInfo info) {
    String susTag = info.getSuspensionTag();
    susTag = (susTag == "★" ? "热门城市" : susTag);
    return Column(
      children: <Widget>[
        Offstage(
          offstage: info.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        InkWell(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                height: _itemHeight,
                alignment: Alignment.centerLeft,
                child: Row(children: <Widget>[
                  Text(info.name,
                      style: TextStyle(
                          fontSize: widget.itemTextFontSize,
                          color: info.name == myTabs[_index].text
                              ? widget.selectedColor
                              : widget.unselectedColor)),
                  SizedBox(height: 8),
                  Offstage(
                      offstage: info.name != myTabs[_index].text,
                      child: Icon(Icons.check,
                          size: 14.0, color: widget.selectedColor))
                ])),
            onTap: () {
              clickItem(info.name);
            })
      ],
    );
  }

  Widget _buildSusWidget(String susTag) {
    susTag = (susTag == "★" ? "热门城市" : susTag);
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  Widget _buildListView() {
    _controller = ScrollController();
    return AzListView(
      key: ValueKey(_index),
      controller: _controller,
      data: mList,
//      topData: _hotCityList,
      itemBuilder: (context, model) => _buildListItem(model),
      suspensionWidget: _buildSusWidget(_suspensionTag),
      isUseRealIndex: true,
      itemHeight: _itemHeight.toInt(),
      suspensionHeight: _suspensionHeight,
      onSusTagChanged: _onSusTagChanged,
      //showCenterTip: false,
      header: AzListViewHeader(
          tag: "★",
          height: _index==0?headerHeight.toInt():0,
          builder: (context) {
            if(_index!=0){
              return Container();
            }
            return _buildHeader();
          }),
    );
  }

  Widget _line = Container(height: 0.6, color: Color(0xFFEEEEEE));

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  void _handleList(List<EntityInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    //根据A-Z排序
    SuspensionUtil.sortListBySuspensionTag(list);
  }
}
