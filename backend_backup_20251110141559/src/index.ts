import express from "express";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";
import dotenv from "dotenv";
import { PrismaClient } from "@prisma/client";
import routes from "./routes"; // ✅ correct path

dotenv.config();

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());
app.use("/api", routes);

const PORT = process.env.PORT || 4000;

// ✅ Create HTTP server and attach Socket.IO
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // allow all origins for now (you can restrict later)
    methods: ["GET", "POST"],
  },
});

let onlineCaptains: Record<string, string> = {}; // { socketId: captainId }

// ✅ Handle Socket.IO connections
io.on("connection", (socket) => {
  console.log("🟢 Socket connected:", socket.id);

  // Captain goes online
  socket.on("captainOnline", async (captainId: string) => {
    console.log(`🚗 Captain ${captainId} is now online`);
    onlineCaptains[socket.id] = captainId;

    // Update DB
    await prisma.captain.update({
      where: { id: captainId },
      data: { online: true },
    });
  });

  // Ride request from user
  socket.on("rideRequest", async (data) => {
    console.log("📨 Ride request:", data);

    const ride = await prisma.ride.create({
      data: {
        userId: data.userId,
        pickup: data.pickup,
        dropoff: data.dropoff,
        distanceKm: data.distanceKm,
        fare: data.fare,
        status: "requested",
      },
    });

    // Broadcast to all online captains
    io.emit("newRide", ride);
    console.log("📡 New ride broadcasted:", ride.id);
  });

  // Captain accepts ride
  socket.on("rideAccepted", async ({ rideId, captainId }) => {
    const updatedRide = await prisma.ride.update({
      where: { id: rideId },
      data: { captainId, status: "accepted" },
    });

    io.emit("rideAccepted", updatedRide);
    console.log(`✅ Ride ${rideId} accepted by Captain ${captainId}`);
  });

  // Captain disconnects
  socket.on("disconnect", async () => {
    const captainId = onlineCaptains[socket.id];
    if (captainId) {
      console.log(`🔴 Captain ${captainId} went offline`);
      await prisma.captain.update({
        where: { id: captainId },
        data: { online: false },
      });
      delete onlineCaptains[socket.id];
    }
  });
});

// ✅ Start the server
server.listen(PORT, async () => {
  try {
    await prisma.$connect();
    console.log("✅ Connected to PostgreSQL");
    console.log(`🚀 Backend + Socket.IO running on port ${PORT}`);
  } catch (error) {
    console.error("❌ Database connection failed:", error);
  }
});
