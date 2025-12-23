import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RiderSocket {
  static io.Socket? socket;

  static void connect() {
    socket = io.io(
      "http://10.0.2.2:4000",
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint("🧑‍🦯 Rider connected to socket");
    });
  }
}
