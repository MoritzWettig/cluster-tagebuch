class Contacts {
  Contacts(
      {this.id,
      this.vorname,
      this.nachname,
      this.strasse,
      this.ort,
      this.plz,
      this.telefonnummer,
      this.adddatum});
  final int id;
  final String vorname;
  final String nachname;
  final String strasse;
  final String ort;
  final String plz;
  final String telefonnummer;
  final int adddatum;

  Contacts.mapfromdb(Map<String, dynamic> map)
      : id = map['id'],
        vorname = map['vorname'],
        nachname = map['nachname'],
        strasse = map['strasse'],
        ort = map['ort'],
        plz = map['plz'],
        telefonnummer = map['telefonnummer'],
        adddatum = map['adddatum'];

  Contacts.mapfromdbforJSON(Map<String, dynamic> map)
      : id = null,
        vorname = map['vorname'],
        nachname = map['nachname'],
        strasse = map['strasse'],
        ort = map['ort'],
        plz = map['plz'],
        telefonnummer = map['telefonnummer'],
        adddatum = null;

  Map<String, dynamic> maptodb() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['vorname'] = vorname;
    map['nachname'] = nachname;
    map['strasse'] = strasse;
    map['ort'] = ort;
    map['plz'] = plz;
    map['telefonnummer'] = telefonnummer;
    map['adddatum'] = adddatum;
    return map;
  }
}
