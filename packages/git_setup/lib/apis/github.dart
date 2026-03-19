/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart' show HttpHeaders;
import 'package:url_launcher/url_launcher.dart';

import 'githost.dart';

// FIXME: Handle for edge cases of json.decode

class GitHub implements GitHost {
  static const _clientID = "aa3072cbfb02b1db14ed";
  static const _clientSecret = "010d303ea99f82330f2b228977cef9ddbf7af2cd";

  final _platform = const MethodChannel('gitjournal.io/git');
  var _accessCode = "";

  @override
  void init(OAuthCallback callback) {
    Future _handleMessages(MethodCall call) async {
      if (call.method != "onURL") {
        Log.d("GitHub Unknown Call: " + call.method);
        return;
      }

      closeInAppWebView();
      Log.d("GitHub: Called onUrl with " + call.arguments.toString());

      String url = call.arguments["URL"];
      var uri = Uri.parse(url);
      var authCode = uri.queryParameters['code'] ?? "";
      if (authCode.isEmpty) {
        Log.d("GitHub: Missing auth code. Now what?");
        callback(GitHostException.OAuthFailed);
      }

      _accessCode = await _getAccessCode(authCode);
      if (_accessCode.isEmpty) {
        Log.d("GitHub: AccessCode is invalid: " + _accessCode);
        callback(GitHostException.OAuthFailed);
      }

      callback(null);
    }

    _platform.setMethodCallHandler(_handleMessages);
    Log.d("GitHub: Installed Handler");
  }

