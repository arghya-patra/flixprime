import 'package:flixprime_app/Screens/Dashboard/collection_all.dart';
import 'package:flixprime_app/Screens/Dashboard/homeView.dart';
import 'package:flixprime_app/Screens/Dashboard/profile.dart';
import 'package:flixprime_app/Screens/Dashboard/watchlist.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //  getDashboardData(context);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // getDashboardData(context) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   String url = APIData.login;

  //   print(url.toString());
  //   var res = await http.post(Uri.parse(url), body: {
  //     'action': 'home',
  //     //  'authorizationToken': ServiceManager.tokenID, //8100007581
  //   });
  //   var data = jsonDecode(res.body);
  //   if (data['status'] == 200) {
  //     print("______________________________________");
  //     print(res.body);
  //     print("______________________________________");
  //     try {
  //       print(res.body);
  //     } catch (e) {
  //       toastMessage(message: e.toString());
  //       setState(() {
  //         isLoading = false;
  //       });
  //       toastMessage(message: 'Something went wrong');
  //     }
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     toastMessage(message: 'Something Went wrong!');
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  //   return 'Success';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  key: _scaffoldKey,

      body: TabBarView(
        controller: _tabController,
        children: [
          HomeViewScreen(), // HomeScreen(),
          CollectionScreen(),
          WatchlistScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomTabBar(),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.black87 // Color.fromARGB(255, 203, 166, 1),
          // gradient: LinearGradient(
          //   colors: [Colors.black, Color.fromARGB(255, 255, 221, 28)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
              icon: Icon(
            Icons.home,
            color: Colors.white,
          )),
          Tab(icon: Icon(Icons.search, color: Colors.white)),
          Tab(icon: Icon(Icons.subscriptions, color: Colors.white)),
          Tab(icon: Icon(Icons.person, color: Colors.white)),
        ],
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(5.0),
        indicatorColor: Colors.white,
        indicator: const BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
