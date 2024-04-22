const { Router } = require("express");
const router = Router();
const {
  verificaUser,
  prueba_conexion,
  verificaUserGoogle,
  datos_formulario_token,
  login_register_participante,
  obtenerIPV4,
  estado_formulario_token,
  crear_usuario,
  verificar_cuenta,
  Logouth,
} = require("../controllers/Auth/auth-controller");

router.post("/Login", verificaUser);
router.post("/loginParticipante", login_register_participante);
router.get("/Saludo", prueba_conexion);
router.post("/LoginG", verificaUserGoogle);
router.get("/ObtenerIP", obtenerIPV4);
router.post("/Crear_Usuario", crear_usuario);
//router.get('/TestErrores/:id', errores_test);

router.get("/DatosFormulario/:token", datos_formulario_token);
//estado_formulario_token
router.get("/estado_formulario_token/:token", estado_formulario_token);
//fucnion para liberar una cuenta es decir verificarla para deje iniciar sesion
//verificar_cuenta
router.post("/verificar_cuenta/:token", verificar_cuenta);
router.post("/Logouth", Logouth);
module.exports = router;
