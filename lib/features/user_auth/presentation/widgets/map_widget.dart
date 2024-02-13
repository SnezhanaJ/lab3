import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../location_services.dart';
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late double lat;
  late double long;
  late Set<Polyline> _polylines;
  late LatLng universityLocation=LatLng(42.004186212873655, 21.409531941596985);

  Marker _currentMarker = const Marker(
    markerId: MarkerId('current_location'),
    position: LatLng(0.0, 0.0), // Initial position, will be updated later
  );
  static CameraPosition _currentPosition = CameraPosition(
    target: LatLng(0.0,0.0),
    zoom: 14.4746,
  );


  @override
  void initState() {
    // Position position = await LocationService().determinePosition();
    // print('this is the position $position');
    LocationService().determinePosition().then((value) {
      setState(() {
        lat = value.latitude;
        long = value.longitude;
        _currentMarker =  Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarkerWithHue(240.0),
          infoWindow: InfoWindow(title: 'Current Location'),
        );
        _currentPosition = CameraPosition(target:  LatLng(lat, long),zoom: 14.4746,);
      });});
    _polylines = {};
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(42.004186212873655, 21.409531941596985),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  static const Marker _UniversityMarker = Marker(
      markerId: MarkerId('_UniversityMarker'),
      icon: BitmapDescriptor.defaultMarker,
       position: LatLng(42.004186212873655, 21.409531941596985));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers:{_UniversityMarker, _currentMarker},
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: _polylines,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToPlace,
        label: const Text('Get Directions'),
        icon: const Icon(Icons.directions),
      ),
    );
  }


  Future<void> _getDirections() async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$lat,$long&destination=${universityLocation.latitude},${universityLocation.longitude}&key=AIzaSyC8ZF_NmZp2A729z3RDxRBJWLeeXYFJZLQ';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      List<LatLng> points = _decodePoly(encodedString: decodedResponse['routes'][0]['overview_polyline']['points']);
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('direction_line'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      });
      LatLngBounds bounds = _calculateBounds(points);
      final GoogleMapController controller = await _controller.future;
      // Zoom out the camera to show the entire polyline
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0)); // Adjust padding as needed
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePoly({required String encodedString}) {
    List<LatLng> poly = [];
    int index = 0, len = encodedString.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encodedString.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encodedString.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }
    return poly;
  }

  Future<void> _goToPlace() async {
    _getDirections();
  }
}