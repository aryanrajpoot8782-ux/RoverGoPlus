import { Router } from 'express';
const router = Router();
// TODO: Add user profile, wallet, history endpoints
router.get('/', (req, res) => res.send('User profile endpoint'));
export default router;
