import 'dart:convert';
import 'package:flixprime_app/Service/apiManager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServiceManager {
  static String userID = '';
  static String tokenID = '';
  static String userBranchID = '';

  static String profileURL = '';
  static String userName = '';
  static String userEmail = '';
  static String sId = '';
  static String userMobile = '';
  static String userDob = '';
  static String userAltMobile = '';
  static String designation = '';
  static bool isVerified = false;

  static String deliveryName = '';
  // static String deliveryAddress = '';

  static String userAddress = '';
  static String addressID = '';
  static String roleAs = '';

  void setUser(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userID', userID);
  }

  void getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? '';
    //getUserData();---need to use later
  }

  void setToken(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenID', userID);
  }

  void getTokenID() async {
    final prefs = await SharedPreferences.getInstance();
    tokenID = prefs.getString('tokenID') ?? '';
    //getUserData();---need to use later
  }

  void setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', userName);
  }

  void getName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('name') ?? '';
  }

  void setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  void getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email') ?? '';
  }

  void setMobile(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('phone', phone);
  }

  void getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    userMobile = prefs.getString('phone') ?? '';
  }

  void setSubId(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('subscriber_id', subId);
  }

  void getSubId() async {
    final prefs = await SharedPreferences.getInstance();
    sId = prefs.getString('subscriber_id') ?? '';
  }

  void removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userID');
    prefs.remove('tokenID');
    // prefs.remove('addressID');
    userID = '';
    tokenID = '';
    // addressID = '';
  }

  void getUserData() async {
    String url = APIData.login;
    print(url);
    var res = await http.post(Uri.parse(url), body: {
      'action': 'astrologer-details',
      'authorizationToken': ServiceManager.tokenID, //8100007581
    });
    var data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data.toString());
      userName = '${data['astrologerDetails']['name']}';
      userEmail = '${data['astrologerDetails']['email']}';
      profileURL = '${data['astrologerDetails']['logo']}';
      // userMobile = data['astrologerDetails']['mobile'] ?? '';
      // userAltMobile = data['astrologerDetails']['alternative_mob'] ?? '';
      // userDob = data['astrologerDetails']['dob'] ?? '';
      // designation = data['astrologerDetails']['Designation'] ?? '';
      // userBranchID = data['astrologerDetails']['branchId'] ?? '';
      // roleAs = '${data['astrologerDetails']['use_role']}';
    } else {
      // print('Status Code: ${res.statusCode}');
      // print(res.body);
    }
  }
}
