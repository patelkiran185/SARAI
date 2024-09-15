import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:sarai/screens/otp_screen.dart';
import 'package:sarai/screens/phone_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/Password register
  Future<UserCredential?> registerWithEmailAndPassword(String email,
      String password, String name, String phone, String? userType) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
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

  // Email/pasword Login
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      print("General error: $e");
      return null;
    }
  }

  //  Github register

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
        final AuthCredential githubCredential =
            GithubAuthProvider.credential(response.accessToken!);

        // Check if user is already registered
        final UserCredential userCredential =
            await _auth.signInWithCredential(githubCredential);

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

  // Github Login

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
        final AuthCredential githubCredential =
            GithubAuthProvider.credential(response.accessToken!);

        try {
          UserCredential userCredential =
              await _auth.signInWithCredential(githubCredential);
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

  // Google register

  final EmailOTP _emailOtp = EmailOTP();

  Future<void> registerWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await addUserToFirestore(user);
        _emailOtp.setConfig(
          appEmail: 'makethon0@gmail.com',
          appName: 'sarai',
          userEmail: user.email!,
        );

        final bool otpSent = await _emailOtp.sendOTP();
        print("OTP Sent: $otpSent");

        if (otpSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpScreen(user: user),
            ),
          );
        } else {
          print("Error: Failed to send OTP");
        }
      }
    } catch (e) {
      print("Error during Google registration: $e");
    }
  }

  Future<void> addUserToFirestore(User user) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  // Google login

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        _showDialog(context, 'Error',
            'An error occurred during sign-in. Please try again.', false);
        return;
      }
      bool isRegistered = await checkUserRegistration(user.email);

      if (isRegistered) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PhoneScreen(user: user),
        ));
      } else {
        _showDialog(context, 'Registration Required',
            'This email is not registered. Please register first.', false);
      }
    } catch (e) {
      print("Error during Google login: $e");
      _showDialog(context, 'Error',
          'An error occurred during sign-in. Please try again.', false);
    }
  }

  Future<bool> checkUserRegistration(String? email) async {
    if (email == null) return false;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (e is FirebaseException) {
        print("Firestore Error Code: ${e.code}");
        print("Firestore Error Message: ${e.message}");
      }
      return false;
    } finally {
      print("Exiting checkUserRegistration function");
    }
  }

  void _handleAccountExistsError(
      BuildContext context, FirebaseAuthException e) async {
    String email = e.email!;
    bool isRegistered = await checkUserRegistration(email);

    if (isRegistered) {
      _showDialog(context, 'Error',
          'Account exists. Please sign in with the correct provider.', false);
    } else {
      _showDialog(context, 'Error',
          'No account found with this email. Please register first.', false);
    }
  }

  void _showDialog(
      BuildContext context, String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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

  generateOtp() {}
}
