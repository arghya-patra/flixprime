import 'dart:convert';

import 'package:flixprime_app/Screens/Dashboard/dashboard.dart';
import 'package:flixprime_app/Screens/Dashboard/dashboardOverview.dart';
import 'package:flixprime_app/Screens/Dashboard/supportScreen.dart';
import 'package:flixprime_app/Screens/Dashboard/updateProfile.dart';
import 'package:flixprime_app/Screens/Dashboard/watchlist.dart';
import 'package:flixprime_app/Screens/Login/login.dart';
import 'package:flixprime_app/Screens/Login/loginScreen.dart';
import 'package:flixprime_app/Screens/Package/packageScreen.dart';
import 'package:flixprime_app/Screens/comingsoon.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flixprime_app/Theme/style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String _profileImage = 'images/profile.jpeg'; // Initial profile image

  bool _isLoading = true;
  String _subscriberId = ServiceManager.sId;
  final String _planName = "Premium Plan";

  @override
  void initState() {
    super.initState();
    ServiceManager().getSubId();
    ServiceManager().getName();
    print(["*****", ServiceManager.sId]);
    print(["*****", ServiceManager.userName]);
    fetchData();
    _subscriberId = ServiceManager.sId;

    // if (_subscriberId == null || _subscriberId == '' || _subscriberId.isEmpty) {
    //   ServiceManager().removeAll();
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => LoginScreen()),
    //       (route) => false);
    // }
    // Simulate a loading delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> fetchData() async {
    try {
      String url = APIData.login;
      print("Request URL: $url");

      var response = await http.post(
        Uri.parse(url),
        body: {
          'action': 'home',
          'authorizationToken': ServiceManager.tokenID,
        },
      );

      print(["#### Response Body:", response.body]);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 201 &&
            responseData['isSuccess'] == "false" &&
            responseData['error'] == "Token does not exist!") {
          print("Logout: Invalid token detected.");
          ServiceManager().removeAll();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false);
          return;
        }

        setState(() {});
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<String?> logoutBuilder(BuildContext context,
      {required Function() onClickYes}) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        title: Text('Logout', style: kHeaderStyle()),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onClickYes,
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('Camera'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _profileImage = pickedFile.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album, color: Colors.orange),
                title: const Text('Gallery'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _profileImage = pickedFile.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
          onTap: onTap,
        ),
        const Divider(color: Colors.white, thickness: 0.5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 28.0),
                    child: Text(
                      "Hello",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(
                      "${ServiceManager.userName}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subscriber ID and Plan Name
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Subscriber ID: $_subscriberId",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   "Plan Name: $_planName",
                        //   style: const TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Options
                  _buildProfileOption('Dashboard', Icons.dashboard, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardOverviewScreen()),
                    );
                    // Handle Dashboard action
                  }),
                  _buildProfileOption('Update Profile', Icons.person, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpdateProfileScreen()));

                    // Handle Update Profile action
                  }),
                  _buildProfileOption('Watch List', Icons.playlist_add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WatchlistScreen()),
                    );
                    // Handle Watch List action
                  }),
                  _buildProfileOption('Package', Icons.card_membership, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPackageScreen()));

                    // Handle Package action
                  }),
                  _buildProfileOption('Support', Icons.lock, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactUsScreen()));
                    // Handle Set Password action
                  }),
                  _buildProfileOption('Logout', Icons.logout, () {
                    logoutBuilder(context, onClickYes: () {
                      try {
                        Navigator.pop(context);
                        // setState(() {
                        //   isLoading = true;
                        // });
                        ServiceManager().removeAll();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false);
                      } catch (e) {
                        // setState(() {
                        //   isLoading = false;
                        // });
                      }
                    });
                    // Handle Logout action
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerEffect() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: 150,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          width: 200,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 32),
        Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
      ],
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: const Center(
        child: Text('User Management Screen'),
      ),
    );
  }
}
