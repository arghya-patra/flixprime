import 'dart:convert';

import 'package:flixprime_app/Components/utils.dart';
import 'package:flixprime_app/Screens/Login/changePass.dart';
import 'package:flixprime_app/Screens/Login/loginScreen.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController mobileController = TextEditingController();
  String otp = '';
  String resOtp = '';
  bool isOtpSent = false;
  bool isLoading = false;
  String? authToken;

  // void sendOtp() {
  //   if (mobileController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please enter mobile number")),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isOtpSent = true;
  //   });

  //   // TODO: Call actual API here
  //   print('Sending OTP to ${mobileController.text}');
  // }

  void verifyOtp() {
    if (otp.length == 4) {
      // TODO: Call verification API
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ChangePasswordScreen(mobile: mobileController.text)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid OTP")),
      );
    }
  }

  Future<String> sendOtp(context) async {
    setState(() {
      isLoading = true;
      //showResend = true;
    });
    String url = APIData.login;
    var res = await http.post(Uri.parse(url), body: {
      'action': 'forgot-password-otp',
      'user_name': mobileController.text,
    });
    var data = jsonDecode(res.body);
    if (data['status'] == 200) {
      print(["****", data]);
      setState(() {
        isOtpSent = true;
        resOtp = data['otp'].toString();
        authToken = data['authorizationToken'].toString();
      });
      //  startResendTimer();
    } else {
      toastMessage(message: 'Invalid data');
    }
    setState(() => isLoading = false);
    return 'Success';
  }

  Future<String> submitOtp(context) async {
    setState(() {
      isLoading = true;
      //showResend = true;
    });
    String url = APIData.login;
    var res = await http.post(Uri.parse(url), body: {
      'action': 'verify-forgot-password-otp',
      'authorizationToken': authToken!,
      'otp': otp.toString(),
    });
    var data = jsonDecode(res.body);
    if (data['status'] == 200) {
      print(["****", data]);
      setState(() {
        ServiceManager()
            .setToken('${data['userDetails']['authorizationToken']}');
        ServiceManager.tokenID = '${data['userDetails']['authorizationToken']}';
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ChangePasswordScreen(mobile: mobileController.text)),
      );
      //  startResendTimer();
    } else {
      toastMessage(message: 'Invalid data');
    }
    setState(() => isLoading = false);
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mobile Number',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
                    padding: EdgeInsets.only(left: 12.0, top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+91 ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                  hintText: 'Enter your mobile number',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    sendOtp(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send OTP',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),

              // OTP Field
              if (isOtpSent) ...[
                const Text(
                  'Enter OTP',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  onChanged: (value) => setState(() => otp = value),
                  keyboardType: TextInputType.number,
                  backgroundColor: Colors.black,
                  textStyle: const TextStyle(color: Colors.white),
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
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      submitOtp(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Submit OTP',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
