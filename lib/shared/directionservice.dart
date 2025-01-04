import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';

class RouteDirections extends ChangeNotifier {
  Future<List<LatLng>> getDirections(LatLng start, LatLng end, {String mode = 'driving'}) async {
    final String apiKey = '$GOOGLE_API_KEY'; // Replace with your Google Maps API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=$mode&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if ((jsonResponse['routes'] as List).isNotEmpty) {
        final points =
        jsonResponse['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      }
    }
    return [];
  }

  List<LatLng> _decodePolyline(String poly) {
    final List<PointLatLng> decodedPolyline =
    PolylinePoints().decodePolyline(poly);
    return decodedPolyline
        .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
        .toList();
  }
}
