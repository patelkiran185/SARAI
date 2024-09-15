import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
    String? userType
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      User? user = userCredential.user;

      await user?.updateProfile(displayName: name);
      await user?.reload();
      user = _auth.currentUser;

      // Save phone, userType to Firestore if necessary.

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }
  
  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }



 Future<UserCredential?> registerWithGitHub(BuildContext context) async {
    try {
      // GitHub sign-in parameters
      var params = GithubSignInParams(
        clientId: 'Ov23lidczkXUiqnUJChA',
        clientSecret: 'dd1e0be5b4383720053fa4e0fbfac30e02206636',
        redirectUrl: 'https://sarai-4f66a.firebaseapp.com/__/auth/handler',
        scopes: 'read:user,user:email',
      );

      // Perform GitHub sign-in
      final response = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return GithubSigninScreen(
              params: params,
              headerColor: Colors.green,
              title: 'Register with GitHub',
            );
          },
        ),
      ) as GithubSignInResponse;

      if (response.accessToken != null) {
        // GitHub credentials
        final AuthCredential githubCredential = GithubAuthProvider.credential(response.accessToken!);
        
        // Check if user is already registered
        final UserCredential userCredential = await _auth.signInWithCredential(githubCredential);
        
        // You can also store additional user details in Firestore here if needed
        
        return userCredential;
      } else {
        print("GitHub registration failed or was canceled");
        return null;
      }
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }

  // GitHub Login
  // ignore: body_might_complete_normally_nullable
  Future<UserCredential?> loginWithGitHub(BuildContext context) async {
    try {
        var params = GithubSignInParams(
        clientId: 'Ov23lidczkXUiqnUJChA',
        clientSecret: 'dd1e0be5b4383720053fa4e0fbfac30e02206636',
        redirectUrl: 'https://sarai-4f66a.firebaseapp.com/__/auth/handler',
        scopes: 'read:user,user:email',
      );

      final response = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return GithubSigninScreen(
              params: params,
              headerColor: Colors.green,
              title: 'Login with GitHub',
            );
          },
        ),
      ) as GithubSignInResponse;

      if (response.accessToken != null) {
        final AuthCredential githubCredential = GithubAuthProvider.credential(response.accessToken!);

        try {
          UserCredential userCredential = await _auth.signInWithCredential(githubCredential);
          return userCredential;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            _handleAccountExistsError(context, e);
          } else {
            print("FirebaseAuthException: ${e.message}");
          }
        }
      } else {
        print("GitHub login failed or was canceled");
        return null;
      }
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }

  // Handle account exists error
  void _handleAccountExistsError(BuildContext context, FirebaseAuthException e) async {
    String email = e.email!;
    List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

    if (signInMethods.contains('google.com')) {
      _showDialog(context, 'Error', 'Account exists with Google. Please sign in with Google.', false);
    } else if (signInMethods.contains('password')) {
      _showDialog(context, 'Error', 'Account exists with Email. Please sign in with Email/Password.', false);
    } else {
      _showDialog(context, 'Error', 'Please sign in with the correct provider.', false);
    }
  }

  void _showDialog(BuildContext context, String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
