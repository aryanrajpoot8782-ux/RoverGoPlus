import { Router, Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import jwt from "jsonwebtoken";

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "rovergo_secret_key";

// ✅ Middleware to verify user JWT token
function verifyToken(req: Request, res: Response, next: Function) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "No token provided" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    (req as any).user = decoded;
    next();
  } catch {
    return res.status(403).json({ message: "Invalid or expired token" });
  }
}

// ✅ POST /api/rides/request
router.post("/request", verifyToken, async (req: Request, res: Response) => {
  try {
    const { pickup, dropoff, distanceKm, fare } = req.body;
    const userId = (req as any).user.id;

    if (!pickup || !dropoff) {
      return res.status(400).json({ message: "Pickup and dropoff are required" });
    }

    const ride = await prisma.ride.create({
      data: {
        userId,
        pickup,
        dropoff,
        distanceKm: parseFloat(distanceKm),
        fare: parseFloat(fare),
        status: "requested",
      },
    });

    res.status(201).json({
      message: "Ride request created successfully",
      ride,
    });
  } catch (error) {
    console.error("❌ Ride request error:", error);
    res.status(500).json({ message: "Failed to create ride request" });
  }
});

export default router;
