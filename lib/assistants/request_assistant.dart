import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) {
        String resData = httpResponse.body;
        var decodeResponseData = jsonDecode(resData);
        return decodeResponseData;
      } else {
        return 'failed';
      }
    } catch (err) {
      return 'failed';
    }
  }
}
