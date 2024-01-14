const { Router } = require('express');
const router = Router();
const { crear_test, test_usuario, errores_test, test_detalle_id, participantes_test, lista_participantes, lista_participantes_busqueda, datos_formulario_token, ingreso_participante_test, verificacion_ingreso_participante, secciones_test, agregar_seccion_test, progreso_secciones_participante, datos_token_id_test, progreso_seccion_siguiente_pregunta, registrar_respuesta_unica, mas_preguntas, registrar_respuestas_multiples, registrar_respuestas_CLAVE_VALOR1, registrar_respuestas_CLAVE_VALOR2 } = require('../controllers/Test_/test-controller');

//router.post('/Login', verificaUser);
router.post('/Crear_Test', crear_test);
router.get('/TestUsuario/:id', test_usuario);
router.get('/TestErrores/:id', errores_test);
router.get('/TestDetalle/:id', test_detalle_id);
router.get('/TestParticipantes/:id', participantes_test);
router.get('/ListaParticipantes', lista_participantes);
router.get('/ListaParticipantesBusqueda/:clave', lista_participantes_busqueda);
router.get('/VerificacionIngresoParticipante/:token_participante/:token_test', verificacion_ingreso_participante);
router.get('/SeccionesTest/:id', secciones_test);
router.post('/AgregarSeccionTest', agregar_seccion_test);
router.get('/ProgresoSeccionesParticipante/:p_id_toke_particiapnta/:p_id_token_test', progreso_secciones_participante);
router.get('/TestDataTOken/:p_id_token_test', datos_token_id_test);
router.get('/ProgresoPreguntasSeccion/:p_id_user/:p_id_token_test/:id_seccion', progreso_seccion_siguiente_pregunta);
router.get('/HayMas/:p_id_user/:p_id_token_test/:id_seccion', mas_preguntas);

router.post('/IngresoParticipanteTest', ingreso_participante_test);
router.post('/RegistrarPreguntaUnica', registrar_respuesta_unica);
//registrar_respuestas_multiples
router.post('/RegistrarPreguntaMultiples', registrar_respuestas_multiples);
//registrar_respuestas_CLAVE_VALOR1
router.post('/RegistrarRespuestasCLAVEVALOR1', registrar_respuestas_CLAVE_VALOR1);
//registrar_respuestas_CLAVE_VALOR2
router.post('/RegistrarRespuestasCLAVEVALOR2', registrar_respuestas_CLAVE_VALOR2);


//esta ruta debe ser publica
router.get('/DatosFormulario/:token', datos_formulario_token);

module.exports = router; 