import 'dart:io';

import 'package:my_rag_project_client/my_rag_project_client.dart';
import 'package:flutter/material.dart';
import 'package:my_rag_project_flutter/chat_page.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

late SessionManager sessionManager;
late Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ipAddress = Platform.isAndroid ? '10.0.2.2' : 'localhost';

  // Initialize the Client with the server URL and authentication key manager
  client = Client(
    'http://$ipAddress:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )
    // Checks the internet connection at all times
    ..connectivityMonitor = FlutterConnectivityMonitor();

  // Initialize SessionManager to handle user sessions and authentication state
  sessionManager = SessionManager(caller: client.modules.auth);
  await sessionManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SWS AI Chat',
      home: const ChatPage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
      ),
    );
  }
}
