import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todoItems = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? savedItems = _prefs.getStringList('todoItems');
    if (savedItems != null) {
      setState(() {
        _todoItems.addAll(savedItems.map((item) => TodoItem.fromJson(item)));
      });
    }
  }

  void _saveTodoItems() {
    List<String> itemsToSave = _todoItems.map((item) => item.toJson()).toList();
    _prefs.setStringList('todoItems', itemsToSave);
  }

  void _addTodoItem(String task) {
    setState(() {
      _todoItems.add(TodoItem(task));
      _saveTodoItems();
    });
  }

  void _editTodoItem(int index, String newTask) {
    setState(() {
      _todoItems[index].task = newTask;
      _saveTodoItems();
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].toggleComplete();
      _saveTodoItems();
    });
  }

  void _promptAddTodoItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTask = '';
        return AlertDialog(
          title: Text('New task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newTask.isNotEmpty) {
                  _addTodoItem(newTask);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _promptEditTodoItem(int index, String task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedTask = task;
        return AlertDialog(
          title: Text('Edit task'),
          content: TextField(
            controller: TextEditingController(text: task),
            onChanged: (value) {
              editedTask = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _editTodoItem(index, editedTask);
                Navigator.of(context).pop();
              },
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
        title: Text('To-Do List'),
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          final item = _todoItems[index];
          return ListTile(
            title: Text(
              item.task,
              style: TextStyle(
                decoration: item.isComplete
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                item.isComplete ? Icons.check_box : Icons.check_box_outline_blank,
              ),
              onPressed: () => _toggleTodoItem(index),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _promptEditTodoItem(index, item.task),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeTodoItem(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddTodoItem,
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoItem {
  String task;
  bool isComplete;

  TodoItem(this.task) : isComplete = false;

  void toggleComplete() {
    isComplete = !isComplete;
  }

  String toJson() {
    return '{"task": "$task", "isComplete": $isComplete}';
  }

  factory TodoItem.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    TodoItem item = TodoItem(data['task']);
    item.isComplete = data['isComplete'];
    return item;
  }
}
