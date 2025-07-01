import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixprime_app/Screens/Dashboard/videoDetails.dart';
import 'package:flixprime_app/Screens/Login/loginScreen.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<dynamic> videoList = [];
  List<dynamic> filteredList = [];
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    String url = APIData.login;

    try {
      var response = await http.post(Uri.parse(url), body: {
        'action': 'home',
        'authorizationToken': ServiceManager.tokenID
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 201 &&
            data['isSuccess'] == "false" &&
            data['error'] == "Token does not exist!") {
          print("Logout: Invalid token detected.");
          ServiceManager().removeAll();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false);
          return;
        }
        setState(() {
          videoList = []; // Initialize videoList as an empty list

          // Check if each list exists and is not empty before adding
          if (data['Movies'] != null && data['Movies'].isNotEmpty) {
            videoList.addAll(data['Movies']);
          }
          if (data['Series'] != null && data['Series'].isNotEmpty) {
            videoList.addAll(data['Series']);
          }
          if (data['Music Videos'] != null && data['Music Videos'].isNotEmpty) {
            videoList.addAll(data['Music Videos']);
          }
          if (data['Documentary'] != null && data['Documentary'].isNotEmpty) {
            videoList.addAll(data['Documentary']);
          }

          // Set filteredList to videoList
          filteredList = videoList;
        });
      } else {
        // Handle error
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions
      debugPrint("Error fetching videos: $e");
    }
  }

  void filterVideos(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredList = videoList;
      } else {
        filteredList =
            videoList.where((video) => video['type_name'] == category).toList();
      }
    });
  }

  void searchVideos(String query) {
    setState(() {
      filteredList = videoList
          .where((video) =>
              video['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Colors.black, Colors.black54],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.white54),
              ),
              onChanged: searchVideos,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Container(
          //   padding:
          //       const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          //   decoration: BoxDecoration(
          //     color: Colors.black87,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black45,
          //         offset: Offset(0, 4),
          //         blurRadius: 8,
          //       ),
          //     ],
          //   ),
          //   child: Wrap(
          //     spacing: 8.0,
          //     runSpacing: 4.0,
          //     alignment: WrapAlignment.center,
          //     children: [
          //       _buildChoiceChip('All'),
          //       _buildChoiceChip('Movies'),
          //       _buildChoiceChip('Web Series'),
          //       _buildChoiceChip('Music Videos'),
          //       _buildChoiceChip('Documentary'),
          //     ],
          //   ),
          // ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 9.0,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final video = filteredList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoDetailsScreen(
                                  id: video['id'],
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
                                alignment: Alignment.center,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: video['thumbnail'],
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
                                  //tag section
                                  // Tag (FREE ribbon) positioned at top-right corner
                                  video['content_type'] == 'Premium'
                                      ? Container()
                                      : Positioned(
                                          top: 0,
                                          right: 0,
                                          child: ClipPath(
                                            clipper: CornerTriangleClipper(),
                                            child: Container(
                                              width: 55,
                                              height: 55,
                                              color: video['content_type'] ==
                                                      'Free'
                                                  ? Colors.yellow[700]
                                                  : Colors.red,
                                              child: Align(
                                                alignment: Alignment(0.7, -0.5),
                                                child: Transform.rotate(
                                                  angle:
                                                      0.785398, // 45 degrees in radians
                                                  child: Text(
                                                    video['content_type'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          video['content_type'] ==
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

                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) =>
                //                 VideoDetailsScreen(id: video['id'])));
                //   },
                //   child: Container(
                //     // decoration: BoxDecoration(
                //     //   gradient: const LinearGradient(
                //     //     colors: [Colors.amber, Colors.black],
                //     //     begin: Alignment.topLeft,
                //     //     end: Alignment.bottomRight,
                //     //   ),
                //     //   borderRadius: BorderRadius.circular(15.0),
                //     //   boxShadow: [
                //     //     BoxShadow(
                //     //       color: Colors.black54,
                //     //       offset: Offset(2, 4),
                //     //       blurRadius: 6,
                //     //     ),
                //     //   ],
                //     // ),
                //     child: Card(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(15.0),
                //         ),
                //         elevation: 8,
                //         child: Container(
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //                 color: Colors.grey, width: 2), // Grey border
                //             borderRadius: BorderRadius.circular(
                //                 15), // Match the border radius
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black
                //                     .withOpacity(0.2), // Shadow color
                //                 blurRadius: 8, // Shadow blur
                //                 spreadRadius: 2, // Shadow spread
                //                 offset: const Offset(0, 4), // Shadow offset
                //               ),
                //             ],
                //           ),
                //           child: ClipRRect(
                //             borderRadius: BorderRadius.circular(15),
                //             child: Image.network(
                //               video['thumbnail'],
                //               height: 150,
                //               width: double.infinity,
                //               fit: BoxFit.cover,
                //             ),
                //           ),
                //         )
                //         ),
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selectedCategory == label ? Colors.black : Colors.white,
        ),
      ),
      selected: selectedCategory == label,
      onSelected: (selected) => filterVideos(label),
      selectedColor: Colors.amber,
      backgroundColor: Colors.grey[800],
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
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
