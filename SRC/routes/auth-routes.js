const { Router } = require('express');
const router = Router();
const { verificaUser, prueba_conexion, verificaUserGoogle, datos_formulario_token, login_register_participante } = require('../controllers/Auth/auth-controller')

router.post('/Login', verificaUser);
router.post('/loginParticipante', login_register_participante);
router.get('/Saludo', prueba_conexion);
router.post('/LoginG', verificaUserGoogle);
//router.get('/TestErrores/:id', errores_test);

router.get('/DatosFormulario/:token', datos_formulario_token);

module.exports = router; 