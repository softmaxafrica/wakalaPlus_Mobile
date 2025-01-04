// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_wakala_mobile_app/shared/progress_indicator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:location/location.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../models/agent.dart';
// import '../models/customer_request.dart';
// import '../models/preparedTicket.dart';
// import '../shared/constants.dart';
//
// class CustomerController extends ChangeNotifier {
//   late String customer;
//
//   LatLng? currentCustomerLocation;
//   Map<PolylineId, Polyline> polylines = {};
//   List<RequestDetailsModel> requestHistory = [];
//   List<RequestDetailsModel> pendingRequest = [];
//   List<AgentDataModel> onlineAgents = [];
//   List<String> networksList = ['AIRTEL', 'HALOTEL', 'TIGO', 'VODACOM', 'TTCL'];
//   List<String> moneyNetworksList = [
//     'AIRTEL',
//     'HALOTEL',
//     'TIGO',
//     'VODACOM',
//     'TTCL',
//     'CRDB',
//     'NMB',
//     'NBC',
//     'ABSA',
//     'AKIBA',
//     'AMANA',
//     'AZANIA',
//     'EQUITY',
//     'EXIM',
//     'KCB'
//   ];
//
//   List<LatLng> pendingRequestRoute = [];
//
//   LatLng? destination;
//   final Location _locationController = Location();
//   final Completer<GoogleMapController> mapController = Completer<
//       GoogleMapController>();
//   Set<Marker> markers = {};
//
//   bool isNavigationMode = false;
//   bool sheetExpanded= true;
//
//   bool isLoading = false;
//
//   Timer? _acceptanceCheckTimer;
//
//
//   Future<void> initializeAll(String customerId) async {
//     // Initial setup
//     // sheetExpanded = false;
//     // isLoading=true;
//       this.customer = customerId;
//
//     try {
//       // Logging the start of getAllAgents
//       print('Starting getAllAgents');
//        await getAllAgents();
//       print('Completed getAllAgents');
//
//       // Logging the start of checkForPendingRequests
//       print('Starting checkForPendingRequests');
//       await checkForPendingRequests(customerId);
//       print('Completed checkForPendingRequests');
//
//       // Logging the start of loadRequestHistory
//       print('Starting loadRequestHistory');
//       await loadRequestHistory(customerId);
//       print('Completed loadRequestHistory');
//
//       // Conditional logic based on pending requests
//       if (pendingRequest.isNotEmpty) {
//         // sheetExpanded = false;
//         isNavigationMode = true;
//       } else {
//         // sheetExpanded = true;
//         isNavigationMode = false;
//       }
//     } catch (e) {
//       // Handle any errors that occur during the asynchronous operations
//       print('An error occurred: $e');
//     } finally {
//       // Notify listeners of state changes
//       notifyListeners();
//     }
//   }
//
//   Future<bool> checkForPendingRequests(String customerId) async {
//     isLoading = true;
//     notifyListeners();
//     final String url = '$CUSTOMER_API/GetAssignedTicket/$customerId';
//     final Uri uri = Uri.parse(url);
//
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final dataList = jsonResponse['dataList'];
//
//         if (dataList != null && dataList.isNotEmpty) {
//           final List<RequestDetailsModel> tickets = RequestDetailsModel.fromJsonList(dataList);
//           for (RequestDetailsModel ticket in tickets) {
//             LatLng agentLocation = LatLng(ticket.agentLatitude!, ticket.agentLongitude!);
//             pendingRequest.add(ticket);
//             await drawRoute(currentCustomerLocation!, agentLocation); // Uncomment if needed
//           }
//           isLoading = false;
//           notifyListeners();
//           return true; // Assigned ticket found
//         }
//       } else {
//         throw Exception('Failed to fetch pending requests');
//       }
//     } catch (e) {
//       print('Failed: $e'); // Log the error
//     } finally {
//       isLoading = false;
//       notifyListeners(); // Ensure listeners are notified in case of an error
//     }
//     return false; // No assigned ticket found
//   }
//
//   Future<void> clearPendingRequests() async {
//     pendingRequest.clear();
//     pendingRequestRoute.clear();
//     clearRoutes();
//     notifyListeners();
//   }
//
//   Future<void> updateCameraPosition(LocationData locationData) async {
//     if (locationData.latitude != null && locationData.longitude != null) {
//       final GoogleMapController controller = await mapController.future;
//       controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(locationData.latitude!, locationData.longitude!),
//             zoom: 18,
//             tilt: 60.0,
//             bearing: 180.0,
//           ),
//         ),
//       );
//     }
//     notifyListeners();
//   }
//
//
//   Future<Map<String, double>> calculateDistanceAndTime({required double startLat,required double startLng,required double endLat,required double endLng,required String apiKey,
//   }) async {
//     final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
//         '?units=metric&origins=$startLat,$startLng'
//         '&destinations=$endLat,$endLng&key=$apiKey';
//
//     final response = await http.get(Uri.parse(url)); // Await the future to get the actual response
//
//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final elements = jsonResponse['rows'][0]['elements'][0];
//
//       final distance = elements['distance']['value'] / 1000; // Convert to kilometers
//       final duration = elements['duration']['value'] / 60; // Convert to minutes
//
//       return {'distance': distance, 'duration': duration};
//     } else {
//       throw Exception('Failed to load distance matrix data');
//     }
//   }
//
//   double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
//     const p = 0.017453292519943295; // pi / 180
//     final a = 0.5 - cos((endLat - startLat) * p) / 2 +
//         cos(startLat * p) * cos(endLat * p) *
//             (1 - cos((endLng - startLng) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
//   }
//
//   double calculateTimeToReach(double distance) {
//     const walkingSpeed = 4; // km/h
//     return (distance / walkingSpeed) * 60; // Convert hours to minutes
//   }
//
//   Future<void> drawRoute(LatLng customerLocation, LatLng agentLocation) async {
//     destination = agentLocation;
//     final polylinePoints = PolylinePoints();
//     final result = await polylinePoints.getRouteBetweenCoordinates(
//       GOOGLE_API_KEY,
//       travelMode: TravelMode.walking,
//       PointLatLng(customerLocation.latitude, customerLocation.longitude),
//       PointLatLng(agentLocation.latitude, agentLocation.longitude),
//     );
//
//
//     if (result.points.isNotEmpty) {
//        isNavigationMode = true;
//       polylines.clear();
//      }
//     await getLocationUpdates();
//     notifyListeners();
//   }
//   Future<void> getLocationUpdates() async {
//     bool serviceEnabled = await _locationController.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _locationController.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }
//     PermissionStatus permissionGranted = await _locationController
//         .hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _locationController.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _locationController.onLocationChanged.listen((
//         LocationData currentLocation) {
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         currentCustomerLocation =
//             LatLng(currentLocation.latitude!, currentLocation.longitude!);
//         updateRoute(); // Call updateRoute to update the route
//         updateCameraPosition(
//             currentLocation); // Optionally update the camera position
//         checkOnCustomerToReachAgent(); // Check and update ticket status
//         notifyListeners();
//       }
//     });
//   }
//
//
//   void clearRoutes() {
//     polylines.clear();
//     notifyListeners();
//   }
//
//    Future<bool> checkForAcceptedRequest(BuildContext context) async {
//     final List<RequestDetailsModel> acceptedRequests = [];
//
//     for (RequestDetailsModel request in pendingRequest) {
//       final String apiUrl = '$CUSTOMER_API/GetAcceptedRequest/${request.transactionId}';
//       final response = await http.get(Uri.parse(apiUrl));
//       final jsonResponse = json.decode(response.body);
//       final statusCode = jsonResponse['statusCode'];
//       final dataList = jsonResponse['dataList'];
//
//       if (statusCode == 200 && dataList.isNotEmpty) {
//         acceptedRequests.add(request);
//       }
//     }
//
//     if (acceptedRequests.isNotEmpty) {
//       // Show route to the accepted agent
//       final acceptedRequest = acceptedRequests.last;
//       final agentLocation = LatLng(acceptedRequest.agentLatitude!, acceptedRequest.agentLongitude!);
//       await drawRoute(currentCustomerLocation!, agentLocation);
//
//       // Start navigation mode
//       isNavigationMode = true;
//       isLoading = false;
//       notifyListeners();
//
//       return true; // Agent found
//     }
//
//     return false; // No agent found
//   }
//
//   Future<void> startAcceptanceCheckTimer(BuildContext context) async {
//     isLoading = true;
//     notifyListeners(); // Notify listeners to update the loading state
//
//     const int timeoutSeconds = 120;
//     int elapsedSeconds = 0;
//
//     _acceptanceCheckTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
//       elapsedSeconds += 5;
//
//       // Check if any pending request is accepted
//       if (pendingRequest.isNotEmpty) {
//         bool agentFound = await checkForPendingRequests(customer);
//         if (agentFound) {
//           timer.cancel();
//           isLoading = false;
//           notifyListeners(); // Notify listeners to update the loading state
//
//           // Show success SnackBar
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Agent has picked up your request!',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );
//
//           return;
//         }
//       }
//
//       // Handle timeout
//       if (elapsedSeconds >= timeoutSeconds) {
//         timer.cancel();
//         isLoading = false;
//         notifyListeners(); // Notify listeners to update the loading state
//
//         // Show failure SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'No agent found . Please try again later.',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//
//         Navigator.pop(context);
//       }
//     });
//   }
//
//   Future<void> loadRequestHistory(String customerId) async {
//     final String url = '$CUSTOMER_API/GetTicketHistory/$customerId';
//     final Uri uri = Uri.parse(url);
//     try {
//       final Response response = await get(uri);
//       if (response.statusCode == 200) {
//         final List<RequestDetailsModel> requests = RequestDetailsModel
//             .fromJsonList(response.body);
//         requestHistory = requests;
//         notifyListeners();
//       } else {
//         throw Exception('Failed to fetch Requests History');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch Requests History : $e');
//     }
//     notifyListeners();
//   }
//
//    Future<void> getAllAgents() async {
//     final String url = '$CUSTOMER_API/GetAllAgents';
//     final Uri uri = Uri.parse(url);
//     try {
//       final Response response = await get(uri);
//       if (response.statusCode == 200) {
//         // Parse the JSON response
//         final List<AgentDataModel> agents = AgentDataModel.fromJsonList(response.body);
//         onlineAgents = agents;
//         print('Agents fetched successfully');
//       } else {
//         print('Failed to fetch agents: ${response.statusCode}');
//         throw Exception('Failed to Fetch Agents: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to fetch agents: $e');
//       throw Exception('Failed to fetch agents: $e');
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   Future<void> updateRoute() async {
//     if (currentCustomerLocation == null || destination == null) return;
//     List<LatLng> coordinates = await getPolylinePoints(
//         currentCustomerLocation!, destination!);
//     generatePolyLineFromPoints(coordinates);
//     pendingRequestRoute = coordinates; // Update the current route points
//     notifyListeners();
//   }
//
//   void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.orange,
//       points: polylineCoordinates,
//       width: 10,
//     );
//     polylines[id] = polyline;
//     notifyListeners();
//   }
//
//   Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       GOOGLE_API_KEY,
//       PointLatLng(start.latitude, start.longitude),
//       PointLatLng(end.latitude, end.longitude),
//       travelMode: TravelMode.walking,
//     );
//     if (result.points.isNotEmpty) {
//       for (PointLatLng point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       print("Error fetching polyline points: ${result.errorMessage}");
//     }
//     notifyListeners();
//
//     return polylineCoordinates;
//   }
//
//
//   Future<String> sendNewRequest(BuildContext context,PreparedCustomerTicket ticket) async {
//      pendingRequest.clear();
//      pendingRequestRoute.clear();
//
//      isLoading = true;
//     final String apiUrl = '$CUSTOMER_API/CreateCustomerTicket';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(ticket.toJson()),
//     );
//
//     final jsonResponse = json.decode(response.body);
//     final success = jsonResponse['Success'];
//     final message = jsonResponse['Message'];
//
//     if (response.statusCode == 200) {
//           bool isPendingAccepted = await  checkForAcceptedRequest(context);
//          if(!isPendingAccepted)
//          {
//
//            startAcceptanceCheckTimer(context);
//            //if the method checkForPendingRequests(customer) returns data and the list of pending requests is populated then draw route
//            notifyListeners();
//          }
//
//          else {
//
//            notifyListeners();
//            return 'successfully: $message';
//          }
//
//     }
//      notifyListeners();
//      isLoading = false;
//
//      return 'request sent successfully: $message';
//   }
//
//   Future<String> CancelTicket(BuildContext context,PreparedCustomerTicket ticket) async {
//     final String apiUrl = '$CUSTOMER_API/CancelRequest';
//     final response = await http.put(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(ticket.toJson()),
//     );
//
//     // Check if the response status code indicates success
//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final success = jsonResponse['successfully'];
//       // final message = jsonResponse['Message'] ?? 'Unknown error';
//
//       clearPendingRequests();
//       notifyListeners();
//       initializeAll(customer);
//       return 'successfully : ${response.statusCode}';
//     } else {
//
//       notifyListeners();
//
//     // Handle non-200 response status codes
//       return 'Server error: ${response.statusCode}';
//     }
//   }
//
//
//   Future<String?> checkOnCustomerToReachAgent() async {
//     if (currentCustomerLocation == null || pendingRequest.isEmpty) return null;
//
//     final RequestDetailsModel request = pendingRequest.last;
//
//     // Calculate distance and time using the Google Distance Matrix API
//     try {
//       final result = await calculateDistanceAndTime(
//         startLat: currentCustomerLocation!.latitude,
//         startLng: currentCustomerLocation!.longitude,
//         endLat: request.customerLatitude,
//         endLng: request.customerLongitude,
//         apiKey: GOOGLE_API_KEY, // Replace with your actual Google API key
//       );
//
//       final double distance = result['distance']!; // Distance in kilometers
//       final double duration = result['duration']!; // Duration in minutes
//
//       // Check if the distance is less than 50 meters (0.05 kilometers)
//       if (distance <= 0.05) {
//         final String apiUrl = '$CUSTOMER_API/UpdateTicketStatusToAttended';
//         final response = await http.put(
//           Uri.parse(apiUrl),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(
//             PreparedCustomerTicket(
//               transactionId: request.transactionId,
//               phoneNumber: request.phoneNumber,
//               description: request.description,
//               network: request.network,
//               serviceRequested: request.serviceRequested,
//               custLatitude: currentCustomerLocation!.latitude,
//               custLongitude: currentCustomerLocation!.longitude,
//               agentCode: request.agentCode,
//               agentLongitude: request.agentLongitude,
//               agentLatitude: request.agentLatitude,
//               lastResponseDateTime: DateTime.now(),
//               createdDate: request.ticketCreationDateTime,
//             ).toJson(),
//           ),
//         );
//
//         if (response.statusCode == 200) {
//           final jsonResponse = json.decode(response.body);
//           final success = jsonResponse['Success'];
//           final message = jsonResponse['Message'];
//
//           if (success) {
//             drawRoute(currentCustomerLocation!,
//                 LatLng(request.agentLatitude!, request.agentLongitude!));
//             notifyListeners();
//             return 'Ticket updated successfully: $message';
//           } else {
//             notifyListeners();
//             return 'Failed to update ticket: $message';
//           }
//         } else {
//           notifyListeners();
//           return 'Failed to update ticket: Server error ${response.statusCode}';
//         }
//       }
//     } catch (e) {
//       return 'Error calculating distance and time: $e';
//     }
//
//     return null;
//   }
//
//
//   Future<bool> MakePhoneCall(String phoneNumber)  async{
//     final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunch(phoneCallUri.toString())) {
//       await launch(phoneCallUri.toString());
//       notifyListeners();
//       return true;
//     } else {
//       notifyListeners();
//       throw 'Could not launch phone call.';
//       return false;
//     }
//   }

// }

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/agent.dart';
import '../models/customer_request.dart';
import '../models/preparedTicket.dart';
import '../shared/constants.dart';

class CustomerController extends ChangeNotifier {
  late String customer;

  LatLng? currentCustomerLocation;
  Map<PolylineId, Polyline> polylines = {};
  List<CustomerRequestsModel> requestHistory = [];
  List<CustomerRequestsModel> pendingRequest = [];
  List<AgentDataModel> onlineAgents = [];
  List<String> networksList = ['AIRTEL', 'HALOTEL', 'TIGO', 'VODACOM', 'TTCL'];
  List<String> moneyNetworksList = [
    'AIRTEL',
    'HALOTEL',
    'TIGO',
    'VODACOM',
    'TTCL',
    'CRDB',
    'NMB',
    'NBC',
    'ABSA',
    'AKIBA',
    'AMANA',
    'AZANIA',
    'EQUITY',
    'EXIM',
    'KCB'
  ];

  List<LatLng> pendingRequestRoute = [];
  // List<RequestDetailsModel> tickets = [];

  LatLng? destination;
  final Location _locationController = Location();
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  Set<Marker> markers = {};

  bool isNavigationMode = false;
  bool sheetExpanded = true;
  bool isLoading = false;
  Timer? _acceptanceCheckTimer;

  Future<void> initializeAll(String customerId) async {
    this.customer = customerId;

    try {
       await getAllAgents();
      print('Completed getAllAgents');

      print('Starting checkForPendingRequests');
      // await checkForPendingRequests(customerId);
      print('Completed checkForPendingRequests');

      print('Starting loadRequestHistory');
      // await loadRequestHistory(customerId);
      print('Completed loadRequestHistory');

      // isNavigationMode = pendingRequest.isNotEmpty;
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      notifyListeners();
    }
  }

// Define the list outside of the method

  // Future<bool> checkForPendingRequests(String customerId) async {
  //   isLoading = true;
  //   notifyListeners();
  //   final String url = '$CUSTOMER_API/GetAssignedTicket/$customerId';
  //   final Uri uri = Uri.parse(url);
  //
  //   try {
  //     final response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       final dataList = jsonResponse['dataList'];
  //
  //       print('DataList: $dataList'); // Add this line for debugging
  //
  //       if (dataList != null && dataList.isNotEmpty) {
  //         // Assign values to the list
  //         tickets = RequestDetailsModel.fromJsonList2(dataList);
  //         for (RequestDetailsModel ticket in tickets) {
  //           LatLng agentLocation = LatLng(ticket.agentLatitude!, ticket.agentLongitude!);
  //           pendingRequest.add(ticket);
  //           drawRoute(currentCustomerLocation!, agentLocation);
  //         }
  //         return true;
  //       }
  //     } else {
  //       throw Exception('Failed to fetch pending requests');
  //     }
  //   } catch (e) {
  //     print('Failed: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  //   return false;
  // }

  Future<void> clearPendingRequests() async {
    // pendingRequest.clear();
    pendingRequestRoute.clear();
    clearRoutes();
    notifyListeners();
  }

  Future<void> updateCameraPosition(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 18,
            tilt: 60.0,
            bearing: 180.0,
          ),
        ),
      );
    }
    notifyListeners();
  }

  Future<Map<String, double>> calculateDistanceAndTime({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String apiKey,
  }) async {
    final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?units=metric&origins=$startLat,$startLng'
        '&destinations=$endLat,$endLng&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final elements = jsonResponse['rows'][0]['elements'][0];
      final distance = elements['distance']['value'] / 1000;
      final duration = elements['duration']['value'] / 60;
      return {'distance': distance, 'duration': duration};
    } else {
      throw Exception('Failed to load distance matrix data');
    }
  }

  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((endLat - startLat) * p) / 2 +
        cos(startLat * p) * cos(endLat * p) *
            (1 - cos((endLng - startLng) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double calculateTimeToReach(double distance) {
    const walkingSpeed = 4;
    return (distance / walkingSpeed) * 60;
  }

  // Future<void> drawRoute(LatLng customerLocation, LatLng agentLocation) async {
  //   destination = agentLocation;
  //   final polylinePoints = PolylinePoints();
  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     GOOGLE_API_KEY,
  //     travelMode: TravelMode.walking,
  //     PointLatLng(customerLocation.latitude, customerLocation.longitude),
  //     PointLatLng(agentLocation.latitude, agentLocation.longitude),
  //   );
  //
  //   if (result.points.isNotEmpty) {
  //     isNavigationMode = true;
  //     polylines.clear();
  //   }
  //   await getLocationUpdates();
  //   notifyListeners();
  // }

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
        currentCustomerLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        // updateRoute();
        updateCameraPosition(currentLocation);
        checkOnCustomerToReachAgent();
        notifyListeners();
      }
    });
  }

  void clearRoutes() {
    polylines.clear();
    notifyListeners();
  }

  // Future<bool> checkForAcceptedRequest(BuildContext context) async {
  //   final List<RequestDetailsModel> acceptedRequests = [];
  //
  //   for (RequestDetailsModel request in pendingRequest) {
  //     final String apiUrl = '$CUSTOMER_API/GetAcceptedRequest/${request.transactionId}';
  //     final response = await http.get(Uri.parse(apiUrl));
  //     final jsonResponse = json.decode(response.body);
  //     final statusCode = jsonResponse['statusCode'];
  //     final dataList = jsonResponse['dataList'];
  //
  //     if (statusCode == 200 && dataList.isNotEmpty) {
  //       acceptedRequests.add(request);
  //     }
  //   }
  //
  //   if (acceptedRequests.isNotEmpty) {
  //     final acceptedRequest = acceptedRequests.last;
  //     final agentLocation = LatLng(acceptedRequest.agentLatitude!, acceptedRequest.agentLongitude!);
  //     await drawRoute(currentCustomerLocation!, agentLocation);
  //     isNavigationMode = true;
  //     isLoading = false;
  //     notifyListeners();
  //     return true;
  //   }
  //
  //   return false;
  // }

  // Future<void> startAcceptanceCheckTimer(BuildContext context) async {
  //   isLoading = true;
  //   notifyListeners();
  //
  //   const int timeoutSeconds = 120;
  //   int elapsedSeconds = 0;
  //
  //   _acceptanceCheckTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
  //     elapsedSeconds += 5;
  //
  //     if (pendingRequest.isNotEmpty) {
  //       bool agentFound = await checkForAcceptedRequest(context);
  //       if (agentFound) {
  //         timer.cancel();
  //         isLoading = false;
  //         notifyListeners();
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Agent has picked up your request!',
  //               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //             ),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //
  //         return;
  //       }
  //     }
  //
  //     if (elapsedSeconds >= timeoutSeconds) {
  //       timer.cancel();
  //       isLoading = false;
  //       notifyListeners();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'No agent accepted your request. Please try again.',
  //             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   });
  // }

  void cancelAcceptanceCheckTimer() {
    _acceptanceCheckTimer?.cancel();
  }

  // Future<void> saveRequestHistory(List<RequestDetailsModel> requestHistory) async {
  //   this.requestHistory = requestHistory;
  //   notifyListeners();
  // }

  // Future<void> loadRequestHistory(String customerId) async {
  //   isLoading = true;
  //   notifyListeners();
  //
  //   final String url = '$CUSTOMER_API/GetRequestHistory/$customerId';
  //   final Uri uri = Uri.parse(url);
  //
  //   try {
  //     final response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       final dataList = jsonResponse['dataList'];
  //
  //       if (dataList != null && dataList.isNotEmpty) {
  //         final List<RequestDetailsModel> requestHistory = RequestDetailsModel.fromJsonList(dataList);
  //         this.requestHistory = requestHistory;
  //       }
  //     } else {
  //       throw Exception('Failed to load request history');
  //     }
  //   } catch (e) {
  //     print('Failed to load request history: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<String> CancelTicket(BuildContext context,PreparedCustomerTicket ticket) async {
    final String apiUrl = '$CUSTOMER_API/CancelRequest';
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
      initializeAll(customer);
      return 'successfully : ${response.statusCode}';
    } else {

      notifyListeners();

    // Handle non-200 response status codes
      return 'Server error: ${response.statusCode}';
    }
  }

  Future<void> getAllAgents() async {
    isLoading = true;
    notifyListeners();

    final String url = '$CUSTOMER_API/GetAllAgents';
    final Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['dataList'];

        if (dataList != null && dataList.isNotEmpty) {
          final List<AgentDataModel> agentList = AgentDataModel.fromJsonList(dataList);
          onlineAgents = agentList;
        }
      } else {
        throw Exception('Failed to load agents');
      }
    } catch (e) {
      print('Failed to load agents: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> getAllTransactions(String customerId) async {
  //   isLoading = true;
  //   notifyListeners();
  //
  //   final String url = '$CUSTOMER_API/GetAllTransactions/$customerId';
  //   final Uri uri = Uri.parse(url);
  //
  //   try {
  //     final response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       final dataList = jsonResponse['dataList'];
  //
  //       if (dataList != null && dataList.isNotEmpty) {
  //         final List<RequestDetailsModel> requestHistory = RequestDetailsModel.fromJsonList(dataList);
  //         this.requestHistory = requestHistory;
  //       }
  //     } else {
  //       throw Exception('Failed to load transactions');
  //     }
  //   } catch (e) {
  //     print('Failed to load transactions: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void onDispose() {
    cancelAcceptanceCheckTimer();
  }

  // void updateRoute() {
  //   if (isNavigationMode) {
  //     polylines.clear();
  //     polylines[PolylineId('route')] = Polyline(
  //       polylineId: PolylineId('route'),
  //       points: [
  //         currentCustomerLocation!,
  //         destination!,
  //       ],
  //       color: Colors.blue,
  //       width: 5,
  //     );
  //   }
  //   notifyListeners();
  // }
  // Future<void> updateRoute() async {
  //
  //   if (currentCustomerLocation == null || destination == null) return;
  //   List<LatLng> coordinates = await getPolylinePoints(
  //       currentCustomerLocation!, destination!);
  //   generatePolyLineFromPoints(coordinates);
  //   pendingRequestRoute = coordinates; // Update the current route points
  //   notifyListeners();
  // }
  // Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
  //   List<LatLng> polylineCoordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     GOOGLE_API_KEY,
  //     PointLatLng(start.latitude, start.longitude),
  //     PointLatLng(end.latitude, end.longitude),
  //     travelMode: TravelMode.walking,
  //   );
  //   if (result.points.isNotEmpty) {
  //     for (PointLatLng point in result.points) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //   } else {
  //     print("Error fetching polyline points: ${result.errorMessage}");
  //   }
  //   notifyListeners();
  //
  //   return polylineCoordinates;
  // }
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
  Future<void> checkOnCustomerToReachAgent() async {
    if (destination != null && currentCustomerLocation != null) {
      final distance = calculateDistance(
        currentCustomerLocation!.latitude,
        currentCustomerLocation!.longitude,
        destination!.latitude,
        destination!.longitude,
      );
      final timeToReach = calculateTimeToReach(distance);

      print('Distance to agent: $distance km, Estimated time: $timeToReach minutes');
    }
  }
  Future<bool> MakePhoneCall(String phoneNumber)  async{
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneCallUri.toString())) {
      await launch(phoneCallUri.toString());
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      throw 'Could not launch phone call.';
      return false;
    }
  }
  // Future<String> sendNewRequest(BuildContext context, PreparedCustomerTicket ticket) async {
  //   // Set loading state to true and notify listeners
  //   isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     // Clear existing pending requests and routes
  //     clearPendingRequests();
  //
  //     // Send the new request to the server
  //     final String apiUrl = '$CUSTOMER_API/CreateCustomerTicket';
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(ticket.toJson()),
  //     );
  //     if (response.statusCode == 200) {
  //       // Request sent successfully
  //       bool isPendingAccepted = await checkForAcceptedRequest(context);
  //       if (!isPendingAccepted) {
  //         // If no agent has accepted the request yet, start the acceptance check timer
  //         startAcceptanceCheckTimer(context);
  //       } else {
  //         // Notify listeners and return success message
  //         notifyListeners();
  //         return 'Request sent successfully';
  //       }
  //     } else {
  //       // Handle HTTP error
  //       throw Exception('Failed to send request: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle exceptions
  //     print('Error sending request: $e');
  //     return 'Error sending request: $e';
  //   } finally {
  //     // Reset loading state and notify listeners
  //     isLoading = false;
  //     notifyListeners();
  //   }
  //   // Return a default message if no specific message is returned earlier
  //   return 'Request sent successfully';
  // }

}
