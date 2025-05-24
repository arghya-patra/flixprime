import 'package:flixprime_app/Screens/Dashboard/videoDetails.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>>? _ottData;

  @override
  void initState() {
    super.initState();
    _ottData = fetchOttData();
  }

  Future<Map<String, dynamic>> fetchOttData() async {
    try {
      String url = APIData.login;

      print(url.toString());
      var response = await http.post(Uri.parse(url), body: {
        'action': 'home',
        'authorizationToken': ServiceManager.tokenID
      });
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        // centerTitle: true,

        // Add an image to the left side
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                // color: Colors.yellow,
                height: 80, // Set desired height
                width: 80, // Set desired width
                child: Image.asset(
                  'images/flix_splash.png', // Replace with your image asset path
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Search icon
          // IconButton(
          //   icon: const Icon(Icons.search, color: Colors.white),
          //   onPressed: () {
          //     // Add your search action here
          //   },
          // ),
          // Profile icon inside a circular red container
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            decoration: const BoxDecoration(
              color: Color(0xffe50916), // Red background color
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // Add your profile action here
              },
            ),
          ),
          // Subscribe button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            child: ElevatedButton(
              onPressed: () {
                // Add your subscribe action here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xffe50916), // Subscribe button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ottData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerSection(data['banner1_list']),
                _buildCategorySection('Hits', data['hits_video_list']),
                _buildCategorySection('Upcoming', data['upcoming_video_list']),
                _buildCategorySection('Movies', data['Movies']),
                _buildBannerSection(data['banner2_list']),
                _buildCategorySection('Web Series', data['Web Series']),
                _buildBannerSection(data['banner3_list']),
                _buildCategorySection('Documentary', data['Documentary']),
                _buildCategorySection('Music Videos', data['Music Videos']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSection(List<dynamic> banners) {
    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(banner['advertisement']),
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> items) {
    int initialDisplayCount = 5;
    bool viewMore = items.length > initialDisplayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 203, 166, 1)),
          ),
        ),
        Container(
          height: 240,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewMore ? initialDisplayCount + 1 : items.length,
              itemBuilder: (context, index) {
                if (viewMore && index == initialDisplayCount) {
                  return _buildViewMoreButton(() {
                    setState(() {
                      viewMore = false;
                    });
                  });
                }
                final item = items[index];
                return _buildItemCard(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () {
              print(item['id']);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoDetailsScreen(
                            id: item['id'],
                          )));
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/thumbnail.png',
                        image: item['thumbnail'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  //
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMoreButton(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'View More',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
