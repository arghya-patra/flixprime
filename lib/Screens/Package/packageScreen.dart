import 'dart:convert';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class SubscriptionPackageScreen extends StatefulWidget {
  const SubscriptionPackageScreen({super.key});

  @override
  _SubscriptionPackageScreenState createState() =>
      _SubscriptionPackageScreenState();
}

class _SubscriptionPackageScreenState extends State<SubscriptionPackageScreen> {
  List<dynamic> packages = [];
  String? activePackage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPackages();
  }

  Future<void> fetchSubscriptionPackages() async {
    try {
      String url = APIData.login;
      final response = await http.post(Uri.parse(url), body: {
        'action': 'all-package',
        'authorizationToken': ServiceManager.tokenID
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          packages = data['all_package_list'];
          activePackage =
              data['userDetails']['membership'] == "P" ? "PREMIUM" : null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching packages: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Packages",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back icon color to white
        ),
      ),
      body: isLoading ? _buildShimmerLoading() : _buildTableView(),
    );
  }

  // Shimmer Effect for Loading
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[700]!,
        highlightColor: Colors.grey[500]!,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Professional Table View UI
  Widget _buildTableView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.pinkAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Plan",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("Price",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("Status",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Subscription List
          Expanded(
            child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (_, index) {
                var package = packages[index];
                bool isActive = package['name'] == activePackage;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Plan Name
                      Text(
                        package['name'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),

                      // Price
                      Text(
                        "Rs. ${package['price']}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),

                      // Status
                      isActive
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Active",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                // Handle subscription purchase
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text("Subscribe"),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
