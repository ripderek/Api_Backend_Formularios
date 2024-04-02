const { Router } = require("express");
const router = Router();
const {
  secciones_usuario,
  crear_seccion_usuario,
  secciones_disponibles_test,
  preguntas_niveles_seccion_id,
  data_editable,
  editar_seccion_op,
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

module.exports = router;
