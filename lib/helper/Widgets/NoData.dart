import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String? message;
  const NoData({super.key, this.message = "No Data Found yet"});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("$message"));
  }
}
