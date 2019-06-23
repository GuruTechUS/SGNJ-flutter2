import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAnonAuth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInAnon() async {
      FirebaseUser user = await firebaseAuth.signInAnonymously();
      print("Signed in ${user.uid}");
      return user;
  }

  void signOut(){
      firebaseAuth.signOut();
      print("Signed out");
  }
}
