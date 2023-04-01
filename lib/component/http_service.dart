import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:appid/component/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HttpService {
  static final HttpService _instance = HttpService.internal();
  HttpService.internal();
  factory HttpService() => _instance;

  final LocalStorage storage = LocalStorage('homerunapp');
  Map<String, String> headers = {};
  final JsonDecoder _decoder = const JsonDecoder();
  static const _baseUrl = "https://api.homerun.livinglab.ventures/v1/";

  Future<dynamic> get(String desturl,
      {Map<String, String> headers = const {'': ''}}) async {

    var authKey = await getInstanceString('authKey');

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'X-Auth-Token': authKey is String ? authKey : '',
      "X-Auth-Api": "qwekqei129p124"
    };

    return http
        .get(Uri.parse(_baseUrl + desturl), headers: requestHeaders)
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(response.body);
    }, onError: (error) {
      throw Exception(error.toString());
    });
  }

  Future<dynamic> post(String desturl,
      {Map<String, String> headers = const {"": ""}, body, encoding}) async {
    body ??= {};

    var authKey = await getInstanceString('authKey');

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "Accept": "application/json",
      "X-Auth-Token": authKey is String ? authKey : '',
      "X-Auth-Api": "qwekqei129p124",
    };

    return http
        .post(Uri.parse(_baseUrl + desturl),
            body: json.encode(body),
            headers: requestHeaders,
            encoding: encoding)
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }

      return _decoder.convert(response.body);
    }, onError: (error) {
      throw Exception(error.toString());
    });
  }

  Future<http.Response> postdata(String desturl,
      {Map<String, String> headers = const {"": ""}, body, encoding}) async {
    body ??= {};

    var authKey = await getInstanceString('authKey');

    Map<String, String> requestHeaders = {
      "Content-type": "application/json",
      "Accept": "application/json",
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
      "X-Auth-Token": authKey is String ? authKey : '',
      "X-Auth-Api": "qwekqei129p124"
    };

    return http.post(Uri.parse(_baseUrl + desturl),
        body: json.encode(body), headers: requestHeaders, encoding: encoding);
  }

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie']!;
    int index = rawCookie.indexOf(';');
    headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }
}
