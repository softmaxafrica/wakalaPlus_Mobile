//
// import 'dart:async';
// import 'package:flutter/material.dart';
//  import 'package:flutter_wakala_mobile_app/data_controllers/customerRequestsController.dart';
// import 'package:flutter_wakala_mobile_app/models/customer_request.dart';
//  import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:provider/provider.dart';
//
// import '../../api_services/agent_apis.dart';
// import '../../models/preparedTicket.dart';
//
// class AgentMap extends StatefulWidget {
//   const AgentMap({Key? key}) : super(key: key);
//
//   @override
//   State<AgentMap> createState() => _AgentMapState();
// }
//
// class _AgentMapState extends State<AgentMap> {
//   late CustomerRequestsController _controller;
//   late  AgentApiServices agentApiServices;
//
//
//   bool _isLoading = true;
//   BitmapDescriptor? _customMarkerIcon;
//   Map<PolylineId, Polyline> polylines = {};
//
//   bool _sheetExpanded = true;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =Provider.of<CustomerRequestsController>(context, listen: false);
//     agentApiServices = Provider.of<AgentApiServices>(context, listen: false);
//
//     _controller.initializeRoute("0658009004");
//     _initLocation();
//   }
//
//   void _initLocation() async {
//     Location location = Location();
//     try {
//       LocationData initialLocation = await location.getLocation();
//       setState(() {
//         _controller.currentAgentLocation = LatLng(initialLocation.latitude!,initialLocation.longitude!);
//         _isLoading = false;
//       });
//       _controller.updateCameraPosition(initialLocation);
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//
//     location.onLocationChanged.listen((LocationData locationData) {
//       setState(() {
//         _controller.currentAgentLocation = LatLng(locationData.latitude!,locationData.longitude!);
//       });
//       _controller.updateCameraPosition(locationData);
//
//     });
//   }
//
//   Future<void> _loadCustomMarker() async {
//     _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
//       ImageConfiguration(size: Size(10, 10)),
//       'assets/agent.png',
//     );
//   }
//
//
//   Set<Marker> _buildMarkers(BuildContext context) {
//     CustomerRequestsController controller = Provider.of<
//         CustomerRequestsController>(context);
//
//     for (int i = 0; i < controller.newRequest.length; i++) {
//       final CustomerRequestsModel request = controller.newRequest[i];
//       _controller.markers.add(
//         Marker(
//           markerId: MarkerId("unreached_${request.ticketCreationDateTime}"),
//           position: LatLng(request.customerLatitude, request.customerLongitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     }
//
//     if (_controller.currentAgentLocation != null && _customMarkerIcon != null) {
//       _controller.markers.add(
//         Marker(
//           markerId: MarkerId('agent_location'),
//           position: _controller.currentAgentLocation!,
//           icon: _customMarkerIcon!,
//         ),
//       );
//     }
//
//     return _controller.markers;
//   }
//
//   // Set<Polyline> _buildPolylines(CustomerRequestsController controller) {
//   //   return controller.polylines.values.toSet();
//   // }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<CustomerRequestsController, AgentApiServices>(
//       builder: (context, customerRequestController, agentApiServices, _) {
//         final currentAgentLocation = customerRequestController.currentAgentLocation;
//
//         return Scaffold(
//           body: Stack(
//             children: [
//               if (_isLoading)
//                 Center(child: CircularProgressIndicator(color: Colors.orange))
//               else
//                 GoogleMap(
//                   onMapCreated: (GoogleMapController controller) => _controller.mapController.complete(controller),
//                   tiltGesturesEnabled: true,
//                   initialCameraPosition: CameraPosition(
//                     target: currentAgentLocation ?? LatLng(0, 0),
//                     zoom: 18,
//                     tilt: 60.0,
//                     bearing: 180.0,
//                   ),
//                   markers: _buildMarkers(context),
//                   polylines: customerRequestController.polylines.values.toSet(),                  myLocationEnabled: true,
//                   indoorViewEnabled: true,
//                   compassEnabled: true,
//                   zoomControlsEnabled: true,
//                 ),
//               DraggableScrollableSheet(
//                 initialChildSize: _sheetExpanded ? 0.5 : 0.05,
//                 minChildSize: 0.05,
//                 maxChildSize: 0.5,
//                 builder: (BuildContext context, ScrollController scrollController) {
//                   List<CustomerRequestsModel> sortedRequests = List.from(customerRequestController.newRequest);
//                   sortedRequests.sort((a, b) {
//                     final distanceA = customerRequestController.calculateDistance(
//                       _controller.currentAgentLocation!.latitude,
//                       _controller.currentAgentLocation!.longitude,
//                       a.customerLatitude,
//                       a.customerLongitude,
//                     );
//                     final distanceB = customerRequestController.calculateDistance(
//                       _controller.currentAgentLocation!.latitude,
//                       _controller.currentAgentLocation!.longitude,
//                       b.customerLatitude,
//                       b.customerLongitude,
//                     );
//                     return distanceA.compareTo(distanceB);
//                   });
//
//                   return Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 2,
//                           blurRadius: 8,
//                           offset: Offset(0, -3),
//                         ),
//                       ],
//                     ),
//                     child: ListView(
//                       controller: scrollController,
//                       padding: EdgeInsets.all(20),
//                       children: [
//                         Text(
//                           'Maombi Ya Huduma',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
//                         ),
//                         SizedBox(height: 10),
//                         if (sortedRequests.isEmpty)
//                           Text(
//                             'Hakuna Maombi Yaliyokufikia',
//                             style: TextStyle(fontSize: 18),
//                           )
//                         else
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: sortedRequests.length,
//                             itemBuilder: (context, index) {
//                               final CustomerRequestsModel request = sortedRequests[index];
//                               final distance = _controller.calculateDistance(
//                                 _controller.currentAgentLocation!.latitude,
//                                 _controller.currentAgentLocation!.longitude,
//                                 request.customerLatitude,
//                                 request.customerLongitude,
//                               );
//                               final timeToReach = _controller.calculateTimeToReach(distance);
//                               return Card(
//                                 child: ListTile(
//                                   onTap: () {
//                                     _showAcceptDialog(request);
//                                   },
//                                   title: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text('${request.serviceRequested} '),
//                                           Text('Mtandao: ${request.network}'),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           ElevatedButton(
//                                             onPressed: () {
//                                               LatLng agentLocation = _controller.currentAgentLocation!;
//                                               LatLng customerLocation = LatLng(request.customerLatitude, request.customerLongitude);
//                                               _controller.attendCustomerTicket(customerLocation,request);
//                                             },
//                                             child: Icon(Icons.phone, color: Colors.white),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text('Umbali: ${distance.toStringAsFixed(2)} km, Muda: ${timeToReach.toStringAsFixed(2)} mins'),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//           floatingActionButton: _buildSitishaSafariButton(customerRequestController),
//         );
//       },
//     );
//   }
//
//   Widget _buildSitishaSafariButton(CustomerRequestsController controller) {
//     if (controller.pendingRequest.isNotEmpty) {
//       return FloatingActionButton(
//         onPressed: () {
//           final request = controller.pendingRequest.first; // Assuming you want to cancel the first pending request
//
//           // Convert CustomerRequestsModel to PreparedCustomerTicket
//           final ticket = PreparedCustomerTicket(
//             transactionId: request.transactionId,
//             phoneNumber: request.phoneNumber,
//             description: request.description,
//             network: request.network,
//             serviceRequested: request.serviceRequested,
//             custLatitude: request.customerLatitude,
//             custLongitude: request.customerLongitude,
//             agentCode: request.agentCode,
//             agentLongitude: _controller.currentAgentLocation!.longitude,
//             agentLatitude: _controller.currentAgentLocation!.latitude,
//             LastResponseDateTime: DateTime.now(),
//             createdDate: request.ticketCreationDateTime,
//           );
//
//           _cancelAssignedTicket(ticket);
//         },
//
//         tooltip: 'Sitisha Safari',
//         child: Icon(Icons.close),
//       );
//     } else {
//       return SizedBox(); // Empty container if no ticket is assigned
//     }
//   }
//   void _showAcceptDialog(CustomerRequestsModel request) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text('Maombi Ya Huduma'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Huduma: ${request.serviceRequested}'),
//               SizedBox(height: 10),
//               Text('Mtandao: ${request.network},'),
//               SizedBox(height: 10),
//               Text('Simu: ${request.phoneNumber},'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop(); // Close the dialog
//                     setState(() {
//                   _sheetExpanded = false; // Minimize the sheet
//                 });
//
//                 final ticket = PreparedCustomerTicket(
//                   transactionId: request.transactionId,
//                   phoneNumber: request.phoneNumber,
//                   description: request.description,
//                   network: request.network,
//                   serviceRequested: request.serviceRequested,
//                   custLatitude: request.customerLatitude,
//                   custLongitude: request.customerLongitude,
//                   agentCode: request.agentCode,
//                   agentLongitude: _controller.currentAgentLocation!.longitude,
//                   agentLatitude: _controller.currentAgentLocation!.latitude,
//                   LastResponseDateTime: DateTime.now(),
//                   createdDate: request.ticketCreationDateTime,
//                 );
//
//                 setState(() {
//                   _isLoading = true;
//                 });
//                     await  _acceptCustomerTicket(ticket);
//                 // final responseMessage = await _controller.updateTicket(context, ticket);
//                 setState(() {
//                   _isLoading = false;
//                 });
//                },
//               child: Text('Anza Safari'),
//
//             ),
//             TextButton(
//               onPressed: () {
//                 polylines.clear();
//                 Navigator.of(dialogContext).pop();
//               },
//               child: Text('Sitisha'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../api_services/agent_apis.dart';
import '../../data_controllers/customerRequestsController.dart';
import '../../data_controllers/new_request.dart';
import '../../data_controllers/pending_request.dart';
import '../../models/customer_request.dart';
import '../../models/preparedTicket.dart';

