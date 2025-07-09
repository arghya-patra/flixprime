import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixprime_app/Screens/Dashboard/homeView.dart';
import 'package:flixprime_app/Screens/Dashboard/videoDetails.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({Key? key}) : super(key: key);

  @override
  State<DashboardOverviewScreen> createState() =>
      _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboardOverview();
  }

  Future<Map<String, dynamic>> fetchDashboardOverview() async {
    final url = Uri.parse(APIData.login);
    final response = await http.post(url, body: {
      'action': 'dashboard-overview',
      'authorizationToken': ServiceManager.tokenID
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Dashboard Overview",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text("No data found",
                    style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;
          final user = data['userDetails'];
          final overview = data['dashboardOverview'];
          final rentList = data['rent_video_list'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(user),
                const SizedBox(height: 20),
                _buildOverviewCard(overview),
                const SizedBox(height: 20),
                if (rentList.isNotEmpty)
                  _buildRentList(rentList)
                else
                  Text(
                    "You have no rented videos.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                user['image'] != null && user['image'].toString().isNotEmpty
                    ? NetworkImage(user['image'])
                    : null,
            child: user['image'] == null || user['image'].toString().isEmpty
                ? const Icon(Icons.person, size: 35, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Email: ${user['email']}",
                    style: const TextStyle(color: Colors.white70)),
                Text("Mobile: ${user['isd']} ${user['mobile']}",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> overview) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade600, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Plan",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _infoRow("Plan", overview['plan']),
          _infoRow("Price", overview['price']),
          _infoRow("Status", overview['is_plan_active']),
          if (overview.containsKey('valid_till'))
            _infoRow("Valid Till", overview['valid_till']),
          if (overview.containsKey('time')) _infoRow("Time", overview['time']),
        ],
      ),
    );
  }

  Widget _buildRentList(List<dynamic> rentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Rent",
          style: TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rentList.length,
            itemBuilder: (context, index) {
              final item = rentList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VideoDetailsScreen(id: item['id'])),
                  );
                },
                child: Container(
                  width: 107,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 103, 82, 82),
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item['thumbnail'],
                                  placeholder: (_, __) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(
                                      Icons.error,
                                      color: Colors.red),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                if (item['content_type'] != 'Premium')
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: ClipPath(
                                      clipper: CornerTriangleClipper(),
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        color: item['content_type'] == 'Free'
                                            ? Colors.yellow[700]
                                            : Colors.red,
                                        child: Align(
                                          alignment: const Alignment(0.7, -0.5),
                                          child: Transform.rotate(
                                            angle: 0.785398, // 45 degrees
                                            child: Text(
                                              item['content_type'] ?? '',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: item['content_type'] ==
                                                        'Rent'
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text("$label:",
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label == 'Price' ? "Rs. $value" : value ?? "N/A",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
