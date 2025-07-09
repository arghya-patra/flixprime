import 'dart:async';
import 'dart:convert';

import 'package:flixprime_app/Components/buttons.dart';
import 'package:flixprime_app/Components/utils.dart';
import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Screens/Login/forgotpass.dart';
import 'package:flixprime_app/Screens/Registration/regStep1.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordLogin = false;
  bool isOtpSent = false;
  String otp = '';
  bool isLoading = false;
  String? resOtp = '';

  int resendCooldown = 20;
  bool canResendOtp = false;
  Timer? _timer;
  bool showResend = false;

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    showResend = false;
    super.initState();
  }

  void startResendTimer() {
    setState(() {
      resendCooldown = 60;
      canResendOtp = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendCooldown == 0) {
        timer.cancel();
        setState(() {
          canResendOtp = true;
        });
      } else {
        setState(() {
          resendCooldown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
            child: Column(
              children: [
                Image.asset(
                  'images/flix_splash.png',
                  height: 40,
                  width: MediaQuery.of(context).size.width - 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Mobile',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 5),
                          Text('+91 ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ),
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 18),

                // Login with password button (white)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (mobileController.text.isEmpty) {
                        toastMessage(message: 'Enter mobile number');
                        return;
                      }
                      setState(() {
                        isPasswordLogin = true;
                        isOtpSent = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Login with Password',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'OR',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Send OTP Button (red)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (mobileController.text.isEmpty) {
                        toastMessage(message: 'Enter mobile number');
                        return;
                      }
                      setState(() {
                        isPasswordLogin = false;
                        isOtpSent = true;
                      });
                      sendOtp(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Send OTP',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                if (isPasswordLogin)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),

                if (isOtpSent && !isPasswordLogin)
                  Column(
                    children: [
                      const Text('Enter OTP',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      PinCodeTextField(
                        appContext: context,
                        length: 4,
                        onChanged: (value) => setState(() => otp = value),
                        backgroundColor: Colors.black,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.grey[800],
                          inactiveFillColor: Colors.grey[800],
                          selectedFillColor: Colors.grey[800],
                          activeColor: Colors.red,
                          selectedColor: Colors.red,
                          inactiveColor: Colors.grey,
                        ),
                        textStyle: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),

                if (showResend && isOtpSent && !isPasswordLogin)
                  TextButton(
                    onPressed: canResendOtp ? () => sendOtp(context) : null,
                    child: Text(
                      canResendOtp
                          ? 'Resend OTP'
                          : 'Resend OTP in $resendCooldown sec',
                      style: TextStyle(
                          color: canResendOtp ? Colors.blue : Colors.grey),
                    ),
                  ),

                const SizedBox(height: 20),

                // Final Login button
                if (isPasswordLogin || isOtpSent)
                  SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? LoadingButton()
                        : ElevatedButton(
                            onPressed: () {
                              if (isPasswordLogin) {
                                print("Passlogin");
                                submitOtp(context, true);
                              } else {
                                print("otpLogin");
                                submitOtp(context, false);
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                  ),

                const SizedBox(height: 20),

                isPasswordLogin
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen())),
                            child: const Text('Forgot Password?',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    : Container(),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New here?',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => RegStep())),
                      child: const Text('Register',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> sendOtp(context) async {
    setState(() {
      isLoading = true;
      showResend = true;
    });
    String url = APIData.login;
    var res = await http.post(Uri.parse(url), body: {
      'action': 'login',
      'mobile': mobileController.text,
      'isd': "+91"
    });
    var data = jsonDecode(res.body);
    if (data['status'] == 200) {
      print(data);
      setState(() {
        resOtp = data['otp'].toString();
        ServiceManager().setToken('${data['authorizationToken']}');
        ServiceManager.tokenID = '${data['authorizationToken']}';
      });
      startResendTimer();
    } else {
      toastMessage(message: 'Invalid data');
    }
    setState(() => isLoading = false);
    return 'Success';
  }

  Future<String> submitOtp(context, isPass) async {
    setState(() => isLoading = true);
    String url = APIData.login;
    var otpBody = {
      'action': 'verify-login-otp',
      'authorizationToken': ServiceManager.tokenID,
      'otp': otp
    };
    var passBody = {
      'action': 'login-with-password',
      'user_name': mobileController.text,
      'password': passwordController.text
    };
    print(["*****", passBody]);

    var res =
        await http.post(Uri.parse(url), body: isPass ? passBody : otpBody);
    var data = jsonDecode(res.body);
    print(["&&&&&&", data]);
    if (data['status'] == 200) {
      ServiceManager().setUser(data['userDetails']['user_id']);
      ServiceManager.userID = data['userDetails']['user_id'];
      ServiceManager().setToken('${data['userDetails']['authorizationToken']}');
      ServiceManager.tokenID = '${data['userDetails']['authorizationToken']}';
      ServiceManager().setName(data['userDetails']['name']);
      ServiceManager.userName = data['userDetails']['name'];
      ServiceManager().setEmail(data['userDetails']['email']);
      ServiceManager.userEmail = data['userDetails']['email'];
      ServiceManager().setMobile(data['userDetails']['mobile']);
      ServiceManager.userMobile = data['userDetails']['mobile'];
      ServiceManager().setSubId(data['userDetails']['subscriber_id']);
      ServiceManager.sId = data['userDetails']['subscriber_id'];

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
        (route) => false,
      );
    } else {
      toastMessage(message: 'Invalid data');
    }
    setState(() => isLoading = false);
    return 'Success';
  }
}
