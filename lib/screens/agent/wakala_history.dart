import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data_controllers/customerRequestsController.dart';

class WakalaHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerRequestsController>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Expanded(
                  child: provider.requestHistory.isNotEmpty
                      ? ListView.builder(
                    itemCount: provider.requestHistory.length,
                    itemBuilder: (context, index) {
                      final request = provider.requestHistory[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Center(
                                child: Text(
                                  request.serviceRequested,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 5,
                              thickness: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    child: Icon(Icons.person, color: Colors.orange),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Mtandao: ${request.network}'),
                                      Text('Simu: ${request.phoneNumber}'),
                                      Text('Muda: ${request.ticketCreationDateTime}'),
                                      Text('Amehudumiwa: ${request.ticketLastResponseDateTime}'),
                                    ],
                                  ),
                                  Icon(Icons.done_all, color: Colors.green),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text('No request history available'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
