const { Router } = require("express");
const router = Router();
const {
  crear_test,
  test_usuario,
  errores_test,
  test_detalle_id,
  participantes_test,
  lista_participantes,
  lista_participantes_busqueda,
  datos_formulario_token,
  ingreso_participante_test,
  verificacion_ingreso_participante,
  secciones_test,
  agregar_seccion_test,
  progreso_secciones_participante,
  datos_token_id_test,
  progreso_seccion_siguiente_pregunta,
  registrar_respuesta_unica,
  mas_preguntas,
  registrar_respuestas_multiples,
  registrar_respuestas_CLAVE_VALOR1,
  registrar_respuestas_CLAVE_VALOR2,
  preguntas_formulario,
  grafica1,
  eliminar_test,
  registrar_ingreso,
  ingresos_usuario,
  progreso_seccion_usuario,
  progreso_preguntas_usuario,
  eliminar_participante_test,
  test_editable,
  Generate_Excel_TODOS,
  Lista_Progreso_Participantes,
  editar_test_no_fechas,
  editar_fechas_test,
  eliminar_seccion_test,
  fu_listar_niveles_num_preguntas,
  sp_actualizar_niveles_preguntas_seccion_test,
} = require("../controllers/Test_/test-controller");

//router.post('/Login', verificaUser);
router.post("/Crear_Test", crear_test);
router.get("/TestUsuario/:id", test_usuario);
router.get("/TestErrores/:id", errores_test);
router.get("/TestDetalle/:id", test_detalle_id);
router.get("/TestParticipantes/:id", participantes_test);
router.get("/ListaParticipantes", lista_participantes);
router.get("/ListaParticipantesBusqueda/:clave", lista_participantes_busqueda);
router.get(
  "/VerificacionIngresoParticipante/:token_participante/:token_test",
  verificacion_ingreso_participante
);
router.get("/SeccionesTest/:id", secciones_test);
router.get("/IngresosUsuarios/:id", ingresos_usuario);
router.get("/ProgresoSeccionesUsuarioMonitoreo/:id", progreso_seccion_usuario);
router.get(
  "/ProgresoPreguntasUsuarioMonitoreo/:id/:id2",
  progreso_preguntas_usuario
);
//test_editable
router.get("/IsEditableTest/:id", test_editable);
//Generate_Excel_TODOS para generar el excel con todas las respuestas de todas las secciones de todos los participantes de un test
router.post("/Generate_Excel_TODOS/:id", Generate_Excel_TODOS);

router.post("/AgregarSeccionTest", agregar_seccion_test);
router.get(
  "/ProgresoSeccionesParticipante/:p_id_toke_particiapnta/:p_id_token_test",
  progreso_secciones_participante
);
router.get("/TestDataTOken/:p_id_token_test", datos_token_id_test);
router.get(
  "/ProgresoPreguntasSeccion/:p_id_user/:p_id_token_test/:id_seccion",
  progreso_seccion_siguiente_pregunta
);
router.get("/HayMas/:p_id_user/:p_id_token_test/:id_seccion", mas_preguntas);

router.post("/IngresoParticipanteTest", ingreso_participante_test);
router.post("/RegistrarPreguntaUnica", registrar_respuesta_unica);
//registrar_respuestas_multiples
router.post("/RegistrarPreguntaMultiples", registrar_respuestas_multiples);
//registrar_respuestas_CLAVE_VALOR1
router.post(
  "/RegistrarRespuestasCLAVEVALOR1",
  registrar_respuestas_CLAVE_VALOR1
);
//registrar_respuestas_CLAVE_VALOR2
router.post(
  "/RegistrarRespuestasCLAVEVALOR2",
  registrar_respuestas_CLAVE_VALOR2
);
router.post("/RegistrarIngreso", registrar_ingreso);

//esta ruta debe ser publica
router.get("/DatosFormulario/:token", datos_formulario_token);
//preguntas_formulario
router.get("/PreguntasFormularios/:id", preguntas_formulario);
//borrar
router.post("/EliminarTest/:id", eliminar_test);
//eliminar participante test
router.post("/EliminarParticipanteTest/:id", eliminar_participante_test);

//grafica1
router.get("/PreguntasFormulariosGrafica/:id/:id2", grafica1);
//Lista del progreso de los participantes en forma de JSON COMPLETO Lista_Progreso_Participantes
router.get(
  "/ListaProgresoParticipantesCompleto/:p_id_test",
  Lista_Progreso_Participantes
);

router.post("/EditarTestNoFechas", editar_test_no_fechas);
//editar_fechas_test
router.post("/editar_fechas_test", editar_fechas_test);
//eliminar_seccion_test
router.post("/eliminar_seccion_test", eliminar_seccion_test);
//fu_listar_niveles_num_preguntas
router.get(
  "/fu_listar_niveles_num_preguntas/:p_id_seccion/:p_id_test",
  fu_listar_niveles_num_preguntas
);
//sp_actualizar_niveles_preguntas_seccion_test
router.post(
  "/sp_actualizar_niveles_preguntas_seccion_test",
  sp_actualizar_niveles_preguntas_seccion_test
);
module.exports = router;
