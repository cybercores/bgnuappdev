import 'package:flutter/material.dart';
import 'drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AzeemShakirBSCSF22M08',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalculatorScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Grades Page'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDataGrid(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  String _selectedOperation = 'Add';
  String _result = '';

  void _calculate() {
    double num1 = double.tryParse(_num1Controller.text) ?? 0;
    double num2 = double.tryParse(_num2Controller.text) ?? 0;

    if (_num1Controller.text.isEmpty || _num2Controller.text.isEmpty) {
      setState(() {
        _result = 'Please enter both numbers.';
      });
      return;
    }

    double result = 0;

    switch (_selectedOperation) {
      case 'Add':
        result = num1 + num2;
        break;
      case 'Subtract':
        result = num1 - num2;
        break;
      case 'Multiply':
        result = num1 * num2;
        break;
      case 'Divide':
        result = num2 != 0 ? num1 / num2 : double.infinity;
        break;
    }

    setState(() {
      _result = 'Result: $result';
    });
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _num1Controller,
              decoration: InputDecoration(
                labelText: 'Enter Number 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _num2Controller,
              decoration: InputDecoration(
                labelText: 'Enter Number 2',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedOperation,
              onChanged: (value) {
                setState(() {
                  _selectedOperation = value!;
                });
              },
              items: ['Add', 'Subtract', 'Multiply', 'Divide'].map((operation) {
                return DropdownMenuItem<String>(
                  value: operation,
                  child: Text(operation),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Submit'),
            ),
            SizedBox(height: 16),
            Text(
              _result,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
