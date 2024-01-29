
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../global/common/toast.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late BuildContext context; // Declare context as late

  void setContext(BuildContext context) {
    this.context = context;
  }


  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch (e){
      if(e.code == 'email-already-in-use'){
        showToast(context,message: ' The email is already in use');
      }else{
        showToast(context,message:'An error occured: ${e.code}');
      }
      }
    return null;
  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch (e){
      if(e.code=='user-not-found' || e.code=='wrong-password'){
        showToast(context,message: 'Invalid email or password.');
      }else{
        showToast(context,message: 'An error occured: ${e.code}');
      }
    }
    return null;
  }


}