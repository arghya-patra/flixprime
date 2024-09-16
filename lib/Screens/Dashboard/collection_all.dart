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

    print(url.toString());
    var response = await http.post(Uri.parse(url), body: {
      'action': 'home',
    });
    print(response.body);
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black54],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white),
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () => searchVideos(searchController.text),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.amber,
            child: Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedCategory == 'All',
                  onSelected: (selected) => filterVideos('All'),
                ),
                ChoiceChip(
                  label: const Text('Movies'),
                  selected: selectedCategory == 'Movies',
                  onSelected: (selected) => filterVideos('Movies'),
                ),
                ChoiceChip(
                  label: const Text('Web Series'),
                  selected: selectedCategory == 'Web Series',
                  onSelected: (selected) => filterVideos('Web Series'),
                ),
                ChoiceChip(
                  label: const Text('Music Videos'),
                  selected: selectedCategory == 'Music Videos',
                  onSelected: (selected) => filterVideos('Music Videos'),
                ),
                ChoiceChip(
                  label: const Text('Documentary'),
                  selected: selectedCategory == 'Documentary',
                  onSelected: (selected) => filterVideos('Documentary'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final video = filteredList[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber,
                        Colors.purple
                      ], // Define your gradient colors here
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        12), // Match the Card's border radius
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                padding: const EdgeInsets.all(8),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                video['cat_name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.blueAccent,
                                    size: 28,
                                  ),
                                  Icon(
                                    Icons.favorite_border,
                                    color: Colors.redAccent,
                                    size: 24,
                                  ),
                                  Icon(
                                    Icons.share,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
