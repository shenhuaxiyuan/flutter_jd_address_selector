class Province {
  String name;
  String no;
  List<City> cityList;

  Province({this.name, this.no, this.cityList});

  Province.fromJson(Map<String, dynamic> json) {    
    this.name = json['name'];
    this.no = json['no'];
    this.cityList = (json['cityList'] as List)!=null?(json['cityList'] as List).map((i) => City.fromJson(i)).toList():null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    data['cityList'] = this.cityList != null?this.cityList.map((i) => i.toJson()).toList():null;
    return data;
  }

}

class City {
  String name;
  String no;
  List<County> countyList;

  City({this.name, this.no, this.countyList});

  City.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.no = json['no'];
    this.countyList = (json['countyList'] as List)!=null?(json['countyList'] as List).map((i) => County.fromJson(i)).toList():null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    data['countyList'] = this.countyList != null?this.countyList.map((i) => i.toJson()).toList():null;
    return data;
  }
}

class County {
  String name;
  String no;

  County({this.name, this.no});

  County.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.no = json['no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['no'] = this.no;
    return data;
  }
}
