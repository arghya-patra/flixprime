import 'dart:io';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  DateTime? selectedDate;
  String? gender;
  File? profileImage;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final response = await http.post(Uri.parse(APIData.login), body: {
      'action': 'get-user-details',
      'authorizationToken': ServiceManager.tokenID
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = data['userDetails'];
      print(["@@@@@@", user]);

      setState(() {
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        gender = _mapGenderCodeToLabel(user['gender']);
        selectedDate =
            user['dob'] != null ? DateTime.tryParse(user['dob']) : null;

        // Preload image if available
        if (user['image'] != null && user['image'].toString().isNotEmpty) {
          profileImage =
              null; // Keeping local image null, since we're showing network image
          profileImageUrl = user['image']; // New variable to show network image
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile")),
      );
    }
  }

  String? profileImageUrl;

  String? _mapGenderCodeToLabel(String? code) {
    switch (code) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return null;
    }
  }

  String? _mapGenderLabelToCode(String? label) {
    switch (label) {
      case 'Male':
        return 'M';
      case 'Female':
        return 'F';
      case 'Other':
        return 'O';
      default:
        return null;
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  Future<void> updateProfile() async {
    print(selectedDate?.toIso8601String());
    String formattedDate = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : '';
    final uri = Uri.parse(APIData.login);
    final request = http.MultipartRequest('POST', uri);
    request.fields['action'] = "update-profile";
    request.fields['authorizationToken'] = ServiceManager.tokenID;

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['dob'] = formattedDate ?? '';
    request.fields['gender'] = _mapGenderLabelToCode(gender) ?? '';

    if (profileImage != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', profileImage!.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print("Update Profile Response: $responseBody");

      // success
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile Updated")));
    } else {
      // failure
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // GestureDetector(
              //   onTap: pickImage,
              //   child: CircleAvatar(
              //     radius: 50,
              //     backgroundColor: Colors.grey[800],
              //     backgroundImage: profileImage != null
              //         ? FileImage(profileImage!)
              //         : (profileImageUrl != null
              //             ? NetworkImage(profileImageUrl!) as ImageProvider
              //             : null),
              //     child: profileImage == null && profileImageUrl == null
              //         ? const Icon(Icons.camera_alt, color: Colors.white)
              //         : null,
              //   ),
              // ),
              const SizedBox(height: 20),
              buildTextField("Name", nameController),
              const SizedBox(height: 12),
              buildTextField("Email", emailController),
              const SizedBox(height: 12),
              buildDatePicker(),
              const SizedBox(height: 12),
              buildGenderSelector(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateProfile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() => selectedDate = pickedDate);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          selectedDate == null
              ? "Select Date of Birth"
              : "DOB: ${selectedDate!.toLocal().toString().split(' ')[0]}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(color: Colors.white70)),
        Row(
          children: [
            buildRadioOption("Male"),
            buildRadioOption("Female"),
            buildRadioOption("Other"),
          ],
        ),
      ],
    );
  }

  Widget buildRadioOption(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: gender,
          onChanged: (val) => setState(() => gender = val.toString()),
          fillColor: MaterialStateProperty.all(Colors.red),
        ),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
