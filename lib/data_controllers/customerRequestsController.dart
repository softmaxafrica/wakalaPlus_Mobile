
 import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/customer_request.dart';
import '../models/preparedTicket.dart';
import '../shared/constants.dart';

class CustomerRequestsController extends ChangeNotifier {
  List<CustomerRequestsModel> newRequest = [];
  List<CustomerRequestsModel> requestHistory = [];

  Map<PolylineId, Polyline> polylines = {};
  LatLng? currentAgentLocation;
  LatLng? destination;
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  Set<Marker> markers = {};
  bool _isNavigationMode = false;
  List<CustomerRequestsModel> pendingRequest = [];
  late String agent;
  final Location _locationController = Location();

  List<LatLng> pendingRequestRoute = []; // Store current route points

  Future<void> initializeRoute(String agentCode) async {
    this.agent = agentCode;
    await checkForAssignedTicket(agentCode);
    if (pendingRequest.isEmpty) {
      await fetchNewRequests(agentCode);
    }
    await loadRequestHistory(agentCode);
    notifyListeners();
  }

  Future<void> clearPendingRequests() async {
    pendingRequest.clear();
    pendingRequestRoute.clear();
    clearRoutes(); // Clear routes on the map
    notifyListeners();
    await fetchNewRequests(agent);
    notifyListeners();
  }

  void clearRoutes() {
    polylines.clear();
    notifyListeners();
  }

  Future<void> fetchNewRequests(String agentCode) async {
    final String url = '$AGENT_API/GetOpenTicket/$agentCode';
    final Uri uri = Uri.parse(url);
    try {
      final Response response = await get(uri);
      if (response.statusCode == 200) {
        final List<CustomerRequestsModel> requests = CustomerRequestsModel
            .fromJsonList(response.body);

        // Filter requests based on distance from agent
        List<CustomerRequestsModel> filteredRequests = [];
        for (CustomerRequestsModel request in requests) {
          double distance = calculateDistance(
            currentAgentLocation!.latitude,
            currentAgentLocation!.longitude,
            request.customerLatitude,
            request.customerLongitude,
          );
          if (distance <= 10) {
            filteredRequests.add(request);
          }
        }

        newRequest = filteredRequests;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch new requests');
      }
    } catch (e) {
      throw Exception('Failed to fetch new requests: $e');
    }
    notifyListeners();
  }
  Future<void> loadRequestHistory(String agentCode) async {
    final String url = '$AGENT_API/GetTicketHistory/$agentCode';
    final Uri uri = Uri.parse(url);
    try {
      final Response response = await get(uri);
      if (response.statusCode == 200) {
        final List<CustomerRequestsModel> requests = CustomerRequestsModel
            .fromJsonList(response.body);
        requestHistory = requests;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch Requests History');
      }
    } catch (e) {
      throw Exception('Failed to fetch Requests History : $e');
    }
    notifyListeners();
  }

