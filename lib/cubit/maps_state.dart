part of 'maps_cubit.dart';

abstract class MapsState extends Equatable {
  const MapsState();
  @override
  List<Object> get props => [];
}

class MapInitial extends MapsState {
  const MapInitial();

  @override
  List<Object> get props => [];
}

class MapLoading extends MapsState {
  const MapLoading();

  @override
  List<Object> get props => [];
}

class PolylinesLoadedState extends MapsState {
  final Map<PolylineId, Polyline> polylines;
  final Map<MarkerId, Marker> markers;

  PolylinesLoadedState({this.polylines, this.markers});
  @override
  List<Object> get props => [polylines, markers];
}
