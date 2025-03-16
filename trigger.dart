import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawer Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MAzeemShakirBSCSF22M08'),
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
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Display Name'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NameDisplayPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Button Page'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ButtonPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Combined Page'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CombinedPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Name Cycler Page'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NameCyclerPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Azeem Shakir'),
      ),
    );
  }
}

// Page 1: Display Name
class NameDisplayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Name'),
      ),
      body: Center(
        child: Text('Azeem Shakir'),
      ),
    );
  }
}

class ButtonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Press Me'),
        ),
      ),
    );
  }
}


class CombinedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Combined Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Azeem Shakir'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 4: Name Cycler Page
class NameCyclerPage extends StatefulWidget {
  @override
  _NameCyclerPageState createState() => _NameCyclerPageState();
}

class _NameCyclerPageState extends State<NameCyclerPage> {
  List<String> names = ['Azeem', 'Mateen', 'Waleed'];
  int currentIndex = 0;

  void _cycleName() {
    setState(() {
      currentIndex = (currentIndex + 1) % names.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Cycler Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(names[currentIndex]),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cycleName,
              child: Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
