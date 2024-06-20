import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todo/src/view/dashboard_screen.dart';

import '../configration/config.dart';

class login_scren extends StatefulWidget {
  const login_scren({super.key});

  @override
  State<login_scren> createState() => _login_screnState();
}

class _login_screnState extends State<login_scren> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  late SharedPreferences prefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }
  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }
  void loginUser() async{
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
      var reqBody = {
        "email":emailController.text,
        "password":passwordController.text
      };
      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(reqBody)
      );
      var jsonResponse = jsonDecode(response.body);
      if(jsonResponse['status']){
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>dashboard_screen(token: myToken)));
      }else{
        print('Something went wrong');
      }
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
                    // errorStyle: TextStyle(color: Colors.red),
                    // errorText: _isNotValidate ? 'Enter proper info' : null,
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
                    // errorStyle: TextStyle(color: Colors.red),
                    // errorText: _isNotValidate ? 'Enter proper info' : null,
                  ),
                    controller: passwordController,
                  )
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              InkWell(
                onTap: () => {
                  loginUser()
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(child: Text('Login',style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),)),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),


            ],
          )

      ),
    );
  }
}

