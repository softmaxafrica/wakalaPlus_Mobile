import 'dart:convert';

class CustomerRequestsModel {
  final String transactionId;
  final String agentCode;
  final String phoneNumber;
  final String description;
  final double customerLongitude;
  final double customerLatitude;
  final double? agentLongitude;
  final double? agentLatitude;
  final String serviceRequested;
  final String network;
  final String ticketStatus;
  final DateTime ticketCreationDateTime;
  final DateTime ticketLastResponseDateTime;

  CustomerRequestsModel({
    required this.transactionId,
    required this.agentCode,
    required this.phoneNumber,
    required this.description,
    required this.customerLongitude,
    required this.customerLatitude,
    required this.agentLongitude,
    required this.agentLatitude,
    required this.serviceRequested,
    required this.network,
    required this.ticketStatus,
    required this.ticketCreationDateTime,
    required this.ticketLastResponseDateTime,
  });

  factory CustomerRequestsModel.fromJson(Map<String, dynamic> json) {
    return CustomerRequestsModel(
      transactionId: json['transactionId'],
      agentCode: json['agentCode'],
      phoneNumber: json['phoneNumber'],
      description: json['description'],
      customerLongitude: json['customerLongitude'],
      customerLatitude: json['customerLatitude'],
      agentLongitude: json['agentLongitude'],
      agentLatitude: json['agentLatitude'],
      serviceRequested: json['serviceRequested'],
      network: json['network'],
      ticketStatus: json['ticketStatus'],
      ticketCreationDateTime: DateTime.parse(json['ticketCreationDateTime']),
      ticketLastResponseDateTime: DateTime.parse(json['ticketLastResponseDateTime']),
    );
  }

  static List<CustomerRequestsModel> fromJsonList(String jsonString) {
    final data = json.decode(jsonString)['dataList'] as List<dynamic>;
    return data.map((json) => CustomerRequestsModel.fromJson(json)).toList();
  }
}

