const { Router } = require('express');
const router = Router();

const { crear_participantes,crear_participantes_test } = require('../controllers/Participantes/participantes-controller');
const { route } = require('./auth-routes');



router.post('/Crear_Participantes', crear_participantes);
router.post('/Crear_Partipantes_Test', crear_participantes_test);

module.exports = router; 