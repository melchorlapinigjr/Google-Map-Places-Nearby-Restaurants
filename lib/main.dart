import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:traveler/map_observer.dart';
import 'package:traveler/screens/mapview.dart';

void main() {
  Bloc.observer = MapBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'traveler app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapView(),
    );
  }
}
