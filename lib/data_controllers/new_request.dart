import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/customer_request.dart';
import '../models/preparedTicket.dart';
import 'customerRequestsController.dart';
import 'pending_request.dart';

class NewRequestsWidget extends StatelessWidget {
  bool _sheetExpanded = true;
  bool _isLoading = true;

  Future<void> _acceptCustomerTicket(
      BuildContext context, PreparedCustomerTicket ticket) async {
    final _controller =
        Provider.of<CustomerRequestsController>(context, listen: false);
    final response = await _controller.updateTicket(context, ticket);
    String message = response.contains('successfully')
        ? 'Umefanikiwa Kupokea Maombi Ya Huduma'
        : 'Imeshindikana Kupokea Maombi Ya Huduma';
    _showSnackBar(context, message);
    if (response.contains('successfully')) {
      _controller.pendingRequest.add(
        _controller.newRequest.firstWhere(
            (element) => element.transactionId == ticket.transactionId),
      );
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
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
    return Consumer<CustomerRequestsController>(
      builder: (context, provider, _) {
        final newRequests = provider.newRequest;
        final pendingRequests = provider.pendingRequest;

        if (newRequests.isEmpty && pendingRequests.isEmpty) {
          Future.delayed(Duration(seconds: 2), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Hakuna Maombi Yaliyofika Kwa Sasa!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          });
        }

        return DraggableScrollableSheet(
          initialChildSize: _sheetExpanded ? 0.5 : 0.05,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            if (newRequests.isNotEmpty) {
              return _buildRequestList(
                  context, scrollController, newRequests, provider);
            } else if (pendingRequests.isNotEmpty) {
              return PendingRequestWidget();
            } else {
              return SizedBox.shrink(); // Return an empty widget if no requests
            }
          },
        );
      },
    );
  }

  Widget _buildRequestList(
      BuildContext context,
      ScrollController scrollController,
      List<CustomerRequestsModel> requests,
      CustomerRequestsController provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Maombi Mapya',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final CustomerRequestsModel request = requests[index];
                  final distance = provider.calculateDistance(
                    provider.currentAgentLocation!.latitude,
                    provider.currentAgentLocation!.longitude,
                    request.customerLatitude,
                    request.customerLongitude,
                  );
                  final timeToReach = provider.calculateTimeToReach(distance);

                  return Card(
                    elevation: 15,
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_rounded,
                        color: Colors.orange,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text('Maombi Ya Huduma'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(

                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text('Huduma:'),
                                      Text('${request.serviceRequested}'),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                                    children: [
                                      Text('Mtandao:'),
                                      Text(' ${request.network}')
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                                    children: [
                                      Text('Simu:'),
                                      Text(' ${request.phoneNumber}')
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(dialogContext)
                                        .pop(); // Close the dialog
                                    _sheetExpanded =
                                        false; // Minimize the sheet

                                    final ticket = PreparedCustomerTicket(
                                      transactionId: request.transactionId,
                                      phoneNumber: request.phoneNumber,
                                      description: request.description,
                                      network: request.network,
                                      serviceRequested:
                                          request.serviceRequested,
                                      custLatitude: request.customerLatitude,
                                      custLongitude: request.customerLongitude,
                                      agentCode: request.agentCode,
                                      agentLongitude: provider
                                          .currentAgentLocation!.longitude,
                                      agentLatitude: provider
                                          .currentAgentLocation!.latitude,
                                      lastResponseDateTime: DateTime.now(),
                                      createdDate:
                                          request.ticketCreationDateTime,
                                    );

                                    _isLoading = true;
                                    await _acceptCustomerTicket(
                                        context, ticket);
                                    _isLoading = false;
                                  },
                                  child: Text('Anza Safari'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.serviceRequested}',
                                style: new TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mtandao: ${request.network}'),
                          Text('Umbali: ${distance.toStringAsFixed(2)} km.'),
                          Text('Muda Wa Kufika: ${timeToReach.toStringAsFixed(2)} mins')
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          bool callSucceed =
                              await provider.MakePhoneCall(request.phoneNumber);
                          if (!callSucceed) {
                            ScaffoldMessenger(
                              child: SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Kuna Tatizo !\n Imeshindikana Kupiga Simu',
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.phone,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
