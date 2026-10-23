import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  namespace: '/location',
})
export class LocationGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private logger: Logger = new Logger('LocationGateway');
  private connectedUsers = new Map<string, string>(); // socketId -> userId

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    const userId = this.connectedUsers.get(client.id);
    if (userId) {
      this.connectedUsers.delete(client.id);
    }
  }

  @SubscribeMessage('register')
  handleRegister(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string },
  ) {
    this.connectedUsers.set(client.id, data.userId);
    this.logger.log(`User ${data.userId} registered with socket ${client.id}`);
    return { event: 'registered', data: { success: true } };
  }

  @SubscribeMessage('location:update')
  handleLocationUpdate(
    @ConnectedSocket() client: Socket,
    @MessageBody() locationData: any,
  ) {
    const userId = this.connectedUsers.get(client.id);
    if (userId) {
      // Broadcast location update to paired devices
      this.server.emit(`location:${userId}`, locationData);
    }
    return { event: 'location:updated', data: { received: true } };
  }

  @SubscribeMessage('command:send')
  handleCommand(
    @ConnectedSocket() client: Socket,
    @MessageBody() commandData: any,
  ) {
    const { targetUserId, command, parameters } = commandData;
    // Send command to target device
    this.server.emit(`command:${targetUserId}`, { command, parameters });
    return { event: 'command:sent', data: { success: true } };
  }

  @SubscribeMessage('sos:alert')
  handleSOS(
    @ConnectedSocket() client: Socket,
    @MessageBody() sosData: any,
  ) {
    const userId = this.connectedUsers.get(client.id);
    // Broadcast SOS alert to emergency contacts
    this.server.emit('sos:broadcast', { userId, ...sosData });
    return { event: 'sos:received', data: { success: true } };
  }

  // Method to send command from REST API
  sendCommandToDevice(deviceId: string, command: any) {
    this.server.emit(`device:${deviceId}:command`, command);
  }

  // Method to broadcast geofence alert
  sendGeofenceAlert(userId: string, alert: any) {
    this.server.emit(`geofence:${userId}`, alert);
  }
}
