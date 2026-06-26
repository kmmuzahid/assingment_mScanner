/*
 * @Author: Km Muzahid 
 * @Date: 2026-01-07 12:17:01
 * @Email: km.muzahid@gmail.com
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinlink/my_app..dart';

void main() async {
  if (kDebugMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      debugPrint('Flutter error: ${details.exception}');
      return const Center(child: Text('Oops, something went wrong'));
    };
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}
