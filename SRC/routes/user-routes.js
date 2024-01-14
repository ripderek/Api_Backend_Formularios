const { Router } = require('express');
const router = Router();
const { datos_Usuarios, crear_usuario, interfaz_usuario } = require('../controllers/Usuarios/usuario-controller')

//router.post('/Login', verificaUser);
router.get('/Datos_Usuario/:id', datos_Usuarios)
router.post('/Crear_Usuario', crear_usuario);
router.get('/Interfaz_Usuario/:id', interfaz_usuario)

module.exports = router; 