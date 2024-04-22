const { Router } = require("express");
const router = Router();
const {
  datos_Usuarios,
  crear_usuario,
  interfaz_usuario,
  sp_actualizar_info_user,
  sp_editar_contrasena,
  Logouth,
  sp_actualizar_interfaz_usuario,
  estadistica_paguina_home,
} = require("../controllers/Usuarios/usuario-controller");

//router.post('/Login', verificaUser);
router.get("/Datos_Usuario/:id", datos_Usuarios);
router.post("/Crear_Usuario", crear_usuario);
router.get("/Interfaz_Usuario/:id", interfaz_usuario);
router.post("/sp_actualizar_info_user", sp_actualizar_info_user);
router.post("/sp_editar_contrasena", sp_editar_contrasena);
router.post("/Logouth", Logouth);
router.post("/sp_actualizar_interfaz_usuario", sp_actualizar_interfaz_usuario);
router.get("/estadistica_paguina_home/:id", estadistica_paguina_home);
module.exports = router;
