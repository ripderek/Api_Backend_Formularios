const pool = require('../../db');
const jwt = require('jsonwebtoken');
const { serialize } = require('cookie');

//funcion para verificar la conexion a la bd
const prueba_conexion = async (req, res, next) => {
    try {
        const users = await pool.query('select 1 as numero');
        console.log(users);
        return res.status(200).json(users.rows[0]);
    } catch (error) {
        next(error);
    }
}

//VerficarUsuario y otorgar token
const verificaUser = async (req, res, next) => {
    try {
        const { correo, contra } = req.body;

        const users = await pool.query('select * from Verification_Auth($1,$2)', [correo, contra]);
        console.log(users);
        console.log(users.rows[0]);
        let verification = users.rows[0];


        //Extraer el resultado del bool para saber si el login es correcto
        let result = verification.verification;
        //console.log('The result is:' + result);

        //Si el Login fallo es decir es diferente del estado 1
        if (result != 1) return res.status(401).json({ error: verification.mensaje });


        //Si no entonces se le otorga un token xd

        const token = jwt.sign({
            exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30,
            email: correo,
        }, 'SECRET') //el secret deberia estan en el .env

        const serialized = serialize('myTokenName', token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'none',
            maxAge: 1000 * 60 * 2, //dos minutos para hacer las pruebas
            path: '/'
        })
        //maxAge: 1000 * 60 * 60 * 24 * 30, //30 dias
        //1000 * 60 * 15,  // 15 minutos
        res.setHeader('Set-Cookie', serialized)
        console.log(serialized);
        console.log(token);

        //Para cargar datos del usuario

        //Guardar el id del usuario en el json
        //Ver si el usuario es admin general y guardar en json para que se guarde como cookie
        const data_auth = await pool.query('select  * from Auth_Data($1,$2)', [correo, contra]);
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
}

module.exports = {
    verificaUser,
    prueba_conexion
};