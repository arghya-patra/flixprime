import 'dart:convert';

import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  @override
  void initState() {
    nameController.text = ServiceManager.userName;
    emailController.text = ServiceManager.userEmail;
    mobileController.text = ServiceManager.userMobile;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Support", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField("Name", nameController, readOnly: true),
            const SizedBox(height: 15),
            buildTextField("Email", emailController, readOnly: true),
            const SizedBox(height: 15),
            buildTextField("Mobile", mobileController,
                keyboardType: TextInputType.phone, readOnly: true),
            const SizedBox(height: 15),
            buildTextField("Subject", subjectController),
            const SizedBox(height: 15),
            buildTextField("Message", descriptionController, maxLines: 5),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (validateForm()) {
                    sendContactUsForm();
                  }
                  // TODO: Implement form submission logic
                  print("Message Sent!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Send Message",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validateForm() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        mobileController.text.isEmpty ||
        subjectController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return false;
    }
    return true;
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> sendContactUsForm() async {
    final url = Uri.parse(APIData.login); // Replace with your API

    final Map<String, String> data = {
      "action": "support-us",
      "authorizationToken": ServiceManager.tokenID,
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "mobile": mobileController.text.trim(),
      "subject": subjectController.text.trim(),
      "message": descriptionController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        //headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        //   print(["***", response.body["message"].toString()]);
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent successfully!")),
        );
        clearFields();
        Navigator.pop(context);
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to send message. (${response.statusCode})")),
        );
      }
    } catch (e) {
      // Network error or exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    subjectController.clear();
    descriptionController.clear();
  }
}
