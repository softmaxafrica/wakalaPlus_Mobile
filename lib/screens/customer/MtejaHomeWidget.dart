import 'package:flutter/material.dart';
 import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 import 'package:provider/provider.dart';

import '../../data_controllers/CustomerController.dart';
import '../../models/preparedTicket.dart';
import '../../shared/functions.dart';

class MtejaHomeWidget extends StatelessWidget {
  CustomerController customerController = CustomerController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerController>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            if(provider.isLoading)
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
                        ),),
                    ],
                  ),
                ),
              ),
            Visibility(
              visible: !provider.isLoading,
              child: DraggableScrollableSheet(
              initialChildSize: provider.sheetExpanded ? 0.5 : 0.2,
              minChildSize: 0.2,
              maxChildSize: 0.7,
              builder: (BuildContext context, ScrollController scrollController) {
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
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        _buildSection(
                                          context,
                                          provider,
                                          'Miamala Ya Kifedha',
                                          Icons.monetization_on_outlined,
                                          provider.moneyNetworksList,
                                          [
                                            _buildServiceColumn(Icons.payments_outlined, 'Toa Pesa'),
                                            _buildServiceColumn(Icons.send_to_mobile_outlined, 'Weka /Tuma Pesa'),
                                            _buildServiceColumn(Icons.app_shortcut, 'Huduma Nyengine')
                                          ],
                                        ),
                                        _buildSection(
                                          context,
                                          provider,
                                          'Huduma Za Usajili',
                                          Icons.app_registration_sharp,
                                          provider.networksList,
                                          [
                                            _buildServiceColumn(Icons.add_reaction_outlined, 'Usajili Mpya'),
                                            _buildServiceColumn(Icons.autorenew, 'Rejesha Laini'),
                                            _buildServiceColumn(Icons.app_registration_sharp, 'Kamilisha Usajili'),
                                          ],
                                        ),
                                        //
                                        FloatingActionButton(onPressed:    () {
                                          GoRouter.of(context).go('/agent_home');
                                        },
                                          child: Text('Wakala'),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            )
          ],
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context,
      CustomerController provider,
      String title,
      IconData icon,
      List<String> itemList,
      List<Widget> gridItems,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.orange),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(
                    'Chagua Mtandao',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  // content: Container(
                  //   width: double.maxFinite,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: itemList.length,
                  //     itemBuilder: (context, index) {
                  //       return ListTile(
                  //         title: Text(itemList[index]),
                  //         onTap: () async {
                  //           Navigator.of(dialogContext).pop(); // Close the dialog
                  //           final ticket = PreparedCustomerTicket(
                  //             transactionId: Functions.generateRequestId(),
                  //             phoneNumber: provider.customer,
                  //             description: 'No Comment',
                  //             network: itemList[index],
                  //             serviceRequested: title,
                  //             custLatitude: provider.currentCustomerLocation!.latitude,
                  //             custLongitude: provider.currentCustomerLocation!.longitude,
                  //             agentCode: '0',
                  //             agentLongitude: null,
                  //             agentLatitude: null,
                  //             lastResponseDateTime: DateTime.now(),
                  //             createdDate: DateTime.now(),
                  //           );
                  //
                  //
                  //           // Provider.of<CustomerController>(context, listen: false).sheetExpanded = false;
                  //
                  //         // Provider.of<CustomerController>(context, listen: false).isLoading = true;
                  //         //    final String result = await provider.sendNewRequest(context, ticket);
                  //           //provider.hideBusy(context);
                  //         // Provider.of<CustomerController>(context, listen: false).isLoading = false;
                  //
                  //           if(result.contains(('successfully')))
                  //             {
                  //               // Provider.of<CustomerController>(context, listen: false).sheetExpanded = false;
                  //               Color snackbarColor = result.contains('successfully') ? Colors.green : Colors.red;
                  //               String snackbarText = result;
                  //               ScaffoldMessenger.of(context).showSnackBar(
                  //                 SnackBar(
                  //                   content: Text(
                  //                     snackbarText,
                  //                     style: TextStyle(
                  //                       color: Colors.white,
                  //                       fontWeight: FontWeight.bold,
                  //                     ),
                  //                   ),
                  //                   backgroundColor: snackbarColor,
                  //                 ),
                  //               );
                  //             }
                  //            else
                  //              {
                  //                // Provider.of<CustomerController>(context, listen: false).sheetExpanded = true;
                  //
                  //                String snackbarText = result;
                  //                ScaffoldMessenger.of(context).showSnackBar(
                  //                  SnackBar(
                  //                    content: Text(
                  //                      snackbarText,
                  //                      style: TextStyle(
                  //                        color: Colors.white,
                  //                        fontWeight: FontWeight.bold,
                  //                      ),
                  //                    ),
                  //                    backgroundColor: Colors.red,
                  //                  ),
                  //                );
                  //              }
                  //
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                      child: Text(
                        'Ondoa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Divider(height: 10, color: Colors.blue),
        GridView.count(
          crossAxisCount: gridItems.length > 2 ? 3 : 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: EdgeInsets.all(5),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridItems.map((item) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(
                        'Chagua Mtandao',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      content: Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(itemList[index]),
                              onTap: () async {
                                Navigator.of(dialogContext).pop(); // Close the dialog
                                final ticket = PreparedCustomerTicket(
                                  transactionId: Functions.generateRequestId(),
                                  phoneNumber: provider.customer,
                                  description: 'No Comment',
                                  network: itemList[index],
                                  serviceRequested: title,
                                  custLatitude: provider.currentCustomerLocation!.latitude,
                                  custLongitude: provider.currentCustomerLocation!.longitude,
                                  agentCode: '0',
                                  agentLongitude: null,
                                  agentLatitude: null,
                                  lastResponseDateTime: DateTime.now(),
                                  createdDate: DateTime.now(),
                                );
                                 // await provider.sendNewRequest(context, ticket);

                              },
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Close the dialog
                          },
                          child: Text(
                            'Tuma Maombi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: item,
            );
          }).toList(),
        ),
      ],
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
}
