import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:flixprime_app/Service/serviceManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<dynamic> watchList = [];

  @override
  void initState() {
    super.initState();
    fetchWatchlist();
  }

  Future<void> fetchWatchlist() async {
    String url = APIData.login;

    print(url.toString());
    var response = await http.post(Uri.parse(url), body: {
      'action': 'watch-list',
      'authorizationToken': ServiceManager.tokenID
    });
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        watchList = data['watch_list'];
      });
    } else {
      // Handle error
      print('Failed to load watchlist');
    }
  }

  Future<void> removeFromWatchlist(String id) async {
    // API call to remove item from watchlist
    // Assuming API URL: 'YOUR_REMOVE_API_URL/$id'
    final response = await http.delete(Uri.parse('YOUR_REMOVE_API_URL/$id'));

    if (response.statusCode == 200) {
      setState(() {
        watchList.removeWhere((item) => item['id'] == id);
      });
    } else {
      // Handle error
      print('Failed to remove item from watchlist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Watchlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: watchList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 35.0,
                  mainAxisSpacing: 9.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: watchList.length,
                itemBuilder: (context, index) {
                  final item = watchList[index];
                  return buildWatchlistItem(item);
                },
              ),
            ),
    );
  }

  Widget buildWatchlistItem(Map<String, dynamic> item) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.amber, size: 20),
                        padding: EdgeInsets.zero, // Reduce button padding
                        constraints:
                            const BoxConstraints(), // Prevent extra space
                        onPressed: () => showRemoveDialog(item['id']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWatchlistItem2(Map<String, dynamic> item) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  alignment: Alignment.center,
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
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // SizedBox(
    //   height: 180, // Ensure consistent height
    //   child: Card(
    //     color: Colors.transparent,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(15),
    //     ),
    //     elevation: 5,
    //     child: Stack(
    //       children: [
    //         Container(
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(10),
    //             boxShadow: const [
    //               BoxShadow(
    //                 color: Color.fromARGB(255, 103, 82, 82),
    //                 blurRadius: 5,
    //                 offset: Offset(2, 2),
    //               ),
    //             ],
    //             color: Colors.black,
    //           ),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(15),
    //             child: AspectRatio(
    //               aspectRatio: 4 / 3,
    //               child: Image.network(
    //                 item['thumbnail'],
    //                 fit: BoxFit.cover,
    //                 width: double.infinity,
    //               ),
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           top: 8,
    //           right: 8,
    //           child: IconButton(
    //             icon: const Icon(Icons.more_vert, color: Colors.amber),
    //             onPressed: () => showRemoveDialog(item['id']),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void showRemoveDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text(
            'Are you sure you want to remove this item from the watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              removeFromWatchlist(id);
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
