import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:todo/src/configration/config.dart';
import 'dart:math';


class dashboard_screen extends StatefulWidget {
  final String token;
  const dashboard_screen({required this.token, Key? key}): super(key: key);

  @override
  State<dashboard_screen> createState() => _dashboard_screenState();
}

class _dashboard_screenState extends State<dashboard_screen> {
  late String email;
  late String userId;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List? items;

  @override
  void initState(){
    super.initState();

    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    email = jwtDecodedToken['email'];
    userId = jwtDecodedToken['_id'];
   getTodoList(userId);


  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      170,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }


  void saveToDo() async {
    if(titleController.text.isNotEmpty && descriptionController.text.isNotEmpty){
      var regBody = {
        "userId":userId,
        "title": titleController.text,
        "desc": descriptionController.text,
      };
      titleController.clear();
      descriptionController.clear();

      var response = await http.post(
        Uri.parse(storeToDo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );
      if( response.statusCode == 200){
        print('info is saved at db');
        getTodoList(userId);
      }else {
        print('failed to store info at db');
      }
    }
  }

  void getTodoList(userId) async {
   var regBody = {
     "userId": userId,
   };

   var response = await http.post(Uri.parse(getToDoList),
     headers: {'Content-Type': 'application/json'},
     body: jsonEncode(regBody)
   );

   var jsonResponse = jsonDecode(response.body);
   items = jsonResponse['success'];
   setState(() {});
  }
  
  void deleteTodo (id) async {
    var regBody = {
      "id":id,
    };

    var response = await http.delete(Uri.parse(deleteToDo),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(regBody)
    );

    var jsonResponse  = jsonDecode(response.body);

    if (jsonResponse['status']) {
      getTodoList(userId);
    };
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title:  Text('TOD0 - List',style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 30,
            fontWeight: FontWeight.bold
        ),),
        leading: InkWell(
          onTap: (){
            showDialog(context: context, builder: (BuildContext contest ){
              return AlertDialog(
                title: Text('Email-id'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(email),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                ],
              );
            },
            );
          },
            child: Icon(Icons.account_circle,color: Colors.grey.shade300,size: 40,)),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

           SizedBox(height: 30),
            Expanded(
              child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: items == null ? null : ListView.builder(
                      itemCount:  items?.length,
                        itemBuilder: (context, int index){
                          return Slidable(
                             key:  const ValueKey(0),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(
                                  onDismissed:  () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Task Deleted Successfully'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    setState(() {
                                      deleteTodo('${items![index]['_id']}');
                                      items!.removeAt(index); // Remove the item from the list or update your data structure
                                    });
                                  },
                              ),
                              children: [
                                SlidableAction(
                                   backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon:  Icons.delete,
                                  label: 'Delete',
                                  onPressed: (BuildContext context) {
                                     print('${items![index]['_id']}');
                                     deleteTodo('${items![index]['_id']}');
                                  },
              
                                ),
                              ],
                            ), child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    height: 150,
                                    width: 380,
                                    decoration: BoxDecoration(
                                        color: getRandomColor(),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [BoxShadow(
                                          color: Colors.grey.shade700,
                                          blurRadius:10,
                                        ),]
                                    ),
                                    child: Center(
                                      child: ListTile(
                                        leading: Icon(Icons.task,color: Colors.grey.shade200,),
                                        title: Text('Title: ${items![index]['title']}',maxLines: 10,style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30, color: Colors.grey.shade900),),
                                        subtitle: Text('Description: ${items![index]['description']}',maxLines: 10,style: TextStyle(fontSize: 20, color: Colors.grey.shade300)),
                                        trailing: Icon(Icons.delete,color: Colors.grey.shade200,),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          );
                        }),
                  ),
            ),

          ],

        ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () =>
          _displayTextInputDialog(context, titleController, descriptionController, saveToDo, () => getTodoList(userId) ),
        child: Icon(Icons.add,color: Colors.white, size: 40,),
        backgroundColor: Colors.pinkAccent,
        shape: CircleBorder (),

        tooltip: 'Add-ToDo',
      ),



    );
  }
}

Future<void> _displayTextInputDialog(BuildContext context, TextEditingController titleController, TextEditingController descriptionController, Function saveToDo, Function refreshList) async {
  return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Add To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
          decoration: InputDecoration(
          filled: true,
              fillColor: Colors.white,
              hintText: "Title",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                controller: titleController,
              ),

              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),

              SizedBox(height: 10),
              ElevatedButton(onPressed: (){saveToDo(); Navigator.of(context).pop();  refreshList();}, child: Text('Add'))
            ],
          ),
        );

  });
}
