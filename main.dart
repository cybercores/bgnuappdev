import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StudentProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_profile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        score INTEGER
      )
    ''');
  }

  Future<int> insertSubject(String name, int score) async {
    final db = await instance.database;
    return await db.insert('subjects', {'name': name, 'score': score});
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    final db = await instance.database;
    return await db.query('subjects');
  }

  Future<int> updateSubject(int id, String name, int score) async {
    final db = await instance.database;
    return await db.update(
      'subjects',
      {'name': name, 'score': score},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  List<Map<String, dynamic>> _subjects = [];
  String? _selectedSubject;
  Map<String, dynamic>? _selectedSubjectData;
  bool _isLoading = false;
  late BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    try {
      final subjects = await DatabaseHelper.instance.getAllSubjects();
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Failed to load subjects: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSubject() async {
    if (_subjectController.text.isEmpty || _scoreController.text.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    final score = int.tryParse(_scoreController.text) ?? 0;
    if (score < 0 || score > 100) {
      _showSnackBar('Score must be between 0 and 100');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await DatabaseHelper.instance.insertSubject(
        _subjectController.text.trim(),
        score,
      );
      _subjectController.clear();
      _scoreController.clear();
      await _loadSubjects();
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSubject() async {
    if (_selectedSubjectData == null ||
        _subjectController.text.isEmpty ||
        _scoreController.text.isEmpty) {
      _showSnackBar('No subject selected or fields are empty');
      return;
    }

    final score = int.tryParse(_scoreController.text) ?? 0;
    if (score < 0 || score > 100) {
      _showSnackBar('Score must be between 0 and 100');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await DatabaseHelper.instance.updateSubject(
        _selectedSubjectData!['id'],
        _subjectController.text.trim(),
        score,
      );
      _subjectController.clear();
      _scoreController.clear();
      _selectedSubject = null;
      _selectedSubjectData = null;
      await _loadSubjects();
    } catch (e) {
      _showSnackBar('Error updating subject: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSubject(int id) async {
    try {
      setState(() => _isLoading = true);
      await DatabaseHelper.instance.deleteSubject(id);
      if (_selectedSubjectData != null && _selectedSubjectData!['id'] == id) {
        _subjectController.clear();
        _scoreController.clear();
        _selectedSubject = null;
        _selectedSubjectData = null;
      }
      await _loadSubjects();
    } catch (e) {
      _showSnackBar('Error deleting subject: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectSubject(String? value) {
    if (value == null) return;

    setState(() {
      _selectedSubject = value;
      _selectedSubjectData = _subjects.firstWhere(
        (subject) => subject['name'] == value,
      );
      _subjectController.text = _selectedSubjectData!['name'];
      _scoreController.text = _selectedSubjectData!['score'].toString();
    });
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 80) return 'A';
    if (percentage >= 65) return 'B';
    if (percentage >= 50) return 'C';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    final totalSubjects = _subjects.length;
    final totalScore =
        _subjects.fold(0, (sum, subject) => sum + (subject['score'] as int));
    final averageScore =
        totalSubjects > 0 ? totalScore.toDouble() / totalSubjects : 0.0;
    final grade = _calculateGrade(averageScore);
    final gradeColor = _getGradeColor(grade);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildSubjectManagementSection(context),
            const SizedBox(height: 24),
            _buildSubjectsAndResultsSection(
                context, grade, gradeColor, averageScore),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  ' https://scontent.flhe3-2.fna.fbcdn.net/v/t39.30808-6/471045074_659023829809731_2864313545709645001_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGsAzzLOoX_BirwW82dVo9xi6QNjnDW0uyLpA2OcNbS7KTHIaYN2dinnn7dYCM1icA8A7axEzfNMr-MRvYRe1G2&_nc_ohc=tvki1RQlbWgQ7kNvgGh6nOs&_nc_oc=AdkQ2XztDMPLBaZm3drbRSgrM4dESzqpIHlhhOLTVMx-rc0k7J4Kvcozn_wxzQP0QqU&_nc_zt=23&_nc_ht=scontent.flhe3-2.fna&_nc_gid=TxWnLoaOmW8TpgHHiHJM9g&oh=00_AYFwXnFbH69jYA4ufu4i9MMCr-z1UB4b-0D6BYo00DROSA&oe=67E981B9'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Azeem Shakir',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: BSCSF22M08',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Computer Sciences ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Academic Year: 2022-26',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectManagementSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subject Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadSubjects,
                  tooltip: 'Refresh subjects',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select a subject'),
                ),
                ..._subjects
                    .map((subject) => DropdownMenuItem<String>(
                          value: subject['name'],
                          child: Text(subject['name']),
                        ))
                    .toList(),
              ],
              onChanged: _selectSubject,
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Score (0-100)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addSubject,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Subject'),
                  ),
                ),
                if (_selectedSubject != null) const SizedBox(width: 16),
                if (_selectedSubject != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateSubject,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('Update Subject'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsAndResultsSection(
    BuildContext context,
    String grade,
    Color gradeColor,
    double averageScore,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subjects List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_isLoading && _subjects.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No subjects added yet. Add your first subject above!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final percentage = subject['score'] as int;
                    final subjectGrade = _calculateGrade(percentage.toDouble());
                    final subjectGradeColor = _getGradeColor(subjectGrade);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) =>
                                  _deleteSubject(subject['id']),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              subject['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Score: ${subject['score']}'),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: subjectGradeColor,
                                  minHeight: 4,
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                subjectGrade,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: subjectGradeColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onTap: () => _selectSubject(subject['name']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            if (_subjects.isNotEmpty) ...[
              Text(
                'Academic Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Total Subjects',
                      _subjects.length.toString(),
                      Icons.book,
                    ),
                    const Divider(color: Colors.white54, height: 20),
                    _buildSummaryRow(
                      'Average Score',
                      '${averageScore.toStringAsFixed(2)}%',
                      Icons.assessment,
                    ),
                    const Divider(color: Colors.white54, height: 20),
                    _buildSummaryRow(
                      'Overall Grade',
                      grade,
                      Icons.grade,
                      gradeColor: gradeColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Subject Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _subjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    final subject = _subjects[index];
                    final percentage = subject['score'] as int;
                    final subjectGrade = _calculateGrade(percentage.toDouble());
                    final subjectGradeColor = _getGradeColor(subjectGrade);

                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                subject['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                      color: subjectGradeColor,
                                      strokeWidth: 8,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$percentage%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: subjectGradeColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          subjectGrade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: subjectGradeColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                onDeleted: () =>
                                    _selectSubject(subject['name']),
                                deleteIcon: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, IconData icon,
      {Color? gradeColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(gradeColor != null ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: gradeColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
