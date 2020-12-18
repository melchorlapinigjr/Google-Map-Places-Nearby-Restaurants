import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  MapsCubit _mapsCubit = MapsCubit();

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
          _mapsCubit.moveCameraToCenter(mapController);
          //show nearby restaurant
          _mapsCubit.getNearbyRestaurants();
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

  buildGoogleMap() {
    Map<MarkerId, Marker> markers = {};
    Map<PolylineId, Polyline> polylines = {};

    return BlocConsumer<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PolylinesLoadedState) {
          markers = state.markers;
          polylines = state.polylines;

          print('State markers: $markers ');
          print('State polylines: $polylines ');
        }
      },
      builder: (context, state) {
        return GoogleMap(
          onTap: (cordinate) {
            _mapsCubit.animateCamera(mapController, cordinate);
          },
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(originLatitude, originLongitude),
            zoom: 8.4746,
          ),
          onMapCreated: _onMapCreated,

          //To Do here
          markers: Set<Marker>.of(markers.values),
          polylines: Set<Polyline>.of(polylines.values),
          compassEnabled: true,
          tiltGesturesEnabled: false,
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    print("\n\nMap ready.\n\n");
  }
}
