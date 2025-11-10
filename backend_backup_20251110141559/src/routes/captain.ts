import { Router } from 'express';
const router = Router();
// TODO: Add captain profile, KYC, payout endpoints
router.get('/', (req, res) => res.send('Captain profile endpoint'));
export default router;
