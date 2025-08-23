import 'dart:convert';

import 'package:flutter/material.dart';

import '../credentials/api_url.dart';
import 'package:http/http.dart' as http;

class Hello extends StatefulWidget {
  final String token;
  const Hello({super.key, required this.token});

  @override
  State<Hello> createState() => _HelloState();
}

class _HelloState extends State<Hello> {

  String data = "";

  @override
  Widget build(BuildContext context) {
    testAPI();
    if(data != "") {
      return Scaffold(
        body: Center(
          child: Text(data),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Future<void> testAPI() async {
    if(data == ""){
      String apiUrl = '${url}private/hello';
      print("API getting called $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if(response.statusCode == 200){
        print("API called");
        print(response.body);
        data = response.body;
        setState(() {});
      }else{
        print('Failed: ${response.statusCode} - ${response.body}');
      }
    }
  }
}
