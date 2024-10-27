import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../main.dart';
import '../../../helper/dialogs.dart';
import '../../helper/api.dart';
import '../../widgets/custom_title.dart';
import '../home_screen.dart';

enum AuthMode { signUp, logIn, reset }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<String> _colleges = [];
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obstructPassword = true;
  bool obstructConfirmPassword = true;
  AuthMode _authMode = AuthMode.logIn;

  TextEditingController collegeController = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    final rawData = await rootBundle.loadString('assets/csv/Engineering.csv');
    List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData);

    // Extract the first column (college names) into a list of strings
    setState(() {
      _colleges = csvData.skip(1).map((row) => row[0].toString()).toList();
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.logIn) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.logIn;
      });
    }
  }

  resetPassword() async {
    if (email.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text.trim())
          .then((value) => Dialogs.showSnackBar(
              context, 'Password reset link sent to your email!'));
    } on FirebaseAuthException catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  login() async {
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text, password: password.text);
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        await APIs.firestore
            .collection('users')
            .doc(APIs.user.uid)
            .update({'isVerified': true});
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const HomeScreen()));
      } else {
        await FirebaseAuth.instance.signOut();
        Dialogs.showErrorSnackBar(context, 'Email not verified!');
      }
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('invalid-credential')) {
        errorMessage = 'Invalid login credentials.';
      }
      Dialogs.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  signup() async {
    if (collegeController.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields!');
      return;
    }
    if (password.text.trim() != confirmPassword.text.trim()) {
      Dialogs.showErrorSnackBar(context, 'Re-enter same password!');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) async {
        await APIs.createUser(collegeController.text.trim());
        await FirebaseAuth.instance.currentUser
            ?.sendEmailVerification()
            .then((value) {
          setState(() {
            _authMode = AuthMode.logIn;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verification link sent to your email!',
                      style: TextStyle(letterSpacing: 1, color: Colors.white)),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              backgroundColor: Colors.black87,
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      });
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak (minimum 6 characters).';
      }
      Dialogs.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Dialogs.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    collegeController.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .1, right: mq.width * .1, top: mq.height * .1),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/icon.png',
                        height: mq.width * .2),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CustomTitle(),
                    ),
                  ],
                ),
                SizedBox(height: _authMode == AuthMode.signUp ? 20 : 30),
                Text(
                  _authMode == AuthMode.logIn
                      ? 'Login Here'
                      : _authMode == AuthMode.signUp
                          ? 'Register Here'
                          : 'Reset Password',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  _authMode == AuthMode.logIn
                      ? 'Login with your email-id & password'
                      : _authMode == AuthMode.signUp
                          ? 'Create your account with email-id & password'
                          : 'Enter your registered email to get password reset link',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: mq.height * .03),
                if (_authMode == AuthMode.signUp)
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _colleges.where((college) => college
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      collegeController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          keyboardType: TextInputType.name,
                          cursorColor: Colors.blue,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1),
                          decoration: InputDecoration(
                            labelText: 'College',
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.lightBlue),
                            ),
                          ));
                    },
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.blue,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_authMode != AuthMode.reset)
                  TextFormField(
                    obscureText: obstructPassword,
                    controller: password,
                    cursorColor: Colors.blue,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obstructPassword = !obstructPassword;
                          });
                        },
                        icon: Icon(obstructPassword == false
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                      labelText: 'Password',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                  ),
                if (_authMode == AuthMode.logIn)
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _authMode = AuthMode.reset;
                        });
                      },
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                if (_authMode == AuthMode.signUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.signUp,
                    obscureText: obstructConfirmPassword,
                    controller: confirmPassword,
                    cursorColor: Colors.blue,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obstructConfirmPassword = !obstructConfirmPassword;
                          });
                        },
                        icon: Icon(obstructConfirmPassword == false
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.lightBlue))
                    : ElevatedButton(
                        onPressed: () => _authMode == AuthMode.logIn
                            ? login()
                            : _authMode == AuthMode.signUp
                                ? signup()
                                : resetPassword(),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 15,
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(_authMode == AuthMode.logIn
                            ? 'Login'
                            : _authMode == AuthMode.signUp
                                ? 'Sign Up'
                                : 'Send Link'),
                      ),
                const SizedBox(height: 25),
                Text(
                  _authMode == AuthMode.logIn
                      ? 'Don\'t have an account?'
                      : _authMode == AuthMode.signUp
                          ? 'Already have an account?'
                          : 'Don\'t want to reset password?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${_authMode == AuthMode.logIn ? 'SIGN-UP' : 'LOGIN'} INSTEAD',
                    style: const TextStyle(
                        color: Colors.lightBlue,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