class AgentMap extends StatefulWidget {
  const AgentMap({Key? key}) : super(key: key);

  @override
  State<AgentMap> createState() => _AgentMapState();
}

class _AgentMapState extends State<AgentMap> {
  late CustomerRequestsController _controller;
  late  AgentApiServices agentApiServices;


  BitmapDescriptor? _customMarkerIcon;
  Map<PolylineId, Polyline> polylines = {};

  bool _sheetExpanded = true;

  bool _isLoading=true;


  @override
  void initState() {
    super.initState();
    _controller =Provider.of<CustomerRequestsController>(context, listen: false);
     _controller.initializeRoute("0658009004");
    _initLocation();
    // _controller.clearRoutes();
    // _controller.pendingRequestRoute.clear();
  }

  void _initLocation() async {
    Location location = Location();
    try {
      LocationData initialLocation = await location.getLocation();
      setState(() {
        _controller.currentAgentLocation = LatLng(initialLocation.latitude!,initialLocation.longitude!);
        _isLoading = false;
      });
      _controller.updateCameraPosition(initialLocation);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }

    location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _controller.currentAgentLocation = LatLng(locationData.latitude!,locationData.longitude!);
      });
      _controller.updateCameraPosition(locationData);
    });
  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(10, 10)),
      'assets/agent.png',
    );
  }

  Set<Marker> _buildMarkers(BuildContext context) {
    CustomerRequestsController controller = Provider.of<
        CustomerRequestsController>(context);

    for (int i = 0; i < controller.newRequest.length; i++) {
      final CustomerRequestsModel request = controller.newRequest[i];
      _controller.markers.add(
        Marker(
          markerId: MarkerId("unreached_${request.ticketCreationDateTime}"),
          position: LatLng(request.customerLatitude, request.customerLongitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (_controller.currentAgentLocation != null && _customMarkerIcon != null) {
      _controller.markers.add(
        Marker(
          markerId: MarkerId('agent_location'),
          position: _controller.currentAgentLocation!,
          icon: _customMarkerIcon!,
        ),
      );
    }
    return _controller.markers;
  }



  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerRequestsController, AgentApiServices>(
      builder: (context, customerRequestController, agentApiServices, _) {
        final currentAgentLocation = customerRequestController.currentAgentLocation;

        return Scaffold(
          body: Stack(
            children: [
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: Colors.orange))
              else
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) => _controller.mapController.complete(controller),
                  tiltGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: currentAgentLocation ?? LatLng(0, 0),
                    zoom: 18,
                    tilt: 60.0,
                    bearing: 180.0,
                  ),
                  markers: _buildMarkers(context),
                  polylines: customerRequestController.polylines.values.toSet(),
                  myLocationEnabled: true,
                  indoorViewEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                ),
              if (_controller.pendingRequest.isNotEmpty)
                PendingRequestWidget()

              else
                NewRequestsWidget()
            ],
          ),
        );
      },
    );
  }
}