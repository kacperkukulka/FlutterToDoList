import 'package:flutter/material.dart';
import 'package:lista_zadan/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labirynt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskList(),
    );
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final Map<int, Color> priorityColor = {
    1: const Color.fromARGB(255, 144, 252, 147),
    2: const Color.fromARGB(255, 240, 253, 138),
    3: const Color.fromARGB(255, 252, 167, 167),
  };

  @override
  Widget build(BuildContext context) {
    // tasks.add(Task(name: 'task1', description: 'description1', startTime: DateTime.now(), priority: 1));
    // tasks.add(Task(name: 'task2', description: 'description2', startTime: DateTime.now(), priority: 2));
    // tasks.add(Task(name: 'task3', description: 'description3', startTime: DateTime.now(), priority: 3));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista zadań'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => 
                AddOrEditTaskView(
                  task: Task(
                    name: "",
                    description: "",
                    priority: 1,
                    startTime: DateTime.now()
                  ),
                  isNew: true,
                )
            )
          ),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Task>>(
        future: DatabaseHelper.instance.getTasks(),
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if(!snapshot.hasData){
            return const Center(child: Text('Pobieranie danych...'));
          }
          return snapshot.data!.isEmpty
          ? const Center(child: Text('Brak zadań. Dodaj jakieś zadanie'),)
          : ListView(
            children: snapshot.data!.map((task) {
              return Card(
                color: priorityColor[task.priority],
                child: ListTile(
                  title: Text(task.name),
                  trailing: Text(
                    "${task.startTime.year.toString()}-"
                    "${task.startTime.month.toString().padLeft(2,'0')}-"
                    "${task.startTime.day.toString().padLeft(2,'0')}"
                  ),
                  onTap: () => 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddOrEditTaskView(
                          task: task, 
                          isNew: false
                        )
                      )
                    ),
                  onLongPress: () async {
                    await DatabaseHelper.instance.remove(task.id!).then((e){
                      setState(() {});
                    });
                  }
                ),
              );
            }).toList()
          );
        },
      ),
    );       
  }
}

class AddOrEditTaskView extends StatefulWidget {
  const AddOrEditTaskView({super.key, required this.task, required this.isNew});

  final Task task;
  final bool isNew;

  @override
  State<AddOrEditTaskView> createState() => _AddOrEditTaskViewState();
}

class _AddOrEditTaskViewState extends State<AddOrEditTaskView> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late DateTime dateController;
  int priorityController = 1;
  late String addOrEditButtonLabel;

  @override
  void initState() {
    if(widget.isNew){ addOrEditButtonLabel = "Dodaj"; }
    else { addOrEditButtonLabel = "Edytuj"; }

    nameController.text = widget.task.name;
    descriptionController.text = widget.task.description;
    dateController = widget.task.startTime.copyWith();
    priorityController = widget.task.priority;
    super.initState();
  }

  // final TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zadanie'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Nazwa:',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20,),
            const Text('Opis:',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            TextField(
              controller: descriptionController,
              minLines: 7,
              maxLines: 7,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20,),
            const Text('Data rozpoczęcia:',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            Text(
              "${dateController.year.toString()}-"
              "${dateController.month.toString().padLeft(2,'0')}-"
              "${dateController.day.toString().padLeft(2,'0')} "
              "${dateController.hour.toString().padLeft(2,'0')}:"
              "${dateController.minute.toString().padLeft(2,'0')}"
            ),
            const SizedBox(height: 10,),
            FilledButton(
              onPressed: () async {
                await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime(1970), 
                  lastDate: DateTime(3000)
                ).then((newDate) async {
                  if(newDate != null){
                    TimeOfDay? newTime = await showTimePicker(
                      context: context, 
                      initialTime: TimeOfDay.now(),
                    );
                    if(newTime != null){
                      setState((){
                        dateController = DateTime(
                          newDate.year,
                          newDate.month,
                          newDate.day,
                          newTime.hour,
                          newTime.minute,
                          0,0,0
                        );
                      });
                    }
                  }
                });
              }, 
              child: const Text('Zmień datę'),
            ),
            const SizedBox(height: 20,),
            const Text('Priorytet:',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('1'),
                    value: 1, 
                    groupValue: priorityController, 
                    onChanged: (value){ setState(() {
                        priorityController = value!;
                      });
                    }
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('2'),
                    value: 2, 
                    groupValue: priorityController, 
                    onChanged: (value){ setState(() {
                        priorityController = value!;
                      });
                    }
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('3'),
                    value: 3, 
                    groupValue: priorityController, 
                    onChanged: (value){ setState(() {
                        priorityController = value!;
                      });
                    }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            FilledButton(
              onPressed: () async {
                Task newTask = Task(
                  id: widget.task.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  startTime: dateController,
                  priority: priorityController
                );
                if(widget.isNew){
                  await DatabaseHelper.instance.add(newTask)
                    .then((_) => {
                      Navigator.pop(context),
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskList()
                        )
                      )
                    }
                  );
                }
                else{
                  await DatabaseHelper.instance.update(newTask)
                    .then((_) => {
                      Navigator.pop(context),
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskList()
                        )
                      )
                    }
                  );
                }
              }, 
              child: Text(addOrEditButtonLabel))
          ],
        ),
      ),
    );
  }
}