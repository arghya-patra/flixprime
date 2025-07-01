import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flixprime_app/Screens/Dashboard/ainAPpWebView.dart';
import 'package:flixprime_app/Screens/Dashboard/animatedSlider.dart';
import 'package:flixprime_app/Screens/Dashboard/notiListScreen.dart';
import 'package:flixprime_app/Screens/Dashboard/profile.dart';
import 'package:flixprime_app/Screens/Dashboard/videoDetails.dart';
import 'package:flixprime_app/Screens/Login/loginScreen.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomeViewScreen extends StatefulWidget {
  const HomeViewScreen({super.key});

  @override
  _HomeViewScreenState createState() => _HomeViewScreenState();
}

class _HomeViewScreenState extends State<HomeViewScreen> {
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  Map<String, dynamic>? apiResponse;
  int notificationCount = 0;
  @override
  void initState() {
    super.initState();
    fetchData();
    loadSliderData();
    //fetchNotificationCount();
  }

  Future<Map<String, dynamic>?> fetchDashboardSliderData() async {
    String url = APIData.login;
    try {
      final response = await http.post(Uri.parse(url), body: {
        'action': 'slider',
        'authorizationToken': ServiceManager.tokenID
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['isSuccess'] == "true") {
          return data;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching dashboard slider data: $e");
      return null;
    }
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

        setState(() {
          apiData = responseData;
          isLoading = false;
        });
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> fetchNotificationCount() async {
    String url = APIData.login; // Replace with real API
    final response = await http.post(Uri.parse(url), body: {
      'action': 'add-notification-in-view',
      'authorizationToken': ServiceManager.tokenID,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        notificationCount = data['count'] ?? 0;
      });
    } else {
      debugPrint('Failed to load notifications');
    }
  }

  Future<void> loadSliderData() async {
    final data = await fetchDashboardSliderData();
    setState(() {
      apiResponse = data;
      isLoading = false;
    });
  }

  Widget buildDashboardSlider(
      Map<String, dynamic> apiResponse, String position) {
    List<dynamic> sliderData = position == "top"
        ? apiResponse['top_slider'] ?? []
        : apiResponse['bottom_slider'] ?? [];

    if (sliderData.isEmpty) return const SizedBox();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: sliderData.length,
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: true,
            pauseAutoPlayOnTouch: true,
            scrollPhysics: const ClampingScrollPhysics(),
          ),
          itemBuilder: (context, index, realIdx) {
            final item = sliderData[index];
            final imageUrl = item['background'] ?? '';
            final title = item['title'] ?? '';
            final logoUrl = item['slider_logo'] ?? '';
            final genre = item['genre'] ?? '';
            final language = item['language'] ?? '';

            return AnimatedSliderItem(
                imageUrl: imageUrl,
                title: title,
                logoUrl: logoUrl,
                genre: genre,
                language: language);
          },
        ),
        // const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 90,
                  child: Image.asset(
                    'images/flix_splash.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // 🔔 Notification icon with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen()),
                    );
                  },
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Center(
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 👤 Profile icon
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
              decoration: const BoxDecoration(
                color: Color(0xffe50916),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: Colors.deepOrange,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await fetchData();
            await loadSliderData();
            //fetchNotificationCount();
          },
          child: isLoading
              ? _buildShimmerEffect()
              : apiData == null
                  ? _buildErrorWidget()
                  : _buildDashboardContent(),
        ));
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            height: 180,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(child: Text("Failed to load data. Please try again!"));
  }

  Widget _buildDashboardContent() {
    return ListView(
      children: [
        apiResponse != null
            ? buildDashboardSlider(apiResponse!, 'top')
            : Container(),

        (apiData!['hits_video_list'] != null &&
                apiData!['hits_video_list'].isNotEmpty)
            ? _buildSection("Trending", apiData!['hits_video_list'])
            : Container(),
        SizedBox(
          height: 10,
        ),
        _buildBanner(apiData!['banner1_list']),
        SizedBox(
          height: 10,
        ),
        (apiData!['release_video_list'] != null &&
                apiData!['release_video_list'].isNotEmpty)
            ? _buildSection("New Release", apiData!['release_video_list'])
            : Container(),
        (apiData!['upcoming_video_list'] != null &&
                apiData!['upcoming_video_list'].isNotEmpty)
            ? _buildSection("Upcoming", apiData!['upcoming_video_list'])
            : Container(),
        SizedBox(
          height: 10,
        ),

        _buildBanner(apiData!['banner2_list']),
        SizedBox(
          height: 10,
        ),
        (apiData!['Movies'] != null && apiData!['Movies'].isNotEmpty)
            ? _buildSection("Movies", apiData!['Movies'])
            : Container(),
        (apiData!['Series'] != null && apiData!['Series'].isNotEmpty)
            ? _buildSection("Series", apiData!['Series'])
            : Container(),

        (apiData!['Documentary'] != null && apiData!['Documentary'].isNotEmpty)
            ? _buildSection("Documentary", apiData!['Documentary'])
            : Container(),

        (apiData!['Music Videos'] != null &&
                apiData!['Music Videos'].isNotEmpty)
            ? _buildSection("Music Videos", apiData!['Music Videos'])
            : Container(),
        _buildBanner(apiData!['banner2_list']),
        // _buildSection("Trailer list", apiData!['trailer_list']),
        apiResponse != null
            ? buildDashboardSlider(apiResponse!, 'bottom')
            : Container(),
      ],
    );
  }

  Widget _buildBanner1(List<dynamic> bannerList) {
    final CarouselController _controller = CarouselController();

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: bannerList.length,
          options: CarouselOptions(
            height: 200,
            autoPlay: bannerList.length > 1,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: true,
            pauseAutoPlayOnTouch: true,
            scrollPhysics:
                const ClampingScrollPhysics(), // Prevent bouncing back
            onScrolled: (position) {
              // Optional: use if needed
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = bannerList[index];
            return GestureDetector(
              onTap: () {
                // Navigate or handle tap
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: banner['advertisement'],
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.grey[300]),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.error, size: 50),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBanner(List<dynamic> bannerList) {
    final PageController _pageController = PageController();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerList.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  // Add Navigation to banner details if needed
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: bannerList[index]['advertisement'],
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.grey[300]),
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.error, size: 50),
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSection(String title, List<dynamic> videoList) {
    // Check if the videoList is empty
    if (videoList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "No data available.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10), // Add some spacing
        ],
      );
    }

    // If the videoList is not empty, build the section as usual
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 190, // Increased for better layout
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videoList.length,
            itemBuilder: (_, index) {
              var item = videoList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoDetailsScreen(
                                id: item['id'],
                              )));
                  // Navigate to video details
                },
                child: Container(
                  width: 110,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      const BoxShadow(
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
                          borderRadius: BorderRadius.circular(10),
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
                                Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: item['thumbnail'],
                                      placeholder: (_, __) =>
                                          Shimmer.fromColors(
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
                                    item['content_type'] == 'Premium'
                                        ? Container()
                                        : Positioned(
                                            top: 0,
                                            right: 0,
                                            child: ClipPath(
                                              clipper: CornerTriangleClipper(),
                                              child: Container(
                                                width: 55,
                                                height: 55,
                                                color: item['content_type'] ==
                                                        'Free'
                                                    ? Colors.yellow[700]
                                                    : Colors.red,
                                                child: Align(
                                                  alignment:
                                                      Alignment(0.7, -0.5),
                                                  child: Transform.rotate(
                                                    angle:
                                                        0.785398, // 45 degrees in radians
                                                    child: Text(
                                                      item['content_type'] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            item['content_type'] ==
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
}

class CornerTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0); // top-right
    path.lineTo(size.width, size.height); // bottom-right
    path.lineTo(0, 0); // top-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
