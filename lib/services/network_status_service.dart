import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service class that handles internet connection monitoring.
/// It exposes a stream and a getter for current connectivity status.
class NetworkStatusService {
  final InternetConnection _internetConnection = InternetConnection();
  late StreamSubscription<InternetStatus> _subscription;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get onStatusChange => _connectionController.stream;

  NetworkStatusService() {
    // Start listening to connection changes
    _subscription =
        _internetConnection.onStatusChange.listen((InternetStatus status) {
      final isConnected = status == InternetStatus.connected;
      _connectionController.add(isConnected);
    });
  }

  /// Check current connectivity once.
  Future<bool> checkConnection() async {
    return await _internetConnection.hasInternetAccess;
  }

  /// Stop listening when not needed (avoid leaks)
  void dispose() {
    _subscription.cancel();
    _connectionController.close();
  }
}
