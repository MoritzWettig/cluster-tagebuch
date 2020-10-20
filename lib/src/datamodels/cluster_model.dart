class Clusters {
  Clusters({this.id, this.name, this.ort, this.anzahlpersonen, this.datum});
  final int id;
  final String name;
  final String ort;
  final String anzahlpersonen;
  final int datum;

  Clusters.mapfromdb(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        ort = map['ort'],
        anzahlpersonen = map['anzahlpersonen'],
        datum = map['datum'];

  Map<String, dynamic> maptodb() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['ort'] = ort;
    map['anzahlpersonen'] = anzahlpersonen;
    map['datum'] = datum;
    return map;
  }
}
