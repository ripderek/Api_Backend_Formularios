const { Router } = require('express');
const router = Router();
const { crear_reporte  } = require('../controllers/Report/reportes-controller');

router.post('/Crear_Reporte', crear_reporte);
//router.get('/Niveles_Seccion/:id', niveles_seccion);
//router.post('/Crear_Nivel/:id_seccion', crear_nivel);

module.exports = router; 