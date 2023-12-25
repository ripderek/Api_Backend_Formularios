const { Router } = require('express');
const router = Router();
const { crear_test, test_usuario, errores_test } = require('../controllers/Test_/test-controller');

//router.post('/Login', verificaUser);
router.post('/Crear_Test', crear_test);
router.get('/TestUsuario/:id', test_usuario);
router.get('/TestErrores/:id', errores_test);

module.exports = router; 