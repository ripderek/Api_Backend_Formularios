const { Router } = require('express');
const router = Router();
const { secciones_usuario, crear_seccion_usuario } = require('../controllers/Secciones/secciones-controller');
const { route } = require('./auth-routes');

//router.post('/Login', verificaUser);
router.get('/Secciones_Usuario/:id', secciones_usuario);
router.post('/Crear_Seccion', crear_seccion_usuario);

module.exports = router; 