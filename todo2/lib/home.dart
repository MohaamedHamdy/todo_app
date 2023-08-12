import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:todo2/SqlDB.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int index = 0;
  GlobalKey<ScaffoldState> sheetkey = GlobalKey();
  GlobalKey<FormState> formkey = GlobalKey();
  bool isShow = false;
  IconData fabicon = Icons.edit;
  SqlDB sqldb = SqlDB();
  List data = [];
  var taskcontroller = TextEditingController();
  var timecontroller = TextEditingController();
  var datecontroller = TextEditingController();
  clearText() {
    taskcontroller.clear();
    timecontroller.clear();
    datecontroller.clear();
  }

  _onTapped(value) {
    setState(() {
      index = value;
    });
  }

  @override
  void initState() {
    readdata();
    super.initState();
  }

  Future readdata() async {
    List<Map> response = await sqldb.readData("SELECT * FROM tasks");
    data.addAll(response);

    setState(() {});
  }

  Widget _bottomsheet() => SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              color: Color.fromARGB(255, 81, 61, 237),
            ),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.minimize,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: taskcontroller,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Value CANNOT be empty";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    hintText: 'Enter Task',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.title,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: timecontroller,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Value CANNOT be empty";
                    }

                    return null;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter Time',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.watch_later,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    showTimePicker(
                            context: context, initialTime: TimeOfDay.now())
                        .then((value) {
                      timecontroller.text = value!.format(context);
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: datecontroller,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Value CANNOT be empty";
                    }
                    return null;
                  },
                  onTap: () {
                    showTimePicker(
                            context: context, initialTime: TimeOfDay.now())
                        .then((value) {
                      datecontroller.text = value!.format(context);
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter Date',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      int response = await sqldb.InsertData('''
                        INSERT INTO tasks
                        (title,time,date)
                        VALUES 
                        ('${taskcontroller.text}','${timecontroller.text}','${datecontroller.text}')''');
                      print(response);
                      clearText();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => home()));
                      setState(() {
                        isShow = false;
                        fabicon = Icons.edit;
                      });
                    }
                  },
                  color: Colors.white,
                  child: const Text('Submit!'),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      key: sheetkey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isShow) {
            if (formkey.currentState!.validate()) {
              Navigator.pop(context);
              setState(() {
                isShow = false;
                fabicon = Icons.edit;
              });
            }
          } else {
            sheetkey.currentState!
                .showBottomSheet((context) => _bottomsheet())
                .closed
                .then((value) {
              setState(() {
                isShow = false;
                fabicon = Icons.edit;
              });
            });
            setState(() {
              isShow = true;
              fabicon = Icons.add;
            });
          }
        },
        child: Icon(fabicon, color: Colors.black),
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: GNav(
        selectedIndex: index,
        onTabChange: _onTapped,
        color: Colors.white,
        activeColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 81, 61, 237),
        haptic: true,
        rippleColor: Colors.blue,
        hoverColor: Colors.grey,
        iconSize: 30,
        tabBorderRadius: 15,
        gap: 8,
        tabs: const [
          GButton(
            icon: Icons.title_rounded,
            text: "New Tasks",
          ),
          GButton(
            icon: Icons.archive_rounded,
            text: 'Archived Tasks',
          ),
          GButton(
            icon: Icons.check_box_outlined,
            text: "Completed Tasks",
          ),
        ],
      ),
      body: displayData(),
    );
  }

  Widget displayData() => ListView.builder(
        shrinkWrap: true,
        itemBuilder: (conetext, index) => ListTile(
          leading: Text("${data[index]['title']}"),
          title: Text("${data[index]['time']}"),
          subtitle: Text("${data[index]['date']}"),
          trailing: IconButton(
            onPressed: () async {
              int response = await sqldb.DeleteData(
                  "DELETE FROM tasks WHERE id = ${data[index]['id']}");
              print(response);
              if (response > 0) {
                data.removeWhere(
                    (element) => element['id'] == data[index]['id']);
              }
              setState(() {});
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ),
        itemCount: data.length,
      );
  Widget dbControl() => Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () async {
                int response = await sqldb.InsertData(
                    "INSERT INTO tasks (title,time,date)VALUES('hii','123','4214')");
                print(response);
              },
              child: Text('insert'),
            ),
            MaterialButton(
              onPressed: () async {
                List<Map> response =
                    await sqldb.readData('SELECT * FROM tasks');
                print(response);
              },
              child: Text('Get'),
            ),
            MaterialButton(
              onPressed: () async {
                await sqldb.mydeldatabase();
              },
              child: Text('Delete DATABASE'),
            ),
          ],
        ),
      );
}
