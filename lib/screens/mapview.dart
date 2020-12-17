import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveler/cubit/maps_cubit.dart';
import 'package:traveler/utils/coordinates.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController mapController;

  @override
  void dispose() {
    super.dispose();
  }

  //MapsCubit instance
  MapsCubit mapsCubit = MapsCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => MapsCubit(),
          child: Container(
            child: Stack(
              children: [
                buildGoogleMap(),
                buildPositionedWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Positioned buildPositionedWidget() {
    return Positioned(
      left: 20,
      top: 10,
      right: 20,
      child: RaisedButton(
        onPressed: () {
          //move camera to center
          mapsCubit.moveCameraToCenter(mapController);
          //show nearby restaurant
          mapsCubit.nearbyRestaurants();
        },
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(Icons.place, color: Colors.redAccent),
            SizedBox(
              width: 10,
            ),
            Text("Show Nearby Restaurants"),
          ],
        ),
      ),
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onTap: (cordinate) {
        _animateCamera(cordinate);
      },
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(originLatitude, originLongitude),
        zoom: 8.4746,
      ),
      onMapCreated: _onMapCreated,
      markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
      compassEnabled: true,
      tiltGesturesEnabled: false,
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    print("\n\nMap ready.\n\n");
  }

  Future<void> _animateCamera(coordinate) async {
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newLatLng(coordinate));
  }

  moveCameraToCenter() async {
    final GoogleMapController controller = mapController;

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(centerLatitude, centerLongitude), 8.0),
    );
  }
}
