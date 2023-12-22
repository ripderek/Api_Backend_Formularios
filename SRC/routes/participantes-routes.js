const { Router } = require('express');
const router = Router();
const { crear_participantes } = require('../controllers/Participantes/participantes-controller');
router.post('/Crear_Participantes', crear_participantes);

module.exports = router; 