import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Todo {
  String text;
  bool isDone;
  DateTime reminderDate;

  Todo(this.text, this.isDone, this.reminderDate);
}

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Kullanıcı Adı',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Şifre',
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Basit bir giriş kontrolü
                if (_usernameController.text == 'bilge' &&
                    _passwordController.text == '1234') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TodoListPage()),
                  );
                } else {
                  // Hatalı giriş durumunda kullanıcıyı bilgilendir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hatalı kullanıcı adı veya şifre.'),
                    ),
                  );
                }
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  List<Widget> _stars = [];
  TextEditingController _todoController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo List'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Drawer'ı kapat
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TodoApp()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/user_avatar.png'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bilge', // Değiştirilen isim
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'bilge@gmail.com', // E-posta adresi eklendi
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notes),
              title: Text('Notlar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NoteListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Takvim'),
              onTap: () {
                Navigator.pop(context);
                _showCalendar();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_todos[index].text),
                      subtitle: Text(
                          'Hatırlatma Tarihi: ${_formatDate(_todos[index].reminderDate)}'),
                      trailing: _todos[index].isDone
                          ? const Icon(Icons.done)
                          : const Icon(Icons.check_box_outline_blank),
                      onTap: () {
                        _toggleTodo(index);
                      },
                      onLongPress: () {
                        _removeTodo(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          ..._stars,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _toggleTodo(int index) {
    setState(() {
      if (!_todos[index].isDone) {
        _todos[index].isDone = true;
        _generateStar();
      }
    });
  }

  void _generateStar() {
    final random = Random();
    final position = Offset(
      random.nextDouble() * MediaQuery.of(context).size.width,
      random.nextDouble() * MediaQuery.of(context).size.height,
    );

    final star = Positioned(
      left: position.dx,
      top: position.dy,
      child: Icon(
        Icons.star,
        color: Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ),
        size: random.nextDouble() * 30 + 10,
      ),
    );

    setState(() {
      _stars.add(star);
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _showAddNoteDialog(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      String? enteredText = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Not Ekle'),
            content: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Başlık',
                  ),
                ),
                TextField(
                  controller: _todoController,
                  decoration: InputDecoration(
                    hintText: 'Notunuzu buraya ekleyin',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Hatırlatma Tarihi: ${_formatDate(selectedDate)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, _titleController.text);
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );

      if (enteredText != null && enteredText.isNotEmpty) {
        setState(() {
          _todos.add(Todo(enteredText, false, selectedDate));
        });
      }
      _todoController.clear();
      _titleController.clear();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showCalendar() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              TableCalendar(
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2032, 12, 31), // 10 yıl
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    return Positioned(
                      right: 0,
                      bottom: 0,
                      child: _buildReminderMarkers(day),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildNoteListForSelectedDay(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderMarkers(DateTime day) {
    final remindersCount = _getRemindersCountForDay(day);

    if (remindersCount == 0) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        remindersCount.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  int _getRemindersCountForDay(DateTime day) {
    return _todos.where((todo) => isSameDay(todo.reminderDate, day)).length;
  }

  Widget _buildNoteListForSelectedDay() {
    final selectedDayTodos = _todos
        .where((todo) => isSameDay(todo.reminderDate, _selectedDay))
        .toList();

    if (selectedDayTodos.isEmpty) {
      return Center(
        child: Text('Bu gün için not bulunmamaktadır.'),
      );
    }

    return ListView.builder(
      itemCount: selectedDayTodos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(selectedDayTodos[index].text),
          subtitle: Text(
            'Hatırlatma Tarihi: ${_formatDate(selectedDayTodos[index].reminderDate)}',
          ),
          onTap: () {
            // İsterseniz burada not üzerinde yapmak istediğiniz işlemleri gerçekleştirebilirsiniz.
          },
        );
      },
    );
  }
}

class NoteListPage extends StatelessWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Notlar'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Drawer'ı kapat
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TodoApp()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/user_avatar.png'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bilge', // Değiştirilen isim
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'bilge@gmail.com', // E-posta adresi eklendi
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notes),
              title: Text('Notlar'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NoteListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Takvim'),
              onTap: () {
                Navigator.pop(context);
                // Takvim sayfasını buraya ekleyebilirsiniz.
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Notlar burada görüntülenecek'),
      ),
    );
  }
}

