import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced State Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TextDataManager(),
    );
  }
}

class TextDataManager extends StatefulWidget {
  const TextDataManager({super.key});

  @override
  State<TextDataManager> createState() => _TextDataManagerState();
}

class _TextDataManagerState extends State<TextDataManager> {
  final TextEditingController _textController = TextEditingController();
  String _displayText = '';
  bool _isEditing = false;
  int _editIndex = -1;
  final List<String> _textList = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      if (_isEditing) {
        // Update existing item
        _textList[_editIndex] = _textController.text;
        _isEditing = false;
        _editIndex = -1;
      } else {
        // Add new item
        _textList.add(_textController.text);
      }
      _displayText = _textController.text;
      _textController.clear();
    });
  }

  void _editData(int index) {
    setState(() {
      _textController.text = _textList[index];
      _isEditing = true;
      _editIndex = index;
      _displayText = _textList[index];
    });
  }

  void _deleteData(int index) {
    setState(() {
      _textList.removeAt(index);
      if (_isEditing && _editIndex == index) {
        _isEditing = false;
        _editIndex = -1;
        _textController.clear();
        _displayText = _textList.isNotEmpty ? _textList.last : '';
      } else if (_textList.isEmpty) {
        _displayText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Text Manager'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _editIndex = -1;
                  _textController.clear();
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Edit your text' : 'Enter your text',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitData,
                ),
              ),
              onSubmitted: (_) => _submitData(),
            ),
            const SizedBox(height: 20),
            if (_displayText.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Editing Preview:' : 'Latest Submission:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: _textList.isEmpty
                  ? const Center(
                child: Text(
                  'No submissions yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _textList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_textList[index] + index.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteData(index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(_textList[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editData(index),
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
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
        onPressed: _submitData,
        child: const Icon(Icons.save),
      )
          : null,
    );
  }
}