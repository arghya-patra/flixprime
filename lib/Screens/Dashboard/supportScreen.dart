import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';

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

  File? selectedFile;

  @override
  void initState() {
    ServiceManager().getEmail();
    ServiceManager().getMobile();
    print(ServiceManager.userName);
    print(ServiceManager.userEmail);
    print(ServiceManager.userMobile);
    nameController.text = ServiceManager.userName;
    emailController.text = ServiceManager.userEmail;
    mobileController.text = ServiceManager.userMobile;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 15),
            buildFilePicker(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (validateForm()) {
                    sendContactUsForm();
                  }
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

  Widget buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Attach File", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: pickFile,
          icon: const Icon(
            Icons.attach_file,
            color: Colors.grey,
          ),
          label: const Text(
            "Choose File",
            style: TextStyle(color: Colors.grey),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
          ),
        ),
        if (selectedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              selectedFile!.path.split('/').last,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
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

  Future<void> sendContactUsForm() async {
    final url = Uri.parse(APIData.login); // Replace with your actual API URL

    final request = http.MultipartRequest('POST', url);
    request.fields['action'] = 'support-us';
    request.fields['authorizationToken'] = ServiceManager.tokenID;
    request.fields['name'] = nameController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['mobile'] = mobileController.text.trim();
    request.fields['subject'] = subjectController.text.trim();
    request.fields['message'] = descriptionController.text.trim();

    if (selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'attachment',
        selectedFile!.path,
      ));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent successfully!")),
        );
        clearFields();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to send message (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void clearFields() {
    subjectController.clear();
    descriptionController.clear();
    setState(() {
      selectedFile = null;
    });
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
}
