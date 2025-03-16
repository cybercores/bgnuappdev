import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
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
    ),
  ));
}
