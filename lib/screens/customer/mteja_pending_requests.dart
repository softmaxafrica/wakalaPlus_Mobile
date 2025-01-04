import 'package:flutter/material.dart';
 import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../data_controllers/CustomerController.dart';
 import '../../models/customer_request.dart';
import '../../models/preparedTicket.dart';


class MtejaPendingRequestWidget extends StatelessWidget {
  
  Future<void> _cancelAssignedTicket(
      BuildContext context, PreparedCustomerTicket ticket) async {
    final customerController = Provider.of<CustomerController>(context, listen: false);
     // customerController.isLoading = true;
    final response = await customerController.CancelTicket(context, ticket);
    // customerController.isLoading = false;
    String message = response.contains('successfully')
        ? 'Umefanikiwa Kusitisha Huduma'
        : 'Imeshindikana kusitisha Huduma';
    _showSnackBar(context, message);
    if (response.contains('successfully')) {
      // customerController.pendingRequest.removeWhere(
              // (element) => element.transactionId == ticket.transactionId);
    }
  }
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerController>(
      builder: (context, provider, _) {
        final pendingRequests = provider.pendingRequest;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.2,
                maxChildSize: 0.5,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final CustomerRequestsModel request =
                        pendingRequests[index];
                        final distance = provider.calculateDistance(
                          provider.currentCustomerLocation!.latitude,
                          provider.currentCustomerLocation!.longitude,
                          request.agentLatitude!,
                          request.agentLongitude!,
                        );
                        final timeToReach =
                        provider.calculateTimeToReach(distance);
                        return Card(
                          elevation: 15,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(children: [
                            ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text(
                                        'Maelezo ya Maombi',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Huduma: ${request.serviceRequested}'),
                                          SizedBox(height: 10),
                                          Text('Mtandao: ${request.network},'),
                                          SizedBox(height: 10),
                                          Text('Simu: ${request.phoneNumber},'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext)
                                                .pop(); // Close the dialog

                                            final ticket =
                                            PreparedCustomerTicket(
                                              transactionId:
                                              request.transactionId,
                                              phoneNumber: request.phoneNumber,
                                              description: request.description,
                                              network: request.network,
                                              serviceRequested:
                                              request.serviceRequested,
                                              custLatitude:
                                              request.customerLatitude,
                                              custLongitude:
                                              request.customerLongitude,
                                              agentCode: request.agentCode,
                                              agentLongitude: provider
                                                  .currentCustomerLocation!
                                                  .longitude,
                                              agentLatitude: provider
                                                  .currentCustomerLocation!
                                                  .latitude,
                                              lastResponseDateTime:
                                              DateTime.now(),
                                              createdDate: request
                                                  .ticketCreationDateTime,
                                            );

                                            await _cancelAssignedTicket(context,ticket);
                                            // await provider.CancelTicket(
                                            //     context, ticket);
                                          },
                                          child: Text(
                                            'Sitisha Huduma',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'Onesha Njia',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              title: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${request.serviceRequested} ',
                                        style: new TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          bool callSucceed =
                                          await provider.MakePhoneCall(
                                              request.phoneNumber);
                                          if (!callSucceed) {
                                            ScaffoldMessenger(
                                              child: SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  'Kuna Tatizo !\n Imeshindikana Kupiga Simu',
                                                  style: new TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.phone,
                                          color: Colors.blue,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      'Umbali: ${distance.toStringAsFixed(2)} km, Muda: ${timeToReach.toStringAsFixed(2)} mins'),
                                ],
                              ),
                            ),
                            Divider(
                              height: 5,
                              thickness: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Icon(Icons.roundabout_right,
                                        color: Colors.orange),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Mtandao: ${request.network}'),
                                      Text('Simu: ${request.phoneNumber}'),
                                      Text('Namba ya Muamala: ${request.transactionId}'),
                                    ],
                                  ),
                                  Icon(Icons.done, color: Colors.blue),
                                ],
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
