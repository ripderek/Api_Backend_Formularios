const { Router } = require('express');
const router = Router();
const { crear_test } = require('../controllers/Test_/test-controller');

//router.post('/Login', verificaUser);
router.post('/Crear_Test', crear_test);

module.exports = router; 