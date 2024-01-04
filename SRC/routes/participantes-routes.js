const { Router } = require('express');
const router = Router();

const { crear_participantes, crear_participantes_test, data_participante_token_id } = require('../controllers/Participantes/participantes-controller');
const { route } = require('./auth-routes');



router.post('/Crear_Participantes', crear_participantes);
router.post('/Crear_Partipantes_Test', crear_participantes_test);
router.get('/DataParticipante/:id', data_participante_token_id);

module.exports = router; 