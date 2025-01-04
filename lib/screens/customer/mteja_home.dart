import 'dart:async';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vsw/screens/customer/miamala.dart';

import '../../data_controllers/CustomerController.dart';
import '../../models/agent.dart';
import 'MtejaHomeWidget.dart';
import 'mteja_pending_requests.dart';

class MtejaHome extends StatefulWidget {
  const MtejaHome({Key? key}) : super(key: key);

  @override
  State<MtejaHome> createState() => _MtejaHomeState();
}

class _MtejaHomeState extends State<MtejaHome> {
  late CustomerController customerController;

  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState()  {
    super.initState();
    customerController =Provider.of<CustomerController>(context, listen: false);
    getData();
    _initLocation();


  }

  void _initLocation() async {
    customerController.isLoading = true;

    Location location = Location();
    try {
      LocationData initialLocation = await location.getLocation();
      setState(() {
        customerController.currentCustomerLocation = LatLng(initialLocation.latitude!,initialLocation.longitude!);
      });
      customerController.updateCameraPosition(initialLocation);
    } catch (e) {
      setState(() {
      });
    }

    location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        customerController.currentCustomerLocation = LatLng(locationData.latitude!,locationData.longitude!);
      });
      customerController.updateCameraPosition(locationData);
    });

    customerController.isLoading = false;

  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(10, 10)),
      'assets/agent.png',
    );
  }

  Set<Marker> _buildMarkers(BuildContext context) {
    CustomerController controller = Provider.of<CustomerController>(context);

    for (int i = 0; i < controller.onlineAgents.length; i++) {
      final AgentDataModel agents = controller.onlineAgents[i];
      customerController.markers.add(
        Marker(
          markerId: MarkerId("agent_${agents.agentPhone}"),
          position: LatLng(agents.latitude!, agents.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    if (customerController.currentCustomerLocation != null && _customMarkerIcon != null) {
      customerController.markers.add(
        Marker(
          markerId: MarkerId('Mteja_location'),
          position: customerController.currentCustomerLocation!,
          icon: _customMarkerIcon!,
        ),
      );
    }
    return customerController.markers;
  }






  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerController>(
      builder: (context, customerController, _) {
        final currentCustomerLocation = customerController.currentCustomerLocation;
       String  _profileimage = "https://www.w3schools.com/w3images/avatar2.png";
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              if (customerController.isLoading)
                Center(
                    child: AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 8,
                            ),
                          ),
                          SizedBox(height: 30,),
                          Text('Tafadhali Subiri........',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) => customerController.mapController.complete(controller),
                  tiltGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: currentCustomerLocation ?? LatLng(0, 0),
                    zoom: 14,
                    tilt: 60.0,
                    bearing: 180.0,
                  ),
                  markers: _buildMarkers(context),
                  polylines: customerController.polylines.values.toSet(),
                  myLocationEnabled: true,
                  indoorViewEnabled: true,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                ),
              Positioned(
                  top:0,
                  left: 0,
                  right: 0,

                  child:
                  Container(
                   padding: EdgeInsets.all(16),
                   decoration: BoxDecoration(
                   color: Colors.black.withOpacity(0.3),
                   borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                       bottomRight:Radius.circular(20)
                   )
                  ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(_profileimage),
                        ),
                        SizedBox(width: 8,),
                        Column(
                          children: [
                            Text('danielhussein',
                              style:TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text('location',
                              style:TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                              ),)
                          ],
                        )

                      ],
                    ),
                )
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.2,
                maxChildSize: 0.5,
                builder: (context, scrollController) {
                  return SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)
                        ),
                        color: Colors.grey,
                      ),

                      child: ListView.builder(
                        controller: scrollController,
                         itemCount: 1,
                        itemBuilder: (context,index) {
                          return Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 400,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text('daniel'),
                                  ),
                                ),
                                SizedBox(height: 20), // Add some spacing between the button and the tabs
                                DefaultTabController(
                                  length: 2, // Number of tabs
                                  child: Column(
                                    children: [
                                      TabBar(
                                        tabs: [
                                          Tab(text: "Miamala ya kifedha"),
                                          Tab(text: "Huduma za Usajili"),
                                        ],
                                        labelColor: Colors.black,
                                        indicatorColor: Colors.orange,
                                      ),
                                      SizedBox(
                                        height: 200,
                                        child: TabBarView(
                                          children: [
                                           Miamala(),
                                            _buildServiceColumn(Icons.payment,"Weka Pesa"),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )



              // if (customerController.pendingRequest.isNotEmpty)
                // MtejaPendingRequestWidget()
              // else
                // MtejaHomeWidget()
            ],
          )
        );
      },
    );
  }

  Widget _buildServiceColumn(IconData icon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Colors.orange),
        SizedBox(height: 5),
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.blue)),
      ],
    );
  }

  void getData() async{
    // customerController.showBusy(context, 'Tafadhali Subiri');
    await     customerController.initializeAll("0755823963");
  }
}