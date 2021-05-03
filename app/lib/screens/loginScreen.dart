import 'package:flutter/material.dart';
import 'signUpScreen.dart';
import 'mainPageView.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {

  final DatabaseBloc databaseBloc = DatabaseBloc();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void logIn(BuildContext context) async {
    // This function will handle authentication
    // Once authenticated, Home screen will be displayed
    final LoginEvent _event = LoginEvent(
      email: emailController.text,
      password: passwordController.text,
    );
    dynamic result = await databaseBloc.mapEventToState(_event).first;
    if (result == "Logged In") {
      // Login successful, push to MainPageView
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainPageView(databaseBloc: databaseBloc),
        )
      );
    } else {
      // Login unsuccessful
      // Show a toaster message displaying the error
      Fluttertoast.showToast(
        msg: result,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Instagram Clone",
                style: TextStyle(
                  fontFamily: "Signatra",
                  fontWeight: FontWeight.w500,
                  fontSize: 50
                ),
              ),
              SizedBox(height: 18.0),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 3.0, bottom: 3.0),
                  labelText: "Email",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5
                    ), 
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 3.0, bottom: 3.0),
                  labelText: "Password",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5
                    ), 
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              GestureDetector(
                onTap: () => logIn(context),
                child: Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 2.0,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 2.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SignUpScreen(databaseBloc: databaseBloc),
                  ));
                },
                child: Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
