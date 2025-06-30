import 'dart:convert';
import 'dart:io';
import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:webview_flutter/webview_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedGender;
  DateTime? selectedDate;
  bool isTermsAccepted = false;
  bool isLoading = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _register(context) async {
    setState(() => isLoading = true);
    try {
      print(["&&&&&&", ServiceManager.tokenID]);
      final uri = Uri.parse("https://flixprime.in/app-api.php");
      final request = http.MultipartRequest('POST', uri)
        ..fields['action'] = 'register-step2'
        ..fields['authorizationToken'] = ServiceManager.tokenID
        ..fields['name'] = fullNameController.text
        ..fields['email'] = emailController.text
        ..fields['gender'] = selectedGender ?? ''
        ..fields['term'] = "1"
        ..fields['dob'] = selectedDate?.toIso8601String() ?? '';

      if (_selectedImage != null) {
        print("YUYUYU");
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          filename: path.basename(_selectedImage!.path),
        ));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print(respStr);

      if (response.statusCode == 200) {
        // Parse the response data
        final Map<String, dynamic> responseData = json.decode(respStr);
        print("Registration successful: $responseData");

        // You can check for specific fields in the response
        if (responseData['status'] == '200' ||
            responseData['isSuccess'] == true) {
          // Handle success (e.g., navigate to another screen)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );
          ServiceManager()
              .setToken('${responseData['userDetails']['authorizationToken']}');
          ServiceManager.tokenID =
              '${responseData['userDetails']['authorizationToken']}';
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false);
          // Navigate to another screen if needed
        } else {
          // Handle error (e.g., show error message)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? 'Registration failed')),
          );
        }
      } else {
        print("Failed to register: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register')),
        );
      }
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.red,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : null,
                            child: _selectedImage == null
                                ? const Icon(Icons.add_a_photo,
                                    size: 30, color: Colors.black)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Full Name', fullNameController),
                      const SizedBox(height: 20),
                      _buildTextField('Email', emailController,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),
                      _buildGenderDropdown(),
                      const SizedBox(height: 20),
                      _buildDatePicker(context),
                      const SizedBox(height: 20),
                      _buildTermsAndConditionsRow(),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _register(context);
                          },
                          // isTermsAccepted &&
                          //      _formKey.currentState!.validate()
                          //?

                          //: null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: const Text('Register',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        if (label == 'Email' &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (label == 'Mobile' && value.length != 10) {
          return 'Enter a valid mobile number';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password should be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.grey)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedGender = newValue;
        });
      },
      validator: (value) => value == null ? 'Select a gender' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? 'Date of Birth'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionsRow() {
    return Row(
      children: [
        Checkbox(
          value: isTermsAccepted,
          onChanged: (value) {
            if (value == true) {
              _showTermsPopup(context);
            } else {
              setState(() {
                isTermsAccepted = false;
              });
            }
          },
          checkColor: Colors.black,
          activeColor: Colors.white,
        ),
        GestureDetector(
          onTap: () => _showTermsPopup(context),
          child: const Text(
            'Accept Terms and Conditions',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(
                          "https://flixprime.in/info/terms-and-conditions"),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isTermsAccepted = true;
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Accept & Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
    );
  }

  Widget _buildShimmerEffect() {
    return Column(
      children: List.generate(6, (index) => _buildShimmerItem()),
    );
  }

  Widget _buildShimmerItem() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(height: 20, width: double.infinity, color: Colors.grey[300]),
      ],
    );
  }
}

// Dummy Terms and Conditions Screen
class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Here are the terms and conditions...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
