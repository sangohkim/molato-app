import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CircularLoadingIndicator extends StatefulWidget {
  const CircularLoadingIndicator({super.key});

  @override
  State<CircularLoadingIndicator> createState() =>
      _CircularLoadingIndicatorState();
}

class _CircularLoadingIndicatorState extends State<CircularLoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator()),
    );
  }
}
