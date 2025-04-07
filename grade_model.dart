class Grade {
  final String studentName;
  final String fatherName;
  final String programName;
  final String shift;
  final String rollNo;
  final String courseCode;
  final String courseTitle;
  final double creditHours;
  final double obtainedMarks;
  final String semester;
  final String considerStatus;

  Grade({
    required this.studentName,
    required this.fatherName,
    required this.programName,
    required this.shift,
    required this.rollNo,
    required this.courseCode,
    required this.courseTitle,
    required this.creditHours,
    required this.obtainedMarks,
    required this.semester,
    required this.considerStatus,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      studentName: json['studentname'] ?? '',
      fatherName: json['fathername'] ?? '',
      programName: json['progname'] ?? '',
      shift: json['shift'] ?? '',
      rollNo: json['rollno'] ?? '',
      courseCode: json['coursecode'] ?? '',
      courseTitle: json['coursetitle'] ?? '',
      creditHours: double.tryParse(json['credithours']?.toString() ?? '0') ?? 0,
      obtainedMarks:
          double.tryParse(json['obtainedmarks']?.toString() ?? '0') ?? 0,
      semester: json['mysemester'] ?? '',
      considerStatus: json['consider_status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentname': studentName,
      'fathername': fatherName,
      'progname': programName,
      'shift': shift,
      'rollno': rollNo,
      'coursecode': courseCode,
      'coursetitle': courseTitle,
      'credithours': creditHours,
      'obtainedmarks': obtainedMarks,
      'mysemester': semester,
      'consider_status': considerStatus,
    };
  }

  String get gradeLetter {
    if (considerStatus != 'E' || obtainedMarks == 0) return 'N/A';
    if (obtainedMarks >= 85) return 'A';
    if (obtainedMarks >= 80) return 'A-';
    if (obtainedMarks >= 75) return 'B+';
    if (obtainedMarks >= 70) return 'B';
    if (obtainedMarks >= 65) return 'B-';
    if (obtainedMarks >= 61) return 'C+';
    if (obtainedMarks >= 58) return 'C';
    if (obtainedMarks >= 55) return 'C-';
    if (obtainedMarks >= 50) return 'D';
    return 'F';
  }

  double get gradePoint {
    if (considerStatus != 'E' || obtainedMarks == 0) return 0.0;
    if (obtainedMarks >= 85) return 4.0;
    if (obtainedMarks >= 80) return 3.7;
    if (obtainedMarks >= 75) return 3.3;
    if (obtainedMarks >= 70) return 3.0;
    if (obtainedMarks >= 65) return 2.7;
    if (obtainedMarks >= 61) return 2.3;
    if (obtainedMarks >= 58) return 2.0;
    if (obtainedMarks >= 55) return 1.7;
    if (obtainedMarks >= 50) return 1.0;
    return 0.0;
  }
}
