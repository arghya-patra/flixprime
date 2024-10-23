import 'dart:convert';

import 'package:flixprime_app/Components/buttons.dart';
import 'package:flixprime_app/Components/utils.dart';
import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Screens/Registration/registration.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OttLoginScreen extends StatefulWidget {
  @override
  _OttLoginScreenState createState() => _OttLoginScreenState();
}

class _OttLoginScreenState extends State<OttLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(255, 153, 153, 153)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // Add some spacing
          Image.asset(
            'images/flix_splash.png', // Replace with your logo or a relevant OTT image
            height: 100,
            width: MediaQuery.of(context).size.width - 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          _buildLoginForm(context, 'For Subscriber'),
        ],
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildLoginForm(BuildContext context, String userType) {
    return Center(
      child: Card(
        elevation: 12, // Add a stronger shadow for depth
        color: Colors.black54,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email/Mobile',
                  labelStyle: const TextStyle(color: Color(0xffe50916)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffe50916)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffe50916), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xffe50916)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xffe50916)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffe50916)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffe50916), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xffe50916)),
                ),
              ),
              const SizedBox(height: 40),
              isLoading
                  ? LoadingButton()
                  : ElevatedButton(
                      onPressed: () {
                        loginUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Forgot password functionality here
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xffe50916)),
                ),
              ),
              // const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()),
                  );
                },
                child: const Text(
                  'New User? Register Here',
                  style: TextStyle(color: Color(0xffe50916)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.grey), // Subtle divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to Terms of Service
                },
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Text('|', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () {
                  // Navigate to Privacy Policy
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> loginUser(context) async {
    setState(() {
      isLoading = true;
    });
    String url = APIData.login;
    var res = await http.post(Uri.parse(url), body: {
      'action': 'login',
      'email': "sganguly9@gmail.com", //emailController.text,
      'password': "12345678", //passwordController.text,
      'user_type': 'subscriber'
    });
    var data = jsonDecode(res.body);

    if (data['status'] == 200) {
      try {
        ServiceManager()
            .setToken('${data['userDetails']['authorizationToken']}');
        ServiceManager.tokenID = '${data['userDetails']['authorizationToken']}';
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
}
