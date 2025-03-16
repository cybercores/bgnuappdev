import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RegistrationPage(),
    DataListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
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
              leading: Icon(Icons.app_registration),
              title: Text('Registration Form'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Saved Data'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Active';

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key = DateTime.now().toString();

      // Store user data as a JSON string
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'status': _status,
      };
      await prefs.setString(key, jsonEncode(userData));

      Fluttertoast.showToast(
        msg: "Data Saved Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {});
    }
  }

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: focusNode.hasFocus ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: labelText,
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAnimatedFormField(
                controller: _nameController,
                focusNode: FocusNode(),
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildAnimatedFormField(
                controller: _emailController,
                focusNode: FocusNode(),
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildAnimatedFormField(
                controller: _passwordController,
                focusNode: FocusNode(),
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      Text('Status:'),
                      Radio(
                        value: 'Active',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value.toString();
                          });
                        },
                      ),
                      Text('Active'),
                      Radio(
                        value: 'Inactive',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value.toString();
                          });
                        },
                      ),
                      Text('Inactive'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: _saveData,
                    child: Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          SharedPreferences prefs = snapshot.data!;
          List<String> keys = prefs.getKeys().toList();
          keys.sort((a, b) => b.compareTo(a)); // Sort keys in descending order

          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              String key = keys[index];
              String? userData = prefs.getString(key);

              if (userData == null) {
                return SizedBox.shrink(); // Skip invalid entries
              }

              // Parse the user data
              Map<String, dynamic> user =
                  Map<String, dynamic>.from(jsonDecode(userData));
              String name = user['name'] ?? '';
              String email = user['email'] ?? '';
              String password = user['password'] ?? '';
              String status = user['status'] ?? 'Inactive';

              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      status == 'Active' ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'Active' ? Icons.check : Icons.close,
                      color: status == 'Active' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $name'),
                        Text('Email: $email'),
                        Text('Password: $password'),
                        Text('Status: $status'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
