import 'package:flutter/material.dart';
import 'mainPageView.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatelessWidget {

  final DatabaseBloc databaseBloc;

  SignUpScreen({@required this.databaseBloc});
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUp(BuildContext context) async {
    // This function will create a new user in firestore
    final SignUpEvent _event = SignUpEvent(
      username: usernameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    dynamic result = await databaseBloc.mapEventToState(_event).first;
    if (result == "Created new user") {
      // Sign Up successful, push to MainPageView
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainPageView(databaseBloc: databaseBloc),
        )
      );
    } else {
      // Sign up unsuccessful
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
                controller: usernameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 3.0, bottom: 3.0),
                  labelText: "Username",
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
                onTap: () => signUp(context),
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