  Future<String> updateTicket(BuildContext context,
      PreparedCustomerTicket ticket) async {
    final String apiUrl = '$AGENT_API/AttendCustTicket';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ticket.toJson()),
    );

    final jsonResponse = json.decode(response.body);
    final success = jsonResponse['Success'];
    final message = jsonResponse['Message'];

    if (response.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Ticket updated successfully: $message'),
      //     backgroundColor: Colors.green,
      //   ),
      //);
      drawRoute(currentAgentLocation!,
          LatLng(ticket.custLatitude, ticket.custLongitude));
      notifyListeners();
      return 'successfully: $message';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $message'),
          backgroundColor: Colors.red,
        ),
      );
      notifyListeners();
      return 'Failed to update ticket: $message';
    }
  }

  Future<String> CancelTicket(BuildContext context,
      PreparedCustomerTicket ticket) async {
    final String apiUrl = '$AGENT_API/CancelTicket';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ticket.toJson()),
    );

    // Check if the response status code indicates success
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final success = jsonResponse['successfully'];
      // final message = jsonResponse['Message'] ?? 'Unknown error';

      clearPendingRequests();
      notifyListeners();
       return 'successfully : ${response.statusCode}';
    } else {
      // Handle non-200 response status codes
      return 'Server error: ${response.statusCode}';
    }
    notifyListeners();
  }

  Future<void> checkForAssignedTicket(String agentCode) async {
    final String url = '$AGENT_API/GetTicketHistory/$agentCode';
    final Uri uri = Uri.parse(url);
    try {
      final Response response = await get(uri);
      if (response.statusCode == 200) {
        final List<CustomerRequestsModel> tickets = CustomerRequestsModel
            .fromJsonList(response.body);

        for (CustomerRequestsModel ticket in tickets) {
          if (ticket.ticketStatus == 'ASSIGNED') {
            // Draw route to this customer's location
            LatLng customerLocation = LatLng(
                ticket.customerLatitude, ticket.customerLongitude);
            pendingRequest.add(ticket);
            await drawRoute(currentAgentLocation!, customerLocation);
            notifyListeners();
            return; // Exit as soon as we find an assigned ticket
          }
        }
      } else {
        throw Exception('Failed to fetch ticket history');
      }
    } catch (e) {
      throw Exception('Failed to fetch ticket history: $e');
    }
    notifyListeners();
  }

  Future<void> updateCameraPosition(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 20,
            tilt: 60.0,
            bearing: 30.0,
          ),
        ),
      );
    }
    notifyListeners();
  }

  double calculateDistance(double startLat, double startLng, double endLat,
      double endLng) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((endLat - startLat) * p) / 2 +
        cos(startLat * p) * cos(endLat * p) *
            (1 - cos((endLng - startLng) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double calculateTimeToReach(double distance) {
    const speed = 2; // km/h
    return (distance / speed) * 60; // Convert hours to minutes
  }

  // Future<void> drawRoute(LatLng agentLocation, LatLng customerLocation) async {
  //   destination = customerLocation;
  //   pendingRequest.clear();
  //   LatLng midpoint = LatLng(
  //     (agentLocation.latitude + customerLocation.latitude) / 2,
  //     (agentLocation.longitude + customerLocation.longitude) / 2,
  //   );
  //
  //   // Calculate the distance between agent and customer locations
  //   double distance = calculateDistance(
  //       agentLocation.latitude, agentLocation.longitude,
  //       customerLocation.latitude, customerLocation.longitude);
  //   double zoomLevel = 20.0;
  //   if (distance > 100) {
  //     zoomLevel = 20.0; // Decrease zoom for longer distances
  //   } else if (distance < 10) {
  //     zoomLevel = 20.0; // Increase zoom for shorter distances
  //   }
  //
  //   CameraPosition cameraPosition = CameraPosition(
  //     target: midpoint, // Set the midpoint as the target
  //     zoom: zoomLevel, // Set the calculated zoom level
  //     tilt: 60.0, // Set tilt for a better view angle
  //     bearing: 180.0, // Set bearing for orientation
  //   );
  //
  //   // Animate the camera to the navigation view
  //   final GoogleMapController controller = await mapController.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  //
  //   final polylinePoints = PolylinePoints();
  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     GOOGLE_API_KEY,
  //     PointLatLng(agentLocation.latitude, agentLocation.longitude),
  //     PointLatLng(customerLocation.latitude, customerLocation.longitude),
  //   );
  //
  //   // if (result.points.isNotEmpty) {
  //   //   List<LatLng> polylineCoordinates = result.points
  //   //       .map((point) => LatLng(point.latitude, point.longitude))
  //   //       .toList();
  //   //
  //   //   final polylineId = PolylineId('route');
  //   //   final polyline = Polyline(
  //   //     polylineId: polylineId,
  //   //     color: Colors.green,
  //   //     points: polylineCoordinates,
  //   //     width: 10,
  //   //   );
  //   //
  //   //   _isNavigationMode = true;
  //   //   polylines.clear();
  //   //   _updateMapMarkers();
  //   //   polylines[polylineId] = polyline;
  //   //
  //   //     pendingRequestRoute = polylineCoordinates;
  //   // }
  //   if (result.points.isNotEmpty) {
  //     _isNavigationMode = true;
  //     polylines.clear();
  //     _updateMapMarkers();
  //   }
  //   await getLocationUpdates();
  //   notifyListeners();
  // }
  Future<void> drawRoute(LatLng agentLocation, LatLng customerLocation) async {
    destination = customerLocation;
    pendingRequest.clear();

    LatLng midpoint = LatLng(
      (agentLocation.latitude + customerLocation.latitude) / 2,
      (agentLocation.longitude + customerLocation.longitude) / 2,
    );

    // Calculate the distance between agent and customer locations
    double distance = calculateDistance(
      agentLocation.latitude,
      agentLocation.longitude,
      customerLocation.latitude,
      customerLocation.longitude,
    );

    double zoomLevel = 20.0;
    if (distance > 100) {
      zoomLevel = 20.0; // Decrease zoom for longer distances
    } else if (distance < 10) {
      zoomLevel = 20.0; // Increase zoom for shorter distances
    }

    CameraPosition cameraPosition = CameraPosition(
      target: midpoint, // Set the midpoint as the target
      zoom: zoomLevel, // Set the calculated zoom level
      tilt: 60.0, // Set tilt for a better view angle
      bearing: 180.0, // Set bearing for orientation
    );

    // Animate the camera to the navigation view
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    final polylinePoints = PolylinePoints();
    final polylineRequest = PolylineRequest(
      origin: PointLatLng(agentLocation.latitude, agentLocation.longitude),
      destination: PointLatLng(customerLocation.latitude, customerLocation.longitude), mode: TravelMode.walking,
    );

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: polylineRequest,
      googleApiKey: GOOGLE_API_KEY, // Optional if not using a proxy
    );

    if (result.points.isNotEmpty) {
      _isNavigationMode = true;
      polylines.clear();
      _updateMapMarkers();
    }

    await getLocationUpdates();
    notifyListeners();
  }

  void _updateMapMarkers() {
    markers.clear();

    markers.add(
      Marker(
        markerId: MarkerId('agent_location'),
        position: LatLng(
            currentAgentLocation!.latitude, currentAgentLocation!.longitude),
      ),
    );

    // Add customer request markers
    for (int i = 0; i < newRequest.length; i++) {
      final CustomerRequestsModel request = newRequest[i];
      markers.add(
        Marker(
          markerId: MarkerId("unreached_${request.ticketCreationDateTime}"),
          position: LatLng(request.customerLatitude, request.customerLongitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        currentAgentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        updateRoute(); // Call updateRoute to update the route
        updateCameraPosition(currentLocation); // Optionally update the camera position
        checkOnAgentReachToCustomer(); // Check and update ticket status
        notifyListeners();
      }
    });
  }

  // Future<void> getLocationUpdates() async {
  //   bool serviceEnabled = await _locationController.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await _locationController.requestService();
  //     if (!serviceEnabled) {
  //       return;
  //     }
  //   }
  //
  //   PermissionStatus permissionGranted = await _locationController
  //       .hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await _locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //
  //   _locationController.onLocationChanged.listen((
  //       LocationData currentLocation) {
  //     if (currentLocation.latitude != null &&
  //         currentLocation.longitude != null) {
  //       currentAgentLocation =
  //           LatLng(currentLocation.latitude!, currentLocation.longitude!);
  //       // if (!isLocationOnRoute(currentAgentLocation!)) {
  //       //   updateRoute(currentAgentLocation!); // Call updateRoute if new location is off the route
  //       // }
  //       updateRoute();
  //       updateCameraPosition(
  //           currentLocation); // Optionally update the camera position
  //       notifyListeners();
  //     }
  //   });
  // }

  bool isLocationOnRoute(LatLng newLocation) {
    const double thresholdDistance = 0.05; // Distance in kilometers to consider "on route"
    for (LatLng point in pendingRequestRoute) {
      if (calculateDistance(
          newLocation.latitude, newLocation.longitude, point.latitude,
          point.longitude) < thresholdDistance) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateRoute() async {
    if (currentAgentLocation == null || destination == null) return;

    List<LatLng> coordinates = await getPolylinePoints(
        currentAgentLocation!, destination!);
    generatePolyLineFromPoints(coordinates);
    pendingRequestRoute = coordinates; // Update the current route points
    notifyListeners();
  }

//
//   Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//   GOOGLE_API_KEY,
//   PointLatLng(start.latitude, start.longitude),
//   PointLatLng(end.latitude, end.longitude),
//   travelMode: TravelMode.walking,
//   );
//   if (result.points.isNotEmpty) {
//   for (PointLatLng point in result.points) {
//   polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//   }
//   } else {
//   print("Error fetching polyline points: ${result.errorMessage}");
//   }
//   notifyListeners();
//
//   return polylineCoordinates;
// }

  Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    // Create a PolylineRequest object
    PolylineRequest polylineRequest = PolylineRequest(
      origin: PointLatLng(start.latitude, start.longitude),
      destination: PointLatLng(end.latitude, end.longitude),
      mode: TravelMode.walking, // Specify travel mode
    );

    try {
      // Call getRouteBetweenCoordinates with the request
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: polylineRequest,
        googleApiKey: GOOGLE_API_KEY,
      );

      if (result.points.isNotEmpty) {
        // Convert the result points to LatLng and add to polylineCoordinates
        for (PointLatLng point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print("Error fetching polyline points: ${result.errorMessage}");
      }
    } catch (e) {
      print("Exception occurred while fetching polyline points: $e");
    }

    notifyListeners();
    return polylineCoordinates;
  }


  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.orange,
      points: polylineCoordinates,
      width: 10,
    );
    polylines[id] = polyline;
    notifyListeners();
  }

  void attendCustomerTicket(LatLng customerLocation,
      CustomerRequestsModel request) {
    drawRoute(currentAgentLocation!, customerLocation);
    notifyListeners();
  }

  List<CustomerRequestsModel> getSortedRequests() {
    List<CustomerRequestsModel> sortedRequests = List.from(newRequest);
    sortedRequests.sort((a, b) {
      final distanceA = calculateDistance(
        currentAgentLocation!.latitude,
        currentAgentLocation!.longitude,
        a.customerLatitude,
        a.customerLongitude,
      );
      final distanceB = calculateDistance(
        currentAgentLocation!.latitude,
        currentAgentLocation!.longitude,
        b.customerLatitude,
        b.customerLongitude,
      );
      return distanceA.compareTo(distanceB);
    });
    return sortedRequests;
  }

  Future<String?> checkOnAgentReachToCustomer() async {
    if (currentAgentLocation == null || pendingRequest.isEmpty) return null;

    final CustomerRequestsModel request = pendingRequest.first;
    final double distance = calculateDistance(
      currentAgentLocation!.latitude,
      currentAgentLocation!.longitude,
      request.customerLatitude,
      request.customerLongitude,
    );

    if (distance < 0.05) {
      final String apiUrl = '$AGENT_API/UpdateTicketStatusToAttended';
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          PreparedCustomerTicket(
            transactionId: request.transactionId,
            phoneNumber: request.phoneNumber,
            description: request.description,
            network: request.network,
            serviceRequested: request.serviceRequested,
            custLatitude: request.customerLatitude,
            custLongitude: request.customerLongitude,
            agentCode: request.agentCode,
            agentLongitude: currentAgentLocation!.longitude,
            agentLatitude: currentAgentLocation!.latitude,
            lastResponseDateTime: DateTime.now(),
            createdDate: request.ticketCreationDateTime,
          ).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final success = jsonResponse['Success'];
        final message = jsonResponse['Message'];

        if (success) {
             SnackBar(
              content: Text('Ticket updated successfully: $message'),
              backgroundColor: Colors.green,
           );
          drawRoute(currentAgentLocation!, LatLng(request.customerLatitude, request.customerLongitude));
          notifyListeners();
          return 'Ticket updated successfully: $message';
        } else {
             SnackBar(
              content: Text('Failed to update ticket: $message'),
              backgroundColor: Colors.red,
           );
          notifyListeners();
          return 'Failed to update ticket: $message';
        }
      } else {
           SnackBar(
            content: Text('Failed to update ticket: Server error ${response.statusCode}'),
            backgroundColor: Colors.red,
         );
        notifyListeners();
        return 'Failed to update ticket: Server error ${response.statusCode}';
      }
    }
    return null;
  }

  Future<bool> MakePhoneCall(String phoneNumber)  async{
       final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunch(phoneCallUri.toString())) {
        await launch(phoneCallUri.toString());
        return true;
      } else {
        throw 'Could not launch phone call.';
        return false;
      }
       notifyListeners();
    }

  }

