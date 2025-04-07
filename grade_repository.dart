import 'package:logger/logger.dart';
import 'api_service.dart';
import 'database_helper.dart';
import 'grade_model.dart';
import 'student_model.dart';

class GradeRepository {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Logger _logger = Logger();

  Future<List<Student>> fetchAndStoreGrades() async {
    try {
      final apiData = await _apiService.fetchGrades();
      await _dbHelper.deleteAllGrades();

      final grades =
          apiData.map<Grade>((json) => Grade.fromJson(json)).toList();

      for (final grade in grades) {
        await _dbHelper.insertGrade(grade.toMap());
      }

      return _processStudents(grades);
    } catch (e) {
      _logger.e('Repository Error: $e');
      rethrow;
    }
  }

  Future<List<Student>> getLocalStudents({bool forceRefresh = false}) async {
    try {
      final localGrades = await _dbHelper.getAllGrades();
      final grades =
          localGrades.map<Grade>((map) => Grade.fromJson(map)).toList();
      return _processStudents(grades);
    } catch (e) {
      _logger.e('Local Data Error: $e');
      rethrow;
    }
  }

  List<Student> _processStudents(List<Grade> grades) {
    final students = <String, Student>{};

    for (final grade in grades) {
      if (!students.containsKey(grade.rollNo)) {
        students[grade.rollNo] = Student(
          name: grade.studentName,
          fatherName: grade.fatherName,
          program: grade.programName,
          shift: grade.shift,
          rollNo: grade.rollNo,
          semesters: {},
        );
      }

      final student = students[grade.rollNo]!;
      if (!student.semesters.containsKey(grade.semester)) {
        student.semesters[grade.semester] = [];
      }

      student.semesters[grade.semester]!.add(grade);
    }

    return students.values.toList();
  }

  Future<void> deleteGrade(String gradeId) async {
    try {
      await _dbHelper.deleteGrade(gradeId);
    } catch (e) {
      _logger.e('Delete Error: $e');
      rethrow;
    }
  }

  Future<void> deleteAllGrades() async {
    try {
      await _dbHelper.deleteAllGrades();
    } catch (e) {
      _logger.e('Clear All Error: $e');
      rethrow;
    }
  }
}
