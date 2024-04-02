const pool = require("../../db");
const jwt = require("jsonwebtoken");
//const { publicIp, publicIpv4, publicIpv6 } = require('public-ip');
//const { publicIpv4 } = require('public-ip');

//const publicIp = require('public-ip');

const { serialize } = require("cookie");

//funcion para verificar la conexion a la bd
const prueba_conexion = async (req, res, next) => {
  try {
    const users = await pool.query("select 1 as numero");
    console.log(users);
    return res.status(200).json(users.rows[0]);
  } catch (error) {
    next(error);
  }
};
const obtenerIPV4 = async (req, res, next) => {
  try {
    try {
      const ip = req.ip;
      console.log(ip);
      return res.status(200).json({ ip: ip });
    } catch (error) {
      console.error("Error al obtener la IP:", error);
      return res.status(500).json({ error: "Error al obtener la IP" });
    }
  } catch (error) {
    console.error("Error al importar public-ip:", error);
    return res.status(500).json({ error: "Error al importar public-ip" });
  }
};

//VerficarUsuario y otorgar token
const verificaUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    console.log(email + "-" + password);
    const users = await pool.query("select * from Verification_Auth($1,$2)", [
      email,
      password,
    ]);

    console.log(users);
    console.log(users.rows[0]);
    let verification = users.rows[0];

    //Extraer el resultado del bool para saber si el login es correcto
    let result = verification.verification;
    //console.log('The result is:' + result);

    //Si el Login fallo es decir es diferente del estado 1
    if (result != 1)
      return res.status(401).json({ error: verification.mensaje });

    //Si no entonces se le otorga un token xd

    const token = jwt.sign(
      {
        exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30,
        email: email,
      },
      "SECRET"
    ); //el secret deberia estan en el .env

    const serialized = serialize("myTokenName", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "none",
      maxAge: 1000 * 60 * 2, //dos minutos para hacer las pruebas
      path: "/",
    });
    //maxAge: 1000 * 60 * 60 * 24 * 30, //30 dias
    //1000 * 60 * 15,  // 15 minutos
    res.setHeader("Set-Cookie", serialized);
    console.log(serialized);
    console.log(token);

    //Para cargar datos del usuario

    //Guardar el id del usuario en el json
    //Ver si el usuario es admin general y guardar en json para que se guarde como cookie
    const data_auth = await pool.query("select  * from Auth_Data($1)", [email]);
    console.log(data_auth.rows[0]);
    //parsear los data_auth para enviar en un solo json
    let data = data_auth.rows[0];
    let userd = data.userd;
    //let isadmin = data.verification;

    //Ver si el usuario es admin de area y guardar en json para que se guarde como cookie
    return res.json({ verification: "true", token: token, id: userd });
  } catch (error) {
    next(error);
  }
};
// funcion para logear a un participante o registrarlo si no esta registrado xd skere modo diablo
const login_register_participante = async (req, res, next) => {
  try {
    const { email, name, hd } = req.body;
    //hd = "uteq.edu.ec"
    //verificar si el dominio ingresado pertencese a la UTEQ
    if (hd === "uteq.edu.ec") {
      //hacer todo el proceso si el dominio es de la U
      //primer verificar si el correo ya esta registrado mediante una consulta de base de datos a tabla participanteGmail
      //auth_data_participantes
      const users = await pool.query(
        "select * from auth_data_participantes($1)",
        [email]
      );

      let verification = users.rows[0];
      //Extraer el resultado del bool para saber si el login es correcto
      let result = verification.r_verificado;
      //si el result es true entonces el correo ya existe por ende solo hay que otorgar token
      if (!result) {
        //como no existe el usuario hay que crearlo skere modo diablo
        //call sp_registrar_participantes()
        const result = await pool.query(
          "call sp_registrar_participantes($1,$2)",
          [email, name]
        );
      }
      //de todos modos otorgar el token ya sea que exista el usuario o recien se halla anadido
      //primero retornar el id del participante dependiendo del correo
      const data_auth = await pool.query(
        "select * from id_participante_emil($1)",
        [email]
      );
      let data = data_auth.rows[0];
      let userd = data.r_id_participante;
      //pasos para el token
      const token = jwt.sign(
        {
          exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30,
          email: email,
        },
        "SECRET"
      ); //el secret deberia estan en el .env

      const serialized = serialize("myTokenName", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "none",
        maxAge: 1000 * 60 * 2, //dos minutos para hacer las pruebas
        path: "/",
      });
      //maxAge: 1000 * 60 * 60 * 24 * 30, //30 dias
      //1000 * 60 * 15,  // 15 minutos
      res.setHeader("Set-Cookie", serialized);
      console.log(serialized);
      console.log(token);
      return res.json({ verification: "true", token: token, id: userd });
    } else
      return res
        .status(404)
        .json({ error: "El correo no pertenece a la UTEQ" });

    //primero verificar si el dominio es la UTEQ, si el dominio no es de la UTEQ = Error xd skere modo diablo

    /*

        
        //Para cargar datos del usuario

        //Guardar el id del usuario en el json
        //Ver si el usuario es admin general y guardar en json para que se guarde como cookie
        const data_auth = await pool.query('select  * from Auth_Data($1)', [email]);
        console.log(data_auth.rows[0]);
        //parsear los data_auth para enviar en un solo json
       
        //let isadmin = data.verification;

        //Ver si el usuario es admin de area y guardar en json para que se guarde como cookie
        */
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para devolver los datos de un formulario por el token enviando de la URL por parametro
//
const datos_formulario_token = async (req, res, next) => {
  try {
    const { token } = req.params;
    console.log(token);
    const result = await pool.query("select * from form_data($1)", [token]);
    console.log(result.rows);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//funcion que retorne el estado que tiene el formulario para saber si esta caducado, proximo, erroneo, no existe, etc.
const estado_formulario_token = async (req, res, next) => {
  try {
    const { token } = req.params;
    console.log(token);
    const result = await pool.query(
      "select * from Estado_Formulario($1) order by r_estado desc limit 1",
      [token]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//VerficarUsuario con el correo que devuelve google y otorgar token

const verificaUserGoogle = async (req, res, next) => {
  try {
    //console.log(req.body);
    const { email } = req.body;

    //console.log('Correo electrónico:', email);

    const users = await pool.query(
      "select * from verification_auth_google($1)",
      [email]
    );
    //console.log(users);
    //console.log(users.rows[0]);
    let verification = users.rows[0];

    //Extraer el resultado del bool para saber si el login es correcto
    let result = verification.verification;
    //console.log('The result is:' + result);

    //Si el Login fallo es decir es diferente del estado 1
    if (result != 1)
      return res.status(401).json({ error: verification.mensaje });

    //Si no entonces se le otorga un token xd

    const token = jwt.sign(
      {
        exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30,
        email: email,
      },
      "SECRET"
    ); //el secret deberia estan en el .env

    const serialized = serialize("myTokenName", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "none",
      maxAge: 1000 * 60 * 2, //dos minutos para hacer las pruebas
      path: "/",
    });
    //maxAge: 1000 * 60 * 60 * 24 * 30, //30 dias
    //1000 * 60 * 15,  // 15 minutos
    res.setHeader("Set-Cookie", serialized);
    console.log(serialized);
    console.log(token);

    //Para cargar datos del usuario

    //Guardar el id del usuario en el json
    //Ver si el usuario es admin general y guardar en json para que se guarde como cookie
    const data_auth = await pool.query("select  * from Auth_Data($1)", [email]);
    console.log(data_auth.rows[0]);
    //parsear los data_auth para enviar en un solo json
    let data = data_auth.rows[0];
    let userd = data.userd;
    //let isadmin = data.verification;

    //Ver si el usuario es admin de area y guardar en json para que se guarde como cookie
    return res.json({ verification: "true", token: token, id: userd });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  verificaUser,
  prueba_conexion,
  verificaUserGoogle,
  datos_formulario_token,
  login_register_participante,
  obtenerIPV4,
  estado_formulario_token,
};
