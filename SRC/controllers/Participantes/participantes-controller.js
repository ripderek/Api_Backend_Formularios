const pool = require('../../db');
//funcion para crear seccion mediante un usuario
const crear_participantes = async (req, res, next) => {
    try {
        //const { id } = req.params;
        const { p_correo_institucional, p_nombres_apellido } = req.body;
        const result = await pool.query('call SP_Registrar_Participantes($1,$2)', [p_correo_institucional, p_nombres_apellido]);
        return res.status(200).json({ message: "Se creó un Participante" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}

//funcion para crear un participantes_test
const crear_participantes_test = async (req, res, next) => {
    try {
        const { p_id_participante, p_id_test } = req.body;
        const result = await pool.query('call sp_crear_participantes_test($1,$2)', [p_id_participante, p_id_test]);
        return res.status(200).json({ message: "Se creó el participantes-test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
//funcion para buscar un participante por el token id 
const data_participante_token_id = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from data_participante_token_id($1)', [id]);
        console.log(result);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

module.exports = {
    crear_participantes,
    crear_participantes_test,
    data_participante_token_id
};