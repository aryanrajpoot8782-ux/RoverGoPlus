# RoverGo+

Production-ready two-wheeler ride-hailing platform inspired by Rapido. Includes:
- RoverGo (Flutter app for riders)
- RoverGo Captain (Flutter app for captains)
- React + TypeScript admin panel
- Node.js + TypeScript backend (PostgreSQL, Prisma, Socket.io, JWT, Firebase, Razorpay, FCM)
- Docker Compose, PM2, GitHub Actions CI/CD

## Structure
- `apps/` — RoverGo, RoverGo Captain, admin panel
- `backend/` — API, real-time, DB
- `docker-compose.yml` — Orchestration
- `.github/workflows/` — CI/CD

See each app's README for setup. Replace placeholders as you build features.