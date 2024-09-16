import 'package:flixprime_app/Service/serviceManager.dart';

class APIData {
  //Auth profile Api
  static const String baseURL = 'https://flixprime.in/';

  static const String login = '${baseURL}app-api.php';

  //Header
  static Map<String, String> kHeader = {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${ServiceManager.tokenID}',
  };
}
