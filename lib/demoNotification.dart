
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:myproject/home_page.dart';
import 'package:myproject/utils/supabase_const.dart';

// Define the Notification model
class Notification {
  final String id;
  final String userId;
  final String body;

  Notification({
    required this.id,
    required this.userId,
    required this.body,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      body: json['body'],
    );
  }
}

// Define the WebhookPayload model
class WebhookPayload {
  final String type;
  final String table;
  final Notification record;
  final String schema;

  WebhookPayload({
    required this.type,
    required this.table,
    required this.record,
    required this.schema,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      type: json['type'],
      table: json['table'],
      record: Notification.fromJson(json['record']),
      schema: json['schema'],
    );
  }
}

// Firebase service account configuration
// const String serviceAccountPath = 'service-account.json';
const String serviceAccountPath = 'assets/service-account.json';
late Map<String, dynamic> serviceAccount;

// Supabase configuration
// final String supabaseUrl = Platform.environment['SUPABASE_URL']!;
const String supabaseUrl = appUrl;
const String supabaseServiceRoleKey = appKey;
// final String supabaseServiceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY']!;

// Fetch the Firebase access token
Future<String> getAccessToken() async {
  if (serviceAccount.isEmpty) {
    // serviceAccount = jsonDecode(await File(serviceAccountPath).readAsString());
    serviceAccount = await loadServiceAccount();
  }

  final jwt = JWT(
    {
      'iss': serviceAccount['client_email'],
      'sub': serviceAccount['client_email'],
      'aud': 'https://www.googleapis.com/oauth2/v4/token',
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
    },
  );

  final token = jwt.sign(
    RSAPrivateKey(serviceAccount['private_key']),
    algorithm: JWTAlgorithm.RS256,
  );

  final response = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': token,
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return responseData['access_token'];
  } else {
    throw Exception('Failed to fetch access token: ${response.body}');
  }
}

// Load the service account from the file
Future<Map<String, dynamic>> loadServiceAccount() async {
  final serviceAccountFile = File(serviceAccountPath);

  if (await serviceAccountFile.exists()) {
    return jsonDecode(await serviceAccountFile.readAsString());
  } else {
    throw Exception('Service account file not found: $serviceAccountPath');
  }
}


// Send an FCM notification
Future<void> sendNotification(String fcmToken, String body) async {
  final String accessToken = await getAccessToken();
  // final String projectId = "calorimeterai-24e6e";
  final String projectId = "supabasenotification";

  final response = await http.post(
    Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'message': {
        'token': fcmToken,
        'notification': {
          'title': 'Notification from Supabase',
          'body': body,
        },
      },
    }),
  );

  if (response.statusCode < 200 || response.statusCode > 299) {
    throw Exception('Failed to send notification: ${response.body}');
  }
}

// Main handler for webhook
Future<void> handleRequest(HttpRequest request) async {
  // final payload = WebhookPayload.fromJson(
  //   jsonDecode(await request.transform(utf8.decoder).join()),
  // );
  // Read and decode the request body
  final String content = await utf8.decodeStream(request);

  // Parse the decoded string into JSON
  final Map<String, dynamic> json = jsonDecode(content);

  // Convert JSON to WebhookPayload
  final payload = WebhookPayload.fromJson(json);

  // Do something with the payload
  print('Payload received: $payload');

  // Fetch user profile from Supabase
  final response = await http.get(
    Uri.parse('$supabaseUrl/rest/v1/profiles?id=eq.${payload.record.userId}'),
    headers: {
      'apikey': supabaseServiceRoleKey,
      'Authorization': 'Bearer $supabaseServiceRoleKey',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body).first;
    final String fcmToken = data['fcm_token'];

    // Send FCM notification
    await sendNotification(fcmToken, payload.record.body);

    // Respond to the webhook request
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode({'status': 'success'}));
  } else {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write(jsonEncode({'error': 'Failed to fetch user profile'}));
  }

  await request.response.close();
}

// Entry point for the Dart server
Future<void> main() async {
  serviceAccount =
      jsonDecode(await File(serviceAccountPath).readAsString()); // Load service account

  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server running on port 8080');

  await for (HttpRequest request in server) {
    if (request.method == 'POST') {
      await handleRequest(request);
    } else {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Method not allowed');
      await request.response.close();
    }
  }
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

