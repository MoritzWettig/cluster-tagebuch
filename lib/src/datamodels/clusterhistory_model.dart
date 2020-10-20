class ClusterHistory {
  ClusterHistory({this.id, this.clusterID, this.contactID});
  final int id;
  final int clusterID;
  final int contactID;

  ClusterHistory.mapfromdb(Map<String, dynamic> map)
      : id = map['id'],
        clusterID = map['clusterID'],
        contactID = map['contactID'];

  Map<String, dynamic> maptodb() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['clusterID'] = clusterID;
    map['contactID'] = contactID;
    return map;
  }
}
