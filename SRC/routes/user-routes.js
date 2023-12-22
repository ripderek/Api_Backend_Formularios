const { Router } = require('express');
const router = Router();
const { datos_Usuarios } = require('../controllers/Usuarios/usuario-controller')

//router.post('/Login', verificaUser);
router.get('/Datos_Usuario/:id', datos_Usuarios)

module.exports = router; 