class PreparedCustomerTicket {
  final String transactionId;
  final String? phoneNumber;
  final String? description;
  final String network;
  final String serviceRequested;
  final double custLatitude;
  final double custLongitude;
  final String agentCode;
  final double? agentLongitude;
  final double? agentLatitude;
   final DateTime? createdDate;
  final DateTime? lastResponseDateTime;


  PreparedCustomerTicket({
    required this.transactionId,
    this.phoneNumber,
    this.description,
    required this.network,
    required this.serviceRequested,
    required this.custLatitude,
    required this.custLongitude,
    required this.agentCode,
    this.agentLongitude,
    this.agentLatitude,
     this.createdDate,
    this.lastResponseDateTime

   });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'phoneNumber': phoneNumber,
      'description': description,
      'network': network,
      'serviceRequested': serviceRequested,
      'custLatitude': custLatitude,
      'custLongitude': custLongitude,
      'agentCode': agentCode,
      'agentLongitude': agentLongitude,
      'agentLatitude': agentLatitude,
      'createdDate': createdDate?.toIso8601String(),
      'LastResponseDateTime': lastResponseDateTime?.toIso8601String(),
    };
  }

}
