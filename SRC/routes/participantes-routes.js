const { Router } = require('express');
const router = Router();
const { crear_participantes } = require('../controllers/Participantes/participantes-controller');
const { route } = require('./auth-routes');
router.post('/Crear_Participantes', crear_participantes);

module.exports = router; 