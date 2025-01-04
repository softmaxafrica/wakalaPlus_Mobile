import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/preparedTicket.dart';
import 'package:http/http.dart' as http;

class AgentApiServices extends ChangeNotifier {

  //
  // Future<String> updateTicket(BuildContext context, PreparedCustomerTicket ticket) async {
  //   final String apiUrl = 'http://softmaxafrica-001-site1.gtempurl.com/api/Agent/AttendCustTicket';
  //   final response = await http.put(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(ticket.toJson()),
  //   );
  //
  //   final jsonResponse = json.decode(response.body);
  //   final success = jsonResponse['Success'];
  //   final message = jsonResponse['Message'];
  //
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Ticket updated successfully: $message'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     notifyListeners();
  //     return 'Ticket updated successfully: $message';
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to update ticket: $message'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     notifyListeners();
  //     return 'Failed to update ticket: $message';
  //   }
  // }
  // Future<String> CancelTicket(BuildContext context, PreparedCustomerTicket ticket) async {
  //   final String apiUrl = 'http://softmaxafrica-001-site1.gtempurl.com/api/Agent/CancelTicket';
  //   final response = await http.put(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(ticket.toJson()),
  //   );
  //
  //   // Check if the response status code indicates success
  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body);
  //     final success = jsonResponse['Success'];
  //     // final message = jsonResponse['Message'] ?? 'Unknown error';
  //
  //     notifyListeners();
  //     return 'Success : ${response.statusCode}';
  //
  //   } else {
  //     // Handle non-200 response status codes
  //     return 'Server error: ${response.statusCode}';
  //   }
  // }

}
