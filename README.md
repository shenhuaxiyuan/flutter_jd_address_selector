# flutter_jd_address_selector

仿京东地址选择器

从https://github.com/shichunlei/flutter_jd_address_selector  改编而来，支持设置初始值，支持A-Z排序 ， 完善了数据源 ，添加热门城市

## Use


### pubspec.yaml

```yaml
    dependencies:
      flutter_jd_address_selector:
        git:
          url: https://github.com/shenhuaxiyuan/flutter_jd_address_selector
```

### import

```dart
    import 'package:flutter_jd_address_selector/flutter_jd_address_selector.dart';
```

### use

```dart
    void _choiceAddressDialog() async {
      showModalBottomSheet(
              context: context,
              isScrollControlled: true,
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
```


## 运行截图

|![1](https://github.com/shenhuaxiyuan/flutter_jd_address_selector/blob/master/screen_pic/Screenshot_1591667475.png))|
| :--: | :--: |


