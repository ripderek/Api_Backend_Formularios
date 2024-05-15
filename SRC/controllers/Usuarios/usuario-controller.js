const pool = require("../../db");
const { serialize } = require("cookie");
const jwt = require("jsonwebtoken");

const datos_Usuarios = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await pool.query("select * from FU_usuario_data($1)", [id]);
    console.log(id);
    console.log(result.rows[0]);

    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
const crear_usuario = async (req, res, next) => {
  try {
    //const { id } = req.params;
    const {
      p_contrasena,
      p_correo_institucional,
      p_identificacion,
      p_nombres_apellidos,
      p_celular,
    } = req.body;
    const result = await pool.query("call crear_usuario($1,$2,$3,$4,$5)", [
      p_contrasena,
      p_correo_institucional,
      p_identificacion,
      p_nombres_apellidos,
      p_celular,
    ]);
    return res.status(200).json({ message: "Se creó un Usuario" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion que devuelve las caracteristicas de la interfaz de un usuario
//FU_interfaz_usuario
const interfaz_usuario = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await pool.query("select * from FU_interfaz_usuario($1)", [
      id,
    ]);
    console.log(id);
    console.log(result.rows[0]);

    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//funcion para actualizar la informacion de un usuario segun su id de usuario
const sp_actualizar_info_user = async (req, res, next) => {
  try {
    const {
      p_nombres_apellidos,
      p_identificacion,
      p_numero_celular,
      p_id_user,
    } = req.body;
    const result = await pool.query(
      "call sp_actualizar_info_user($1,$2,$3,$4)",
      [p_nombres_apellidos, p_identificacion, p_numero_celular, p_id_user]
    );
    return res
      .status(200)
      .json({ message: "Se actualizo la informacion del usuario" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//sp_editar_contrasena actualizar la contrasena del perfil
const sp_editar_contrasena = async (req, res, next) => {
  try {
    const { p_id_usuario, p_nueva_contraseña } = req.body;
    const result = await pool.query("call sp_editar_contrasena($1,$2)", [
      p_id_usuario,
      p_nueva_contraseña,
    ]);
    return res
      .status(200)
      .json({ message: "Se actualizo la contrasena del usuario" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//para cerrar la sesion y caducar el token actual
const Logouth = async (req, res, next) => {
  console.log("En la fucnion de logout");
  const { myTokenName } = req.cookies;
  if (!myTokenName) return res.status(401).json({ error: "Null Token" });
  try {
    jwt.verify(myTokenName, "SECRET");
    const serialized = serialize("myTokenName", null, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "none",
      maxAge: 0, //para que vensa la cookie de una vez
      path: "/",
    });
    //maxAge: 1000 * 60 * 60 * 24 * 30, //30 dias
    //1000 * 60 * 15,  // 15 minutos
    res.setHeader("Set-Cookie", serialized);
    return res.status(200).json({ message: "Se termino la sesion " });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//actualizar la interfaz de usuario
const sp_actualizar_interfaz_usuario = async (req, res, next) => {
  try {
    const { p_id_usuario, p_sidenavcolor, p_sidenavtype } = req.body;
    const result = await pool.query(
      "call sp_actualizar_interfaz_usuario($1,$2,$3)",
      [p_id_usuario, p_sidenavcolor, p_sidenavtype]
    );
    return res
      .status(200)
      .json({ message: "Se actualizo la interfaz del usuario" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion para retornar estadisctas del usuario skere modo diablo
const estadistica_paguina_home = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "select * from estadistica_paguina_home($1)",
      [id]
    );
    console.log(id);
    console.log(result.rows);
    console.log(result.rows[0]);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
module.exports = {
  datos_Usuarios,
  crear_usuario,
  interfaz_usuario,
  sp_actualizar_info_user,
  sp_editar_contrasena,
  Logouth,
  sp_actualizar_interfaz_usuario,
  estadistica_paguina_home,
};
