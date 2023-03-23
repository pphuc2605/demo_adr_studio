import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskList(),
      child: MaterialApp(
        title: 'Quản Lý Công Việc',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class TaskList extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void markTaskAsDone(Task task) {
    task.isDone = true;
    notifyListeners();
  }

  void markTaskAsNotDone(Task task) {
    task.isDone = false;
    notifyListeners();
  }

  void editTask(Task task, String description, DateTime deadline) {
    task.description = description;
    task.deadline = deadline;
    notifyListeners();
  }

  List<Task> get overdueTasks =>
      _tasks.where((task) => task.deadline.isBefore(DateTime.now())).toList();

  List<Task> get tasksToDo => _tasks.where((task) => !task.isDone).toList();
}

class Task {
  String description;
  DateTime deadline;
  bool isDone;

  Task(
      {required this.description, required this.deadline, this.isDone = false});
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Công Việc'),
      ),
      body: Consumer<TaskList>(
        builder: (context, taskList, child) {
          return Column(
            children: [
              SizedBox(height: 20),
              Text('Đang Làm:', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: taskList.tasksToDo.length,
                  itemBuilder: (context, index) {
                    Task task = taskList.tasksToDo[index];
                    return ListTile(
                      title: Text(task.description),
                      subtitle: Text(
                          'Deadline: ${DateFormat.yMd().add_Hm().format(task.deadline)}'),
                      trailing: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          if (value == true) {
                            taskList.markTaskAsDone(task);
                          } else {
                            taskList.markTaskAsNotDone(task);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text('Quá Hạn:', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: taskList.overdueTasks.length,
                  itemBuilder: (context, index) {
                    Task task = taskList.overdueTasks[index];
                    return ListTile(
                      
                      title: Text(
                        task.description,
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: Text(
                          'Deadline: ${DateFormat.yMd().add_Hm().format(task.deadline)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          taskList.removeTask(task);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Task? newTask = await showDialog<Task>(
            context: context,
            builder: (context) {
              String description = '';
              DateTime deadline = DateTime.now();
              return AlertDialog(
                title: Text('Thêm Công Việc Mới'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Tên công việc',
                        hintText: 'Nhập tên công việc',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Deadline:'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            deadline = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          }
                        }
                      },
                      child: Text(
                        DateFormat.yMd().add_Hm().format(deadline),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (description.isNotEmpty) {
                        Task newTask =
                            Task(description: description, deadline: deadline);
                        Navigator.pop(context, newTask);
                      }
                    },
                    child: Text('Lưu'),
                  ),
                ],
              );
            },
          );
          if (newTask != null) {
            Provider.of<TaskList>(context, listen: false).addTask(newTask);
          }
        },
        tooltip: 'Thêm Công Việc Mới',
        child: Icon(Icons.add),
      ),
    );
  }
}
