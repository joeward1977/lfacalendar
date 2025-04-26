class Period {
  static const int cName = 0;
  static const int rName = 1;

  String id;
  String className;
  String roomName;
  bool fullCourse;
  List<String> date;
  List<String> startTime;
  List<String> endTime;

  Period(var id)
      : this.withData(
            id: id,
            className: "",
            roomName: "",
            fullCourse: false,
            date: [],
            startTime: [],
            endTime: []);

  Period.withData(
      {required this.id,
      required this.className,
      required this.roomName,
      required this.fullCourse,
      required this.date,
      required this.startTime,
      required this.endTime});

  dynamic getSortValue(int index) {
    switch (index) {
      case cName:
        return className;
      case rName:
        return roomName;
      default:
        return className;
    }
  }

  static Period mapToObject(Map<String, dynamic> theMap) {
    return Period.withData(
      id: theMap['id'].toString(),
      className: theMap['className'],
      roomName: theMap['roomName'],
      fullCourse: theMap['fullCourse'],
      date: [],
      startTime: [],
      endTime: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "className": className,
      "roomName": roomName,
      "fullCourse": fullCourse,
    };
  }
}
