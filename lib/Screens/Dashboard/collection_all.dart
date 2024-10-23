import 'package:flixprime_app/Screens/Dashboard/videoDetails.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    var response = await http.post(Uri.parse(url), body: {'action': 'home'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        videoList = data['Movies'] +
            data['Web Series'] +
            data['Music Videos'] +
            data['Documentary'];
        filteredList = videoList;
      });
    } else {
      // Handle error
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black54],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
              ),
              onChanged: searchVideos,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children: [
                _buildChoiceChip('All'),
                _buildChoiceChip('Movies'),
                _buildChoiceChip('Web Series'),
                _buildChoiceChip('Music Videos'),
                _buildChoiceChip('Documentary'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
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
                            builder: (context) =>
                                VideoDetailsScreen(id: video['id'])));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(2, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  video['thumbnail'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Text(
                                    video['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video['cat_name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.blueAccent,
                                      size: 26,
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.favorite_border,
                                      color: Colors.redAccent,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.share,
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ],
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
