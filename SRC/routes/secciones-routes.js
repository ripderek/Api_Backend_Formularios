const { Router } = require('express');
const router = Router();
const { secciones_usuario, crear_seccion_usuario, secciones_disponibles_test, preguntas_niveles_seccion_id } = require('../controllers/Secciones/secciones-controller');
const { route } = require('./auth-routes');

//router.post('/Login', verificaUser);
router.get('/Secciones_Usuario/:id', secciones_usuario);
router.post('/Crear_Seccion', crear_seccion_usuario);
router.get('/Secciones_Disponibles_test', secciones_disponibles_test);
router.get('/PreguntasNivelSeccion/:id', preguntas_niveles_seccion_id);
module.exports = router; 