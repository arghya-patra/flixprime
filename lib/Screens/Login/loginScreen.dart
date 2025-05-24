import 'dart:convert';

import 'package:flixprime_app/Components/buttons.dart';
import 'package:flixprime_app/Components/utils.dart';
import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Screens/Registration/regStep1.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordLogin = false; // Toggle between password and OTP login
  bool isOtpSent = false; // Controls the visibility of the OTP input section
  String otp = ''; // Stores the entered OTP
  bool isLoading = false;
  String? resOtp = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'images/flix_splash.png', // Replace with your logo or a relevant OTT image
                  height: 40,
                  width: MediaQuery.of(context).size.width - 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // Login text
                const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Mobile/Email Field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mobile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon(Icons.flag, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            '+91',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Password Field (only visible when isPasswordLogin is true)
                if (isPasswordLogin)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                // OTP Field (only visible when OTP is sent and password login is not enabled)
                if (isOtpSent && !isPasswordLogin)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Enter OTP',
                        style: TextStyle(color: Colors.white),
                      ),
                      // Text(
                      //   resOtp!,
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      const SizedBox(height: 10),
                      PinCodeTextField(
                        appContext: context,
                        length: 4,
                        onChanged: (value) {
                          setState(() {
                            otp = value;
                          });
                        },
                        backgroundColor: Colors.black,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.grey[800],
                          inactiveFillColor: Colors.grey[800],
                          selectedFillColor: Colors.grey[800],
                          activeColor: Colors.yellow,
                          selectedColor: Colors.yellow,
                          inactiveColor: Colors.grey,
                        ),
                        textStyle: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Send OTP or Login button based on isPasswordLogin
                if (!isOtpSent && !isPasswordLogin)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (emailController.text.isNotEmpty) {
                          setState(() {
                            isOtpSent = true;
                          });
                          sendOtp(context);
                        } else {
                          toastMessage(message: 'Please enter credential');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                // OR section
                // const Text(
                //   'OR',
                //   style: TextStyle(color: Colors.white),
                // ),
                // const SizedBox(height: 10),
                // // Login with password/OTP button
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton(
                //     onPressed: () {
                //       setState(() {
                //         isPasswordLogin = !isPasswordLogin;
                //         isOtpSent = false; // Reset OTP when switching mode
                //       });
                //     },
                //     style: OutlinedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 15),
                //       side: const BorderSide(color: Colors.white),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //     ),
                //     child: Text(
                //       isPasswordLogin
                //           ? 'Login with OTP'
                //           : 'Login with Password',
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 18,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
                // Final Login button (visible when isPasswordLogin or isOtpSent is true)
                if (isPasswordLogin || isOtpSent)
                  SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? LoadingButton()
                        : ElevatedButton(
                            onPressed: () {
                              submitOtp(context);
                              // loginUser(context);
                              if (isOtpSent) {
                                print("Entered OTP: $otp");
                              } else {
                                print("Login with Password");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New here?',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegStep()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // // OR LOGIN WITH
                // const Text(
                //   'OR LOGIN WITH',
                //   style: TextStyle(color: Colors.white),
                // ),
                // const SizedBox(height: 10),
                // // Social Login Icons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.facebook),
                //       color: Colors.blue,
                //     ),
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.g_mobiledata),
                //       color: Colors.red,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> sendOtp(context) async {
    print("Send otp");
    setState(() {
      isLoading = true;
    });
    String url = APIData.login;
    var res = await http.post(Uri.parse(url), body: {
      'action': 'login',
      'mobile': emailController.text,
      'isd': "+91"
    });
    var data = jsonDecode(res.body);
    print(data);

    if (data['status'] == 200) {
      print(data['authorizationToken']);
      setState(() {
        resOtp = data['otp'].toString();
      });

      try {
        setState(() {
          // ServiceManager().setUser(data['userDetails']['userId']);
          // ServiceManager.userID = data['userDetails']['userId'];
          ServiceManager().setToken('${data['authorizationToken']}');
          ServiceManager.tokenID = '${data['authorizationToken']}';
        });
        // print(["*(*())", ServiceManager.tokenID]);

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (context) => DashboardScreen()),
        //     (route) => false);
      } catch (e) {
        toastMessage(message: e.toString());
        setState(() {
          isLoading = false;
        });
        toastMessage(message: 'Something went wrong');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Invalid data');
    }
    setState(() {
      isLoading = false;
    });
    return 'Success';
  }

  Future<String> submitOtp(context) async {
    setState(() {
      isLoading = true;
    });
    String url = APIData.login;
    print(["&&", ServiceManager.tokenID]);
    var res = await http.post(Uri.parse(url), body: {
      'action': 'verify-login-otp',
      'authorizationToken': ServiceManager.tokenID,
      'otp': otp
    });
    var data = jsonDecode(res.body);
    print(data);

    if (data['status'] == 200) {
      print(data['otp']);
      try {
        print("&&&&&&");
        setState(() {
          ServiceManager().setUser(data['userDetails']['user_id']);
          ServiceManager.userID = data['userDetails']['user_id'];
          ServiceManager()
              .setToken('${data['userDetails']['authorizationToken']}');
          ServiceManager.tokenID =
              '${data['userDetails']['authorizationToken']}';
          ServiceManager().setName(data['userDetails']['name']);
          ServiceManager.userName = data['userDetails']['name'];

          ServiceManager().setEmail(data['userDetails']['email']);
          ServiceManager.userEmail = data['userDetails']['email'];

          ServiceManager().setMobile(data['userDetails']['mobile']);
          ServiceManager.userMobile = data['userDetails']['mobile'];

          ServiceManager().setSubId(data['userDetails']['subscriber_id']);
          ServiceManager.sId = data['userDetails']['subscriber_id'];
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => false);
      } catch (e) {
        toastMessage(message: e.toString());
        setState(() {
          isLoading = false;
        });
        toastMessage(message: 'Something went wrong');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Invalid data');
    }
    setState(() {
      isLoading = false;
    });
    return 'Success';
  }

  // Future<String> loginUser(context) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   String url = APIData.login;
  //   var res = await http.post(Uri.parse(url), body: {
  //     'action': 'login',
  //     'email': "sganguly9@gmail.com", //emailController.text,
  //     'password': "12345678", //passwordController.text,
  //     'user_type': 'subscriber'
  //   });
  //   var data = jsonDecode(res.body);
  //   print(data);

  //   if (data['status'] == 200) {
  //     try {
  //       setState(() {
  //         ServiceManager().setUser(data['userDetails']['userId']);
  //         ServiceManager.userID = data['userDetails']['userId'];
  //         ServiceManager()
  //             .setToken('${data['userDetails']['authorizationToken']}');
  //         ServiceManager.tokenID =
  //             '${data['userDetails']['authorizationToken']}';
  //       });

  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => DashboardScreen()),
  //           (route) => false);
  //     } catch (e) {
  //       toastMessage(message: e.toString());
  //       setState(() {
  //         isLoading = false;
  //       });
  //       toastMessage(message: 'Something went wrong');
  //     }
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     toastMessage(message: 'Invalid data');
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  //   return 'Success';
  // }
}
