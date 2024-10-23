import 'dart:convert';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class VideoDetailsScreen extends StatefulWidget {
  String? id;
  VideoDetailsScreen({required this.id});
  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? videoData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVideoDetails();
  }

  Future<Map<String, dynamic>> fetchVideoDetails() async {
    String url = APIData.login;
    print(url.toString());
    var response = await http.post(Uri.parse(url), body: {
      'action': 'view-content',
      'authorizationToken': ServiceManager.tokenID,
      'video_id': widget.id
    });
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load video details');
    }
  }

  Future<void> loadVideoDetails() async {
    try {
      final data = await fetchVideoDetails();
      setState(() {
        videoData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Video Details'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading ? buildShimmerEffect() : buildVideoDetails(),
    );
  }

  // Shimmer Effect while loading data
  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(height: 200, color: Colors.white),
              const SizedBox(height: 10),
              Container(height: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Build UI after fetching video details
  Widget buildVideoDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Landscape Image and Video Name with Description
          Stack(
            children: [
              FadeInImage.assetNetwork(
                placeholder: 'images/thumbnail.png',
                image: videoData?['videoDetails']['landscape'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.contain,
              ),
              Positioned(
                bottom: 20,
                left: 16,
                child: Text(
                  videoData?['videoDetails']['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0.0, 1.0),
                        blurRadius: 5.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  videoData?['videoDetails']['description'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 10),

                // Age Rating and Genre
                Row(
                  children: [
                    Text(
                      'Age Rating: ${videoData?['videoDetails']['age_rating']}',
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Genre: ${videoData?['videoDetails']['genre']}',
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Video Language
                videoData?['video_lang_list'].isEmpty
                    ? Container()
                    : Text(
                        'Language: ${videoData?['video_lang_list'][0]['name'] ?? "N/A"}',
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),

                const SizedBox(height: 20),

                // Related Videos Section
                const Text('Related Videos',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Related Videos Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videoData?['related_video_list'].length ?? 0,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    var relatedVideo = videoData?['related_video_list'][index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoDetailsScreen(
                                      id: relatedVideo['id'],
                                    )));
                      },
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: 'images/thumbnail.png',
                              image: relatedVideo?['thumbnail'] ?? '',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(relatedVideo?['name'] ?? ''),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
