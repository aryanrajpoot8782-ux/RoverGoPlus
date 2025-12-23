import 'package:socket_io_client/socket_io_client.dart' as io;

class CaptainSocket {
  static io.Socket? _socket;
  static io.Socket? get socket => _socket;

  // Connect to server
  static void connect(String url, {Function? onConnect}) {
    _socket = io.io(url, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.on('connect', (_) {
      if (onConnect != null) onConnect();
    });
  }

  // Send captain's live location
  static void sendLiveLocation(String captainId, double lat, double lng) {
    _socket?.emit("captain:location", {
      "captainId": captainId,
      "lat": lat,
      "lng": lng,
    });
  }

  // Listen for real-time map updates
  static void onLocationUpdate(Function(dynamic data) callback) {
    _socket?.on("captain:update-marker", callback);
  }

  static void dispose() {
    _socket?.disconnect();
    _socket = null;
  }
}
