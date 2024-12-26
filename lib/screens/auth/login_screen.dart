import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../main.dart';
import '../../../helper/dialogs.dart';
import '../../helper/api.dart';
import '../../helper/constants.dart';
import '../../models/main_user.dart';
import '../../widgets/custom_title.dart';
import '../home_screen.dart';

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
  UserType _userType = UserType.others;

  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

  void _switchUserType(bool isOthers) {
    if (isOthers) {
      setState(() {
        _userType = UserType.vendor;
      });
    } else {
      setState(() {
        _userType = UserType.others;
      });
    }
  }

  _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        await APIs.firestore
            .collection('users')
            .doc(APIs.user.uid)
            .update({'isVerified': true});
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const HomeScreen()));
      } else {
        await FirebaseAuth.instance.signOut();
        Dialogs.showErrorSnackBar(context, 'Email not verified.');
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

  _signup() async {
    if ((_collegeController.text.trim().isEmpty ||
            _nameController.text.trim().isEmpty ||
            _phoneController.text.trim().isEmpty ||
            _emailController.text.trim().isEmpty ||
            _passwordController.text.trim().isEmpty ||
            _confirmPasswordController.text.trim().isEmpty) ||
        ((_yearController.text.trim().isEmpty &&
                _userType == UserType.others) ||
            (_shopController.text.trim().isEmpty &&
                _userType == UserType.vendor))) {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      Dialogs.showErrorSnackBar(context, 'Re-enter same password.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((value) async {
        final mainUser = MainUser(
          id: APIs.user.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          pushToken: '',
          college: _collegeController.text.trim(),
          name: _nameController.text.trim(),
          year: _yearController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          customers: [],
          isVerified: false,
        );
        await APIs.createUser(mainUser);
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
                  Text('Verification link sent to your email.',
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

  _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter your email.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim())
          .then((value) => Dialogs.showSnackBar(
              context, 'Password reset link sent to your email.'));
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

  _requestForCollegeRegistration() {
    if (_collegeController.text.trim().isEmpty) {
      Dialogs.showErrorSnackBar(context, 'Enter college name.');
      return;
    }
    Dialogs.showSnackBar(context, 'Request sent to the developer.');
  }

  Widget _customTextFormField({
    required TextEditingController controller,
    required TextInputType textInputType,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      cursorColor: Colors.blue,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        hintText: controller == _yearController ? 'eg. 2026' : null,
        hintStyle: const TextStyle(fontWeight: FontWeight.bold),
        labelText: labelText,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _collegeController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    _shopController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .1,
              right: mq.width * .1,
              top: _authMode == AuthMode.signUp
                  ? mq.height * .045
                  : mq.height * .1),
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
                const SizedBox(height: 20),
                Text(
                  _authMode == AuthMode.logIn
                      ? 'Login Here'
                      : _authMode == AuthMode.signUp
                          ? 'Register Here'
                          : _authMode == AuthMode.reset
                              ? 'Reset Password'
                              : 'College Registration',
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
                          ? 'Following details are necessary for registration'
                          : _authMode == AuthMode.reset
                              ? 'Enter your registered email to get password reset link'
                              : 'Enter your college name to request for registration',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: mq.height * .03),
                if (_authMode == AuthMode.signUp)
                  Card(
                    color: Colors.amber,
                    child: ListTile(
                      title: const Text(
                        'Do you have a SHOP ?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Switch.adaptive(
                        activeColor: Colors.white,
                        activeTrackColor: Colors.blue,
                        value: _userType == UserType.others ? false : true,
                        onChanged: _switchUserType,
                      ),
                    ),
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 10),
                if (_authMode == AuthMode.signUp)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        const Text(
                          "Once saved, these sections can't be changed further !",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.trim().isEmpty) {
                              _collegeController.clear();
                              return const Iterable<String>.empty();
                            }
                            return _colleges.where((college) => college
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          initialValue: TextEditingValue(
                              text: _collegeController.text.trim()),
                          onSelected: (String selection) {
                            _collegeController.text = selection;
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            // textEditingController.text =
                            //     _collegeController.text.trim();
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
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
                                    borderSide: const BorderSide(
                                        color: Colors.lightBlue),
                                  ),
                                ));
                          },
                        ),
                        const SizedBox(height: 12),
                        _customTextFormField(
                            controller: _nameController,
                            textInputType: TextInputType.name,
                            labelText: _userType == UserType.others
                                ? 'Name'
                                : 'Vendor Name'),
                        const SizedBox(height: 12),
                        _customTextFormField(
                            controller: _userType == UserType.others
                                ? _yearController
                                : _shopController,
                            textInputType: _userType == UserType.others
                                ? TextInputType.number
                                : TextInputType.name,
                            labelText: _userType == UserType.others
                                ? 'Final Year'
                                : 'Shop Name'),
                      ],
                    ),
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                if (_authMode == AuthMode.signUp)
                  _customTextFormField(
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                    labelText: 'Phone no.',
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                _customTextFormField(
                  controller: _authMode == AuthMode.collegeNotRegistered
                      ? _collegeController
                      : _emailController,
                  textInputType: _authMode == AuthMode.collegeNotRegistered
                      ? TextInputType.name
                      : TextInputType.emailAddress,
                  labelText: _authMode == AuthMode.collegeNotRegistered
                      ? 'College Name'
                      : 'Email',
                ),
                const SizedBox(height: 12),
                if (_authMode == AuthMode.logIn || _authMode == AuthMode.signUp)
                  TextFormField(
                    obscureText: obstructPassword,
                    controller: _passwordController,
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
                      child: Text('Forgot Password ?',
                          style: TextStyle(color: Colors.red.shade600)),
                    ),
                  ),
                if (_authMode == AuthMode.signUp) const SizedBox(height: 12),
                if (_authMode == AuthMode.signUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.signUp,
                    obscureText: obstructConfirmPassword,
                    controller: _confirmPasswordController,
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
                            ? _login()
                            : _authMode == AuthMode.signUp
                                ? _signup()
                                : _authMode == AuthMode.reset
                                    ? _resetPassword()
                                    : _requestForCollegeRegistration(),
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
                                : _authMode == AuthMode.reset
                                    ? 'Send Link'
                                    : 'Request for registration'),
                      ),
                const SizedBox(height: 25),
                Text(
                  _authMode == AuthMode.logIn
                      ? 'Don\'t have an account ?'
                      : _authMode == AuthMode.signUp
                          ? 'Already have an account ?'
                          : _authMode == AuthMode.reset
                              ? 'Don\'t want to reset password ?'
                              : 'College already registered ?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    if (_authMode == AuthMode.signUp) {
                      setState(() {
                        _authMode = AuthMode.logIn;
                      });
                    } else {
                      setState(() {
                        _authMode = AuthMode.signUp;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${_authMode == AuthMode.signUp ? 'LOGIN' : 'SIGN-UP'} INSTEAD',
                    style: const TextStyle(
                        color: Colors.lightBlue,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (_authMode != AuthMode.collegeNotRegistered)
                  const SizedBox(height: 10),
                if (_authMode != AuthMode.collegeNotRegistered)
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: ListTile(
                      title: const Text(
                        'If your COLLEGE is not registered in this app',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _authMode = AuthMode.collegeNotRegistered;
                            });
                          },
                          style: const ButtonStyle(
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.black),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.amber),
                          ),
                          child: const Text(
                            'CLICK HERE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
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
