import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static Future<void> signUp(String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw error.message.toString();
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> signIn(String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw error.message.toString();
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("role");
    } on FirebaseAuthException catch (error) {
      throw error.message.toString();
    } catch (error) {
      rethrow;
    }
  }
}
