import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children:[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: "Enter search term",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(onPressed: ()=>{}, child: Text("Generate with AI")),
                TextButton(onPressed: ()=>{}, child: Text("Add manually")),
              ],
            ),
          )
      )
    );
  }
}