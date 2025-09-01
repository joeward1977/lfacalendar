class Period {
  static const int cName = 0;
  static const int rName = 1;

  String id;
  String className;
  String roomName;
  bool fullCourse;
  List<String> startDate;
  List<String> startTime;
  List<String> endDate;
  List<String> endTime;
  int? colorId;
  String description;

  Period(var id, {int? colorId})
      : this.withData(
            id: id,
            className: "",
            roomName: "",
            fullCourse: false,
            startDate: [],
            startTime: [],
            endDate: [],
            endTime: [],
            colorId: colorId,
            description: "");

  Period.withData(
      {required this.id,
      required this.className,
      required this.roomName,
      required this.fullCourse,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      this.colorId,
      required this.description});

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
      startDate: [],
      startTime: [],
      endDate: [],
      endTime: [],
      colorId: theMap['colorId'] != null
          ? int.tryParse(theMap['colorId'].toString())
          : null,
      description: theMap['description'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "className": className,
      "roomName": roomName,
      "fullCourse": fullCourse,
      "colorId": colorId,
      "description": description,
    };
  }
}
