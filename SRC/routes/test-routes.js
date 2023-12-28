const { Router } = require('express');
const router = Router();
const { crear_test, test_usuario, errores_test, test_detalle_id, participantes_test, lista_participantes, lista_participantes_busqueda } = require('../controllers/Test_/test-controller');

//router.post('/Login', verificaUser);
router.post('/Crear_Test', crear_test);
router.get('/TestUsuario/:id', test_usuario);
router.get('/TestErrores/:id', errores_test);
router.get('/TestDetalle/:id', test_detalle_id);
router.get('/TestParticipantes/:id', participantes_test);
router.get('/ListaParticipantes', lista_participantes);
router.get('/ListaParticipantesBusqueda/:clave', lista_participantes_busqueda);

module.exports = router; 