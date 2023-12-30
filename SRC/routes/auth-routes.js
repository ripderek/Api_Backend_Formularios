const { Router } = require('express');
const router = Router();
const { verificaUser, prueba_conexion, verificaUserGoogle } = require('../controllers/Auth/auth-controller')

router.post('/Login', verificaUser);
router.get('/Saludo', prueba_conexion);
router.post('/LoginG', verificaUserGoogle);

module.exports = router; 