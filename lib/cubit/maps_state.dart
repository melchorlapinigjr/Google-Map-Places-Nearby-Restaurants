part of 'maps_cubit.dart';

abstract class MapsState extends Equatable {
  const MapsState();

  @override
  List<Object> get props => [];
}

class MapsInitial extends MapsState {
  const MapsInitial();

  @override
  List<Object> get props => [];
}

class MapLoading extends MapsState {
  const MapLoading();

  @override
  List<Object> get props => [];
}

class MapsLoaded extends MapsState {
  const MapsLoaded();

  @override
  List<Object> get props => [];
}

class PolylinesLoadingState extends MapsState {
  const PolylinesLoadingState();

  @override
  List<Object> get props => [];
}

class PolylinesLoadedState extends MapsState {
  final Map<PolylineId, Polyline> polylines;

  PolylinesLoadedState(this.polylines);
  @override
  List<Object> get props => [polylines];
}

class MarkersLoadedState extends MapsState {
  final Map<MarkerId, Marker> markers;

  MarkersLoadedState(this.markers);
  @override
  List<Object> get props => [markers];
}

class MapAnimateCameraState extends MapsState {
  final coordinate;

  MapAnimateCameraState(this.coordinate);
  @override
  List<Object> get props => [coordinate];
}
