import 'dart:convert';

class AgentDataModel {
  final String agentCode;
  final String password;
  final String nida;
  final String agentFullName;
  final String agentPhone;
  final String networksOperating;
  final String serviceGroupCode;
  final String? regstrationStatus;
  final String? address;
  final double? longitude;
  final double? latitude;
  final double? distanceToCustomer;

  AgentDataModel({
    required this.agentCode,
    required this.password,
    required this.nida,
    required this.agentFullName,
    required this.agentPhone,
    required this.networksOperating,
    required this.serviceGroupCode,
    this.regstrationStatus,
    this.address,
    this.longitude,
    this.latitude,
    this.distanceToCustomer,
  });

  factory AgentDataModel.fromJson(Map<String, dynamic> json) {
    return AgentDataModel(
      agentCode: json['agentCode'] as String,
      password: json['password'] as String,
      nida: json['nida'] as String,
      agentFullName: json['agentFullName'] as String,
      agentPhone: json['agentPhone'] as String,
      networksOperating: json['networksOperating'] as String,
      serviceGroupCode: json['serviceGroupCode'] as String,
      regstrationStatus: json['regstrationStatus'] as String?,
      address: json['address'] as String?,
      longitude: json['longitude'] as double?,
      latitude: json['latitude'] as double?,
      distanceToCustomer: json['distanceToCustomer'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentCode': agentCode,
      'password': password,
      'nida': nida,
      'agentFullName': agentFullName,
      'agentPhone': agentPhone,
      'networksOperating': networksOperating,
      'serviceGroupCode': serviceGroupCode,
      'regstrationStatus': regstrationStatus,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'distanceToCustomer': distanceToCustomer,
    };
  }

  static List<AgentDataModel> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List<dynamic>;
    return data.map((json) => AgentDataModel.fromJson(json)).toList();
  }

  static String toJsonList(List<AgentDataModel> models) {
    final data = models.map((model) => model.toJson()).toList();
    return json.encode(data);
  }
}
