import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/src/configration/config.dart';
import 'package:todo/src/view/login_screen.dart';

import 'dashboard_screen.dart';

class register_screen extends StatefulWidget {
  const register_screen({super.key});

  @override
  State<register_screen> createState() => _register_screenState();
}

class _register_screenState extends State<register_screen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotVaidate = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

  }

  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }

  void registerUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,  // Access the text property
        "password": passwordController.text,  // Access the text property
      };

      try {
        var response = await http.post(
          Uri.parse(registration),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          print('User registered successfully');
          
          var jsonResponse = jsonDecode(response.body);
          var myToken = jsonResponse['token'];
          prefs.setBool('token', myToken);
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text('Success') ,

            );
          });
          Navigator.push(context, MaterialPageRoute(builder: (context)=>dashboard_screen(token: myToken)));
        } else {
          print('Failed to register user: ${response.body}');
          // Handle the error (e.g., show an error message)
        }
      } catch (e) {
        print('An error occurred: $e');
        // Handle exceptions (e.g., network issues)
      }
    } else {
      setState(() {
        _isNotVaidate = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),

              Center(
                child: Text('To-Do-App',style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.1,
                ),),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.06),

              Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(decoration: InputDecoration(
                    hintText: 'email',
                    icon: Icon(Icons.email),
                    errorStyle: TextStyle(color: Colors.red),
                    errorText: _isNotVaidate ? 'Enter proper info' : null,
                  ),
                    controller: emailController,
                  )
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(decoration: InputDecoration(
                    hintText: 'password',
                    icon: Icon(Icons.password),
                    errorStyle: TextStyle(color: Colors.red),
                    errorText: _isNotVaidate ? 'Enter proper info' : null,
                  ),
                    controller: passwordController,
                  )
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              InkWell(
                onTap: () => {
                  registerUser()
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(child: Text('Register',style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),)),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => login_scren()));
                },
                child: Text('already register Sign in',style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),),
              ),
            ],
          )

      ),
    );
  }
}
