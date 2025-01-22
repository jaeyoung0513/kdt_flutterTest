import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import './todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<ToDo>? toDoList;
  String? responseError;
  Future<List<ToDo>?>? futureFetchData;
  bool _isAddingTodo = false;
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureFetchData = fetchData();
  }

  Future<List<ToDo>?> fetchData() async {
    final url = Uri.parse("http://10.0.2.2:8080/todo/list");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
        json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          toDoList = jsonData.map((json) => ToDo.fromJson(json)).toList();
        });
      } else {
        setState(() {
          responseError = 'Error: ${response.statusCode}';
          toDoList = null;
        });
      }
    } catch (e) {
      setState(() {
        responseError = 'Error: $e';
        toDoList = null;
      });
    }

    return toDoList;
  }

  Future<void> addTodo(String task) async {
    final trimmedTask = task.trim();
    if (trimmedTask.isEmpty) {
      Fluttertoast.showToast(
        msg: "할 일을 입력해주세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[200],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    final url = Uri.parse("http://10.0.2.2:8080/todo");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'task': task}),
      );

      if (response.statusCode == 200) {
        fetchData();
        setState(() {
          _isAddingTodo = false;
          _todoController.clear();
        });
      } else {
        setState(() {
          responseError = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        responseError = 'Error: $e';
      });
    }
  }

  Future<void> toggleComplete(int id, bool completed) async {
    final url = Uri.parse("http://10.0.2.2:8080/todo/$id");
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completed': !completed}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        setState(() {
          responseError = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        responseError = 'Error: $e';
      });
    }
  }

  Future<void> deleteTodo(int id) async {
    final url = Uri.parse("http://10.0.2.2:8080/todo/$id");
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        fetchData();
      } else {
        setState(() {
          responseError = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        responseError = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo List"),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _isAddingTodo = !_isAddingTodo;
            });
          },
        ),
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            if (_isAddingTodo)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: const InputDecoration(
                          hintText: '할 일을 입력하세요',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        addTodo(_todoController.text);
                      },
                    ),
                  ],
                ),
              ),
            if (responseError != null)
              Text(
                responseError!,
                style: const TextStyle(color: Colors.red),
              )
            else if (toDoList == null)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: toDoList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final todo = toDoList![index];
                    return ListTile(
                      title: Text(todo.task),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              todo.completed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                              todo.completed ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              if (todo.id != null) {
                                toggleComplete(todo.id!, todo.completed);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              if (todo.id != null) {
                                deleteTodo(todo.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}