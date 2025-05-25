import 'dart:convert';
import 'package:flixprime_app/Screens/Dashboard/videoplayerWV.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class VideoDetailsScreen extends StatefulWidget {
  final String? id;
  VideoDetailsScreen({required this.id});
  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? videoData;
  bool isLoading = true;
  bool showFullDescription = false;

  @override
  void initState() {
    super.initState();
    loadVideoDetails();
  }

  Future<Map<String, dynamic>> fetchVideoDetails() async {
    String url = APIData.login;
    var response = await http.post(Uri.parse(url), body: {
      'action': 'view-content',
      'authorizationToken': ServiceManager.tokenID,
      'video_id': widget.id
    });
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
        print(videoData);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back icon color to white
        ),
      ),
      body: isLoading ? buildShimmerEffect() : buildVideoDetails(),
    );
  }

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

  Widget buildVideoDetails() {
    // bool showFullDescription = false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section as Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Image
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/thumbnail.png',
                        image: videoData?['videoDetails']['landscape'] ?? '',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VideoPlayerWebViewScreen(
                              videoUrl:
                                  'https://iframe.mediadelivery.net/embed/271549/78f12111-23c0-4a2e-8ec5-e7da3b4d9bea?token=a9a6d6d0cc97c02ec47012f05c123c7a517f93c700e59cd8b384bb2d737eb4e4&expires=2692722600&autoplay=false&loop=true&muted=true&preload=true&responsive=true',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Yellow button color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 0),
                        elevation: 2, // Slight shadow effect
                      ),
                      child: const Text(
                        'Play',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoData?['videoDetails']['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          videoData?['videoDetails']['description'] ?? '',
                          maxLines: showFullDescription ? 50 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white, height: 1.4),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showFullDescription = !showFullDescription;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber, // Yellow button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          elevation: 2, // Slight shadow effect
                          minimumSize: const Size(0, 30),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Adjust to fit content
                          children: [
                            Text(
                              showFullDescription ? 'Show Less' : 'Show More',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Space between text and icon
                            Icon(
                              showFullDescription
                                  ? Icons.arrow_upward
                                  : Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildAlignedInfoRow('Age Rating',
                                videoData?['videoDetails']['age_rating']),
                            buildAlignedInfoRow(
                                'Genre', videoData?['videoDetails']['genre']),
                            buildAlignedInfoRow(
                                'Language',
                                videoData?['video_lang_list'].isEmpty
                                    ? "N/A"
                                    : videoData?['video_lang_list'][0]['name']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.red,
            thickness: 2,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Related Videos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videoData?['related_video_list'].length ?? 0,
              itemBuilder: (context, index) {
                var relatedVideo = videoData?['related_video_list'][index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoDetailsScreen(id: relatedVideo['id']),
                      ),
                    );
                  },
                  child: buildRelatedVideoCard(relatedVideo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlignedInfoRow(String title, String? data) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Increase vertical space
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6, // Adjust flex for title
            child: Text(
              "$title :",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
              width: 20), // Add more horizontal space between title and data
          Expanded(
            flex: 5, // Adjust flex for data
            child: Text(
              data ?? 'N/A',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRelatedVideoCard(Map<String, dynamic>? relatedVideo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 150,
      child: Card(
        color: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: FadeInImage.assetNetwork(
                placeholder: 'images/thumbnail.png',
                image: relatedVideo?['thumbnail'] == 'https://flixprime.in/'
                    ? "https://flixprime.in/uploads/advertisement/1709202927_0.jpg"
                    : relatedVideo?['thumbnail'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8),
              child: Text(
                relatedVideo?['name'] ?? '',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                relatedVideo?['type_name'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoDetails2() {
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
                fit: BoxFit.cover,
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
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 10),

                // Age Rating and Genre
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.star,
                        color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      'Age Rating: ${videoData?['videoDetails']['age_rating']}',
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                    // const SizedBox(width: 5),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.movie,
                        color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      'Genre: ${videoData?['videoDetails']['genre']}',
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ),
                // const SizedBox(height: 10),

                // Video Language
                videoData?['video_lang_list'].isEmpty
                    ? Container()
                    : Row(
                        children: [
                          const Icon(Icons.language,
                              color: Colors.orangeAccent),
                          const SizedBox(width: 5),
                          Text(
                            'Language: ${videoData?['video_lang_list'][0]['name'] ?? "N/A"}',
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        ],
                      ),

                const SizedBox(height: 20),

                // Related Videos Section
                const Text('Related Videos',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Related Videos Horizontal List
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: videoData?['related_video_list'].length ?? 0,
                    itemBuilder: (context, index) {
                      var relatedVideo =
                          videoData?['related_video_list'][index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailsScreen(
                                id: relatedVideo['id'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 150,
                          child: Card(
                            color: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'images/thumbnail.png',
                                    image: relatedVideo?['thumbnail'] ?? '',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 8),
                                  child: Text(
                                    relatedVideo?['name'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    relatedVideo?['type_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _playVideo2(String videoUrl) {
  //   print(videoUrl);

  //   // Declare the controller first
  //   VideoPlayerController controller = VideoPlayerController.network(
  //       "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4");

  //   // Initialize the controller and handle the video player in the dialog
  //   controller.initialize().then((_) {
  //     // Ensure the first frame is shown after the video is initialized
  //     controller.play();

  //     // Show video player in a dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         print("dialog");
  //         return AlertDialog(
  //           contentPadding: EdgeInsets.zero,
  //           content: AspectRatio(
  //             aspectRatio: controller.value.aspectRatio,
  //             child: VideoPlayer(controller),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 // Stop the video when closing the dialog
  //                 controller.pause();
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Close'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }).catchError((error) {
  //     print("***************");
  //     print(error.toString());
  //     print("***************");
  //     // Handle any errors in video initialization
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Error loading video')),
  //     );
  //   });
  // }
}
