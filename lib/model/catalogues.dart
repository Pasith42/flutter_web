import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Catalogues {
  Catalogues(
      {required this.name,
      required this.number,
      required this.room,
      required this.startDate,
      required this.checkDate,
      required this.image})
      : id = uuid.v4();

  //ไอดีของผู้ใช้
  final String id;
  //ชือ อุปกรณ์
  final String name;
  //****รหัส อุปกรณ์****
  final int number;
  //รหัสห้อง
  final String room;
  //กำหนดวันที่เริ่มใช้งาน
  final DateTime startDate;
  //กำหนดวันที่ตรวจสภาพ
  final DateTime checkDate;
  //เก็บภาพที่ถ่ายรูปได้
  final String image;

  factory Catalogues.tofromJson(Map<String, dynamic> json) => Catalogues(
        name: json["name"],
        number: json["number"],
        room: json["room"],
        startDate: (json["startDate"] as Timestamp).toDate(),
        checkDate: (json["checkDate"] as Timestamp).toDate(),
        image: json["image"],
    );
  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "number": number,
      "room": room,
      "startDate" : Timestamp.fromDate(startDate),
      "checkDate" : Timestamp.fromDate(checkDate),
      "image" : image
    };
  }
}
