const { Router } = require('express');
const router = Router();
const { niveles_seccion, crear_nivel } = require('../controllers/Niveles/niveles-controller');

//router.post('/Login', verificaUser);
router.get('/Niveles_Seccion/:id', niveles_seccion);
router.post('/Crear_Nivel/:id_seccion', crear_nivel);

module.exports = router; 