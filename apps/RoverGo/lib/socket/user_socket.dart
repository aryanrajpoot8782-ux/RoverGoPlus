import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class UserSocket {
  static late io.Socket socket;

  static void connect() {
    socket = io.io(
      "http://YOUR_SERVER_IP:4000",
      {
        "transports": ["websocket"],
        "autoConnect": true,
      },
    );

    socket.onConnect((_) {
      debugPrint("🔌 User connected to socket");
    });
  }
}
