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
          print(["&&&&", activePackage]);
          print(["######", packages]);
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.pinkAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text("Plan",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    Expanded(
                      child: Text("Price",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    Expanded(
                      child: Text("Status",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    Expanded(
                      child: Text("Validity",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subscription List
              Expanded(
                child: ListView.builder(
                  itemCount: packages.length,
                  itemBuilder: (_, index) {
                    var package = packages[index];
                    bool isActive = package['name'] == activePackage;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isActive
                              ? Colors.greenAccent.shade100
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Plan Name
                          Expanded(
                            child: Text(
                              package['name'],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),

                          // Price
                          Expanded(
                            child: Text(
                              "₹${package['price']}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),

                          // Status
                          Expanded(
                            child: Center(
                              child: isActive
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
                                  : OutlinedButton.icon(
                                      onPressed: () {
                                        // Handle subscription purchase
                                      },
                                      icon: const Icon(Icons.shopping_cart,
                                          size: 12, color: Colors.deepPurple),
                                      label: const Text("Buy"),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.deepPurpleAccent),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        foregroundColor: Colors.deepPurple,
                                      ),
                                    ),
                            ),
                          ),

                          // Validity
                          Expanded(
                            child: Text(
                              "${package['validity']}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
