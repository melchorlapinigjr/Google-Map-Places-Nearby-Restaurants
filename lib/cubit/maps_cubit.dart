import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as mapweb;
import 'package:traveler/utils/api_key.dart';
import 'package:traveler/utils/coordinates.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  MapsCubit() : super(MapsInitial());

  Future<void> initMapController() async {}

  createPoliylineCoordinates() async {
    _loadingState();
    // this will hold each polyline coordinate as Lat and Lng pairs
    final List<LatLng> polylineCoordinates = [];

    // this is the key object - the PolylinePoints
    // which generates every polyline between start and finish
    final PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints
        .getRouteBetweenCoordinates(
      Secrets.GOOGLE_API_KEY, // Google Maps API Key
      PointLatLng(originLatitude, originLongitude),
      PointLatLng(destLatitude, destLongitude),
      travelMode: TravelMode.driving,
    )
        .catchError((onError) {
      print("\n\nAn error occured possibly due to network issues\n\n");
    });

    if (result != null) {
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        //Assign gathered polyline coordinates to polylines
        polylines(polylineCoordinates);
      } else {
        print("No coordinate points available.");
      }
    } else {
      print("\n\nNo coordinates found between routes.\n\n");
    }
  }

  polylines(List<LatLng> polylineCoordinates) {
    // this will hold the generated polylines
    final Map<PolylineId, Polyline> polylines = {};

    final PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;

    emit(PolylinesLoadedState(polylines));
  }

  // this will hold my markers
  final Map<MarkerId, Marker> markers = {};

  addMarker(
      LatLng position,
      String nameId,
      BitmapDescriptor descriptor,
      String infoTitle,
      String infoVicinity,
      String infoRating,
      bool isRestaurant) {
    final MarkerId markerId = MarkerId(nameId);

    Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: position,
        draggable: false,
        infoWindow: isRestaurant
            ? InfoWindow(
                title: infoTitle,
                snippet: "Rating: $infoRating",
              )
            : InfoWindow());
    markers[markerId] = marker;
    print("Marker created!");
  }

  animateCamera(coordinate) {
    emit(MapAnimateCameraState(coordinate));
  }

  nearbyRestaurants() async {
    _loadingState();

    mapweb.GoogleMapsPlaces _places =
        mapweb.GoogleMapsPlaces(apiKey: Secrets.GOOGLE_API_KEY);

    final centerLocation = mapweb.Location(centerLatitude, centerLongitude);
    final result = await _places.searchNearbyWithRadius(centerLocation, 200000,
        type: "resturant");

    if (result.status == "OK") {
      print(result.results.toString());
      print("\nNearby request successful!\n");

      result.results.forEach((data) {
        addMarker(
            LatLng(data.geometry.location.lat, data.geometry.location.lng),
            data.name,
            BitmapDescriptor.defaultMarkerWithHue(25),
            data.name,
            data.reference,
            data.rating.toString(),
            true);
      });

      emit(MarkersLoadedState(markers));
    }
  }

  _loadingState() {
    emit(MapLoading());
  }

  moveCameraToCenter(mapController) async {
    final GoogleMapController controller = mapController;

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(centerLatitude, centerLongitude), 8.0),
    );
  }

  setInitialRouteMarkers() {
    /// Add origin marker
    addMarker(LatLng(originLatitude, originLongitude), "origin",
        BitmapDescriptor.defaultMarker, '', '', '', false);

    /// Add destination marker
    addMarker(LatLng(destLatitude, destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90), '', '', '', false);
    emit(MarkersLoadedState(markers));
  }
}
