const { Router } = require('express');
const router = Router();
const { verificaUser, prueba_conexion } = require('../controllers/Auth/auth-controller')

router.post('/Login', verificaUser);
router.get('/Saludo', prueba_conexion)

module.exports = router; 