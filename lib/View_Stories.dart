// ignore: camel_case_types
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class files {
  String url;
  String filetype;
  String otherCaption;
  Timestamp time1;
  int duration;

  files(this.url, this.filetype, this.otherCaption, this.time1, this.duration);

  files.fromMap(Map<dynamic, dynamic> data)
      : url = data["url"],
        filetype = data["filetype"],
        otherCaption = data["otherCaption"],
        duration = data["duration"],
        time1 = data["time1"];
}
