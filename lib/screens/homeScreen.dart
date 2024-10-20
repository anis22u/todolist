import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/screens/Addtaskscreen.dart';
import 'package:todolist/screens/Task_Details_Screen.dart';

final _firestore = FirebaseFirestore.instance;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2a2c57),
        title: const Center(
            child: Text(
          'ToDo List',
          style: TextStyle(fontFamily: 'Matemasie'),
        )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [taskstream()],
      ),
      floatingActionButton: FloatingActionButton.large(
          elevation: 25,
          backgroundColor: Color(0xff2a2c57),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Addtask()),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// data stream from firebase
class taskstream extends StatefulWidget {
  @override
  State<taskstream> createState() => _taskstreamState();
}

class _taskstreamState extends State<taskstream> {
  List<bool> taskCompletedList = [];

  void checkboxChanged(int index, bool? newValue) {
    setState(() {
      taskCompletedList[index] = newValue ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        // No data state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'list is empty.',
              style: TextStyle(fontSize: 20, fontFamily: 'Eater'),
            ),
          ));
        }
        // Data available
        final tasks = snapshot.data!.docs;

        if (taskCompletedList.length != tasks.length) {
          taskCompletedList = List.generate(tasks.length, (index) => false);
        }

        List<taskview> taskslist = [];
        for (int i = 0; i < tasks.length; i++) {
          final taskData = tasks[i].data() as Map<String, dynamic>;
          final title = taskData['title'] ?? 'No Title';
          final description = taskData['description'] ?? 'No Description';
          final location = taskData['location'] ??
              const GeoPoint(0, 0); // Fallback GeoPoint if null
          final image = taskData['image'] ?? '';

          final taskView = taskview(
            title: title,
            description: description,
            location: location,
            image: image,
            taskcompleted: taskCompletedList[i],
            onchanged: (value) => checkboxChanged(i, value),
          );
          taskslist.add(taskView);
        }

        return Expanded(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              children: taskslist),
        ); // Return the populated widgets
      },
    );
  }
}

class taskview extends StatelessWidget {
  final String title;
  final String description;
  final GeoPoint location;
  final String image;
  final bool taskcompleted;
  final Function(bool?)? onchanged;

  taskview(
      {required this.title,
      required this.description,
      required this.location,
      required this.image,
      required this.taskcompleted,
      this.onchanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
              height: 100,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xffB0C4DE),
              ),
              child: SingleChildScrollView(
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          // Query Firestore to find the task based on title and description
                          final querySnapshot = await _firestore
                              .collection('tasks')
                              .where('title', isEqualTo: title)
                              .where('description', isEqualTo: description)
                              .get();

                          for (var doc in querySnapshot.docs) {
                            await _firestore
                                .collection('tasks')
                                .doc(doc.id)
                                .delete();
                          }
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: taskcompleted,
                            onChanged: onchanged,
                            checkColor: Colors.white,
                            activeColor: Color(0xff101229),
                            side: BorderSide(color: Color(0xff101229)),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'TITLE:   $title ',
                                style: TextStyle(
                                    fontFamily: 'GermaniaOne',
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: taskcompleted == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: Colors.black,
                                    decorationThickness: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Detail Button
                      TextButton.icon(
                        onPressed: () {
                          print(image);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => taskdetailscreen(
                                        title: title,
                                        description: description,
                                        location: location,
                                        image: image,
                                      )));
                        },
                        label: const Text(
                          'Details',
                          style: TextStyle(color: Color(0xff2a2c57)),
                        ),
                        icon: const Icon(
                          Icons.info,
                          color: Color(0xff2a2c57),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        )
      ],
    );
  }
}
