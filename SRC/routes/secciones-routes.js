const { Router } = require("express");
const router = Router();
const {
  secciones_usuario,
  crear_seccion_usuario,
  secciones_disponibles_test,
  preguntas_niveles_seccion_id,
  data_editable,
  editar_seccion_op,
  agg_invitado_seccion,
  participantes_test_id_test,
  informacion_participante_test,
  eliminar_usuario_seccion,
  search_usuarios,
} = require("../controllers/Secciones/secciones-controller");
const { route } = require("./auth-routes");

//router.post('/Login', verificaUser);
router.get("/Secciones_Usuario/:id", secciones_usuario);
router.post("/Crear_Seccion", crear_seccion_usuario);
router.get("/Secciones_Disponibles_test", secciones_disponibles_test);
router.get("/PreguntasNivelSeccion/:id", preguntas_niveles_seccion_id);
//data_editable
router.get("/data_editable/:id", data_editable);
//editar_seccion_op
router.post("/editar_seccion_op", editar_seccion_op);
//agregar invitado a seccion
router.post("/Invitado_Seccion", agg_invitado_seccion);
//participantes_test_id_test
router.get("/participantes_test_id_test/:id", participantes_test_id_test);
//informacion_participante_test
router.get(
  "/informacion_participante_test/:id_test/:tokenUsuar",
  informacion_participante_test
);
//eliminar_usuario_seccion
router.post("/eliminar_usuario_seccion", eliminar_usuario_seccion);
//search_usuarios
router.get("/search_usuarios/:palabra_clave", search_usuarios);
module.exports = router;
