// ignore: file_names
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:assignment_application/reusable_widget.dart';
import 'package:assignment_application/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:assignment_application/loginscreen.dart';

String email = '';
String countryCode = '+1'; // Default country code

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _countryCodeTextController =
      TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  // List of country codes
  List<String> countryCodes = [
    '+1',
    '+91',
    '+44',
    '+81',
    '+91',
  ];
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _acceptedTerms = false; // Initialize the variable to false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Let Us know more ",
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("FFFFFF"),
          hexStringToColor("FFFFFF"),
          hexStringToColor("FFFFFF")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Enter Email",
                          labelText: "Email",
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _passwordTextController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            hintText: "Enter Password", labelText: "Password"),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _userNameTextController,
                        decoration: const InputDecoration(
                          hintText: "Enter User Name",
                          labelText: "User Name",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _countryCodeTextController,
                        decoration: const InputDecoration(
                          hintText: "Enter Country Code",
                          labelText: "Country Code",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _phoneNumberTextController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "Enter Phone Number",
                          labelText: "Phone Number",
                        ),
                      ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  title: const Text("Accept Terms and Conditions"),
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value!;
                    });
                  },
                ),
                SigninSignUpButton(context, false, () {
                  if (_acceptedTerms) {
                    validEmail();
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please accept the terms and conditions",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validEmail() {
    final bool isValid =
        EmailValidator.validate(_emailTextController.text.trim());
    if (isValid) {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text.trim(),
              password: _passwordTextController.text)
          .then((value) {
        email = _emailTextController.text.trim();
        // Get phone number and country code from text controllers
        String phoneNumber = _phoneNumberTextController.text.trim();
        String countryCode = _countryCodeTextController.text.trim();
        String userName = _userNameTextController.text.trim();

        // Add phone number and country code to user profile
        User? user = FirebaseAuth.instance.currentUser;
        // ignore: deprecated_member_use
        user?.updateProfile(displayName: userName);
        FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '$countryCode$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
          codeSent: (String verificationId, int? resendToken) {},
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignInScreen()));
      }).catchError((error) {
        if (kDebugMode) {
          print("Error ${error.toString()}");
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "Enter Valid Email Address",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
