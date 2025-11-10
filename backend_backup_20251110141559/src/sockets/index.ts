import { Server } from 'socket.io';

export function initSockets(io: Server) {
  io.on('connection', (socket) => {
    console.log('Socket connected:', socket.id);
    // TODO: Add real-time ride matching, status updates
    socket.on('disconnect', () => {
      console.log('Socket disconnected:', socket.id);
    });
  });
}
