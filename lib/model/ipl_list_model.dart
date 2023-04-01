class IplListModel {
  int id;
  int memberId;
  String ipl;
  String type;
  String address;
  bool selected;

  IplListModel(
      {required this.id,
      required this.memberId,
      required this.ipl,
      required this.selected,
      required this.type,
      required this.address});
  factory IplListModel.fromJson(Map<String, dynamic> json) {
    final message = IplListModel(
      id: json['id'] as int,
      memberId: json['member_id'] as int,
      ipl: json['ipl'] as String,
      selected: json['selected'] as bool,
      type: json['type'] as String,
      address: json['address'] as String,
    );
    return message;
  }
}
