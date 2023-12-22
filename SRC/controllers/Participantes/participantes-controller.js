const pool = require('../../db');
//funcion para crear seccion mediante un usuario
const crear_participantes = async (req, res, next) => {
    try {
        //const { id } = req.params;
        const { p_correo_institucional, p_nombres_apellido, p_tipo_identificacion, p_identificacion, p_celular } = req.body;
        const result = await pool.query('call SP_Registrar_Participantes($1,$2,$3,$4,$5)', [p_correo_institucional, p_nombres_apellido, p_tipo_identificacion, p_identificacion, p_celular]);
        return res.status(200).json({ message: "Se creó un Participante" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}


module.exports = {
    crear_participantes
};