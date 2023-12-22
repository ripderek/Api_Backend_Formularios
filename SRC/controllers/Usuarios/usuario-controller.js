const pool = require('../../db');


const datos_Usuarios = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_usuario_data($1)', [id]);
        console.log(id);
        console.log(result.rows[0]);

        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
const crear_usuario = async (req, res, next) => {
    try {
        //const { id } = req.params;
        const { p_contraseña, p_correo_institucional, p_identificacion, p_nombres_apellidos, p_celular,p_tipo_identificacion } = req.body;
        const result = await pool.query('call crear_usuario($1,$2,$3,$4,$5,$6)', [p_contraseña, p_correo_institucional, p_identificacion, p_nombres_apellidos, p_celular,p_tipo_identificacion]);
        return res.status(200).json({ message: "Se creó un Usuario" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}


module.exports = {
    datos_Usuarios,
    crear_usuario
};
