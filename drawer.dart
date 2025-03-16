import 'package:flutter/material.dart';

class StudentDataGrid extends StatefulWidget {
  @override
  _StudentDataGridState createState() => _StudentDataGridState();
}

class _StudentDataGridState extends State<StudentDataGrid> {
 
  final List<Map<String, String>> students = [
    {'Name': 'Bhola Record', 'Attendance': '90%', 'GPA': '4', 'CGPA': '4'},
    {'Name': 'Jugno', 'Attendance': '85%', 'GPA': '3.5', 'CGPA': '3.6'},
    {'Name': 'Bohemia', 'Attendance': '92%', 'GPA': '3.9', 'CGPA': '4.0'},
    {'Name': 'Feeqa', 'Attendance': '88%', 'GPA': '3.7', 'CGPA': '3.8'},
    {'Name': 'Majeed', 'Attendance': '95%', 'GPA': '4.0', 'CGPA': '4.0'},
  ];

 
  void _updateStudentData(int index, String field, String newValue) {
    setState(() {
      students[index][field] =                                   newValue;
    });
  }

 
  void _showEditDialog(int index, String field, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _updateStudentData(index, field, controller.text);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Data Grid'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Name',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Attendance',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('GPA',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('CGPA',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
          rows: students.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> student = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(student['Name']!)),
                DataCell(
                  Text(student['Attendance']!),
                  onTap: () {
                    _showEditDialog(
                        index, 'Attendance', student['Attendance']!);
                  },
                ),
                DataCell(
                  Text(student['GPA']!),
                  onTap: () {
                    _showEditDialog(index, 'GPA', student['GPA']!);
                  },
                ),
                DataCell(
                  Text(student['CGPA']!),
                  onTap: () {
                    _showEditDialog(index, 'CGPA', student['CGPA']!);
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
