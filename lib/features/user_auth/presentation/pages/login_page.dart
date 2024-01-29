import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lab3/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:lab3/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:lab3/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{

  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _auth.setContext(context); // Set the context in initState
  }
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Login"),
),
body:  Center(
child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
child:  Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
"Login",
style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
),
const SizedBox(
height: 30,
),
FormContainerWidget(
  controller: _emailController,
  hintText: "Email",
  isPasswordField: false,
),
const SizedBox(
height: 30,
),
FormContainerWidget(
  controller: _passwordController,
hintText: "Password",
isPasswordField: true,
),
const SizedBox(
height: 30,
),
GestureDetector(
onTap: _signIn,
child: Container(
width: double.infinity,
height: 50,
decoration: BoxDecoration(
color: Colors.blue,
borderRadius: BorderRadius.circular(10),
),
child: const Center(child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
),
),
const SizedBox(height: 20,),
Row(mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text("Don't have an account?"),
const SizedBox(width: 5,),
GestureDetector(
onTap: (){
Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignUpPage()),(route)=>false);
},
child: const Text("Sign Up", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
)
],)
],
),)
),
);
}

  void _signIn() async{
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if(user != null){
      Fluttertoast.showToast(msg: 'User is successfully signed in ');
      print( 'User is successfully signed in ');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }else{
      print("Error");
    }

  }
}