  Future<String> _getAccessCode(String authCode) async {
    var url = Uri.parse(
        "https://github.com/login/oauth/access_token?client_id=$_clientID&client_secret=$_clientSecret&code=$authCode");

    var response = await _postWithRetry(url);
    if (response.statusCode != 200) {
      Log.d("Github getAccessCode: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.OAuthFailed;
    }
    // Log.d("GithubResponse: " + response.body);

    var map = Uri.splitQueryString(response.body);
    return map["access_token"] ?? "";
  }

  @override
  Future<void> launchOAuthScreen() async {
    // FIXME: Add some 'state' over here!

    var url = "https://github.com/login/oauth/authorize?client_id=" +
        _clientID +
        "&scope=repo";
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<List<GitHostRepo>> listRepos() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url =
        Uri.parse("https://api.github.com/user/repos?page=1&per_page=100");
    var headers = _headersWithDefaults({
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    });

    if (foundation.kDebugMode) {
      var redactedHeaders = Map<String, String>.from(headers);
      if (redactedHeaders.containsKey(HttpHeaders.authorizationHeader)) {
        redactedHeaders[HttpHeaders.authorizationHeader] = 'token ***';
      }
      Log.d(toCurlCommand(url, redactedHeaders));
    }

    var response = await _getWithRetry(url, headers: headers);
    if (response.statusCode != 200) {
      Log.e("Github listRepos: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.HttpResponseFail;
    }

    List<dynamic> list = jsonDecode(response.body);
    var repos = <GitHostRepo>[];
    for (var d in list) {
      var map = Map<String, dynamic>.from(d);
      var repo = repoFromJson(map);
      repos.add(repo);
    }

    // FIXME: Sort these based on some criteria
    return repos;
  }

  @override
  Future<GitHostRepo> createRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = Uri.parse("https://api.github.com/user/repos");
    var data = <String, dynamic>{
      'name': name,
      'private': true,
    };

    var headers = _headersWithDefaults({
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    });

    var response = await _postWithRetry(
      url,
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      Log.e("Github createRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      if (response.statusCode == 422) {
        if (response.body.contains("name already exists")) {
          throw GitHostException.RepoExists;
        }
      }

      throw GitHostException.CreateRepoFailed;
    }

    Log.d("GitHub createRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return repoFromJson(map);
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var userInfo = await getUserInfo();
    var owner = userInfo.username;
    var url = Uri.parse("https://api.github.com/repos/$owner/$name");

    var headers = _headersWithDefaults({
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    });

    var response = await _getWithRetry(url, headers: headers);
    if (response.statusCode != 200) {
      Log.e("Github getRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      throw GitHostException.GetRepoFailed;
    }

    Log.d("GitHub getRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return repoFromJson(map);
  }

  @override
  Future<void> addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = Uri.parse("https://api.github.com/repos/$repo/keys");

    var data = <String, dynamic>{
      'title': "GitJournal",
      'key': sshPublicKey,
      'read_only': false,
    };

    var headers = _headersWithDefaults({
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    });

    var response = await _postWithRetry(
      url,
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      Log.d("Github addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.DeployKeyFailed;
    }

    Log.d("GitHub addDeployKey: " + response.body);
  }

  static GitHostRepo repoFromJson(Map<String, dynamic> parsedJson) {
    DateTime? updatedAt;
    try {
      updatedAt = DateTime.parse(parsedJson['updated_at'].toString());
    } catch (e, st) {
      Log.e("github repoFromJson", ex: e, stacktrace: st);
    }
    var licenseMap = parsedJson['license'];
    var fullName = parsedJson['full_name'].toString();

    var owner = parsedJson['owner'];
    var username = "";
    if (owner != null) {
      username = (owner as Map)["login"];
    } else {
      username = fullName.split('/').first;
    }

    /*
    print("");
    parsedJson.forEach((key, value) => print(" $key: $value"));
    print("");
    */

    return GitHostRepo(
      name: parsedJson['name'],
      username: username,
      fullName: fullName,
      cloneUrl: parsedJson['ssh_url'],
      updatedAt: updatedAt,
      description: parsedJson['description'] ?? "",
      stars: parsedJson['stargazers_count'],
      forks: parsedJson['forks_count'],
      issues: parsedJson['open_issues_count'],
      language: parsedJson['language'] ?? "",
      private: parsedJson['private'],
      // tags: parsedJson['topics'] ?? [],
      tags: [],
      license: licenseMap != null ? licenseMap['spdx_id'] : null,
    );
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = Uri.parse("https://api.github.com/user");

    var headers = _headersWithDefaults({
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    });

    var response = await _getWithRetry(url, headers: headers);
    if (response.statusCode != 200) {
      Log.d("Github getUserInfo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.HttpResponseFail;
    }

    Map<String, dynamic>? map;
    try {
      map = jsonDecode(response.body);
      if (map == null || map.isEmpty) {
        Log.d("Github getUserInfo: jsonDecode Failed " +
            response.statusCode.toString() +
            ": " +
            response.body);

        throw GitHostException.JsonDecodingFail;
      }
    } catch (ex, st) {
      Log.e("GitHub user Info", ex: ex, stacktrace: st);
      logException(ex, st);
      rethrow;
    }

    if (!map.containsKey('name')) {
      throw Exception('GitHub UserInfo missing name');
    }
    if (!map.containsKey('email')) {
      throw Exception('GitHub UserInfo missing email');
    }
    if (!map.containsKey('login')) {
      throw Exception('GitHub UserInfo missing login');
    }

    var name = "";
    var email = "";
    var login = "";

    if (map['name'] is String) {
      name = map['name'];
    }

    if (map['email'] is String) {
      email = map['email'];
    }

    if (map['login'] is String) {
      login = map['login'];
    }

    return UserInfo(name: name, email: email, username: login);
  }

  String _buildAuthHeader() {
    return 'token $_accessCode';
  }

  Map<String, String> _headersWithDefaults(Map<String, String> headers) {
    return {
      ...headers,
      HttpHeaders.connectionHeader: 'close',
      HttpHeaders.userAgentHeader: 'GitJournal',
    };
  }

  Future<http.Response> _getWithRetry(
    Uri url, {
    Map<String, String>? headers,
  }) {
    return _requestWithRetry(
      () => http.get(url, headers: headers).timeout(const Duration(seconds: 20)),
      'GET $url',
    );
  }

  Future<http.Response> _postWithRetry(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _requestWithRetry(
      () => http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 20)),
      'POST $url',
    );
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() fn,
    String requestName,
  ) async {
    const attempts = 3;
    for (var i = 0; i < attempts; i++) {
      try {
        final response = await fn();
        if (response.statusCode >= 500 && i < attempts - 1) {
          await Future<void>.delayed(Duration(milliseconds: 400 * (i + 1)));
          continue;
        }
        return response;
      } catch (ex) {
        final transient = _isTransientNetworkError(ex);
        if (!transient || i == attempts - 1) rethrow;
        Log.w(
          '$requestName failed, retrying',
          ex: ex,
          props: {'attempt': '${i + 1}/$attempts'},
        );
        await Future<void>.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    throw Exception('$requestName failed unexpectedly');
  }

  bool _isTransientNetworkError(Object ex) {
    if (ex is TimeoutException) {
      return true;
    }
    final msg = ex.toString().toLowerCase();
    return msg.contains('connection closed before full header was received') ||
        msg.contains('connection reset') ||
        msg.contains('connection aborted') ||
        msg.contains('software caused connection abort') ||
        msg.contains('timed out');
  }
}
