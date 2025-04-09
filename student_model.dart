import 'package:apilocal/grade_model.dart';

class Student {
  final String name;
  final String fatherName;
  final String program;
  final String shift;
  final String rollNo;
  final Map<String, List<Grade>> semesters;

  Student({
    required this.name,
    required this.fatherName,
    required this.program,
    required this.shift,
    required this.rollNo,
    required this.semesters,
  });

  double calculateSemesterGPA(String semester) {
    final grades = semesters[semester];
    if (grades == null || grades.isEmpty) return 0.0;

    double totalQualityPoints = 0;
    double totalCreditHours = 0;

    for (final grade in grades) {
      if (grade.considerStatus != 'E' || grade.obtainedMarks == 0) continue;

      totalQualityPoints += grade.gradePoint * grade.creditHours;
      totalCreditHours += grade.creditHours;
    }

    return totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0;
  }

  double calculateCGPA() {
    double totalQualityPoints = 0;
    double totalCreditHours = 0;

    for (final semester in semesters.keys) {
      final grades = semesters[semester]!;
      for (final grade in grades) {
        if (grade.considerStatus != 'E' || grade.obtainedMarks == 0) continue;

        totalQualityPoints += grade.gradePoint * grade.creditHours;
        totalCreditHours += grade.creditHours;
      }
    }

    return totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0;
  }

  double getTotalCredits() {
    double total = 0;
    for (final semester in semesters.keys) {
      for (final grade in semesters[semester]!) {
        if (grade.considerStatus == 'E') {
          total += grade.creditHours;
        }
      }
    }
    return total;
  }

  int getCompletedSemesters() {
    return semesters.keys.where((sem) {
      return semesters[sem]!.any((grade) => grade.considerStatus == 'E');
    }).length;
  }
}
