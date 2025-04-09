import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:apilocal/grade_model.dart';
import 'package:apilocal/grade_repository.dart';
import 'package:apilocal/student_model.dart';
import 'package:apilocal/add_grade_screen.dart';

final gradeRepositoryProvider = Provider((ref) => GradeRepository());
final studentsProvider = FutureProvider<List<Student>>((ref) {
  final repository = ref.read(gradeRepositoryProvider);
  return repository.getLocalStudents();
});

class GradeScreen extends ConsumerStatefulWidget {
  const GradeScreen({super.key});

  @override
  ConsumerState<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends ConsumerState<GradeScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadData({bool forceRefresh = false}) async {
    try {
      EasyLoading.show(status: 'Loading data...');
      final repository = ref.read(gradeRepositoryProvider);
      await repository.fetchAndStoreGrades();
      ref.invalidate(studentsProvider);
      EasyLoading.showSuccess('Data loaded successfully');
      _scrollToTop();
    } catch (e) {
      EasyLoading.showError('Failed to load data: ${e.toString()}');
    }
  }

  Future<void> _eraseData() async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Erase'),
            content: const Text('Are you sure you want to delete all data?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        EasyLoading.show(status: 'Erasing data...');
        final repository = ref.read(gradeRepositoryProvider);
        await repository.deleteAllGrades();
        ref.invalidate(studentsProvider);
        EasyLoading.showSuccess('All data erased');
      } catch (e) {
        EasyLoading.showError('Failed to erase data');
      }
    }
  }

  Future<void> _navigateToAddScreen(BuildContext context,
      {Student? student}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGradeScreen(student: student)),
    );

    if (result == true) {
      ref.invalidate(studentsProvider);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load student data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final cgpa = student.calculateCGPA();
    final totalCredits = student.getTotalCredits();
    final completedSemesters = student.getCompletedSemesters();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: ListTile(
          title: Text(student.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Text('${student.program} • ${student.rollNo}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text('CGPA: ${cgpa.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: _getTextColorForGpa(cgpa),
                        fontWeight: FontWeight.bold)),
                backgroundColor: _getBackgroundColorForGpa(cgpa),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Text('Add Grade for this Student'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'add') {
                    _navigateToAddScreen(context, student: student);
                  }
                },
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Father Name', student.fatherName),
                _buildInfoRow('Shift', student.shift),
                _buildInfoRow('Total Credits', totalCredits.toStringAsFixed(2)),
                _buildInfoRow(
                    'Completed Semesters', completedSemesters.toString()),
                const SizedBox(height: 16),
                const Text('Semester-wise Performance:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...student.semesters.keys.map((semester) {
                  final gpa = student.calculateSemesterGPA(semester);
                  return _buildSemesterCard(student, semester, gpa);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(Student student, String semester, double gpa) {
    final semesterGrades = student.semesters[semester]!;
    final completedCourses =
        semesterGrades.where((g) => g.considerStatus == 'E').length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text('Semester $semester',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Chip(
              label: Text('GPA: ${gpa.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: _getTextColorForGpa(gpa),
                      fontWeight: FontWeight.bold)),
              backgroundColor: _getBackgroundColorForGpa(gpa),
            ),
            const SizedBox(width: 8),
            Text('$completedCourses courses'),
          ],
        ),
        children:
            semesterGrades.map((grade) => _buildGradeTile(grade)).toList(),
      ),
    );
  }

  Widget _buildGradeTile(Grade grade) {
    return ListTile(
      title: Text(grade.courseTitle),
      subtitle: Text(grade.courseCode),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${grade.obtainedMarks} (${grade.gradeLetter})',
              style: TextStyle(
                  color: _getColorForMarks(grade.obtainedMarks),
                  fontWeight: FontWeight.bold)),
          Text('${grade.creditHours} cr', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Color _getBackgroundColorForGpa(double gpa) {
    if (gpa >= 3.5) return Colors.green.shade100;
    if (gpa >= 3.0) return Colors.blue.shade100;
    if (gpa >= 2.5) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Color _getTextColorForGpa(double gpa) {
    if (gpa >= 3.5) return Colors.green.shade800;
    if (gpa >= 3.0) return Colors.blue.shade800;
    if (gpa >= 2.5) return Colors.orange.shade800;
    return Colors.red.shade800;
  }

  Color _getColorForMarks(double marks) {
    if (marks >= 85) return Colors.green;
    if (marks >= 70) return Colors.blue;
    if (marks >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Academic Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (students) => _buildStudentList(students),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addBtn',
            onPressed: () => _navigateToAddScreen(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'loadBtn',
            onPressed: _loadData,
            child: const Icon(Icons.cloud_download),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'eraseBtn',
            onPressed: _eraseData,
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<Student> students) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No student records found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Load Data'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: students.length,
        itemBuilder: (context, index) => _buildStudentCard(students[index]),
      ),
    );
  }
}
