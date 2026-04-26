import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_widget.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return const HomeWidget();
  }
}

