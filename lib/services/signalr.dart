import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:vsw/shared/constants.dart';

class SignalRService with ChangeNotifier {
  final _hubConnection = HubConnectionBuilder()
       .withUrl('$BASE_URL/SignalHub') // Replace with your server URL
      //.withUrl('http://localhost:5217/SignalHub') // Replace with your server URL
      .build();

  final List<String> _messages = [];
  bool _isConnected = false;

  List<String> get messages => _messages;
  bool get isConnected => _isConnected;

  Future<void> initializeSignalR() async {
    _hubConnection.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _messages.add(arguments[0] as String);
        notifyListeners();
      }
    });

    try {
      await _hubConnection.start();
      _isConnected = true;
      notifyListeners();
      print('SignalR connected');
    } catch (e) {
      print('Error connecting to SignalR: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    if (_isConnected) {
      await _hubConnection.invoke('SendMessage', args: [message]);
    }
  }

  Future<void> stopConnection() async {
    await _hubConnection.stop();
    _isConnected = false;
    notifyListeners();
  }
}
