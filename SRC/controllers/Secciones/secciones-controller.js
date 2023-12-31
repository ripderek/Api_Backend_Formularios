const pool = require('../../db');

//recibe el id del usuario y devuelve todas las secciones que participa
const secciones_usuario = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_Secciones_usuario($1)', [id]);
        console.log(id);
        console.log(result.rows);

        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para crear seccion mediante un usuario
const crear_seccion_usuario = async (req, res, next) => {
    try {
        //const { id } = req.params;
        const { p_titulo, p_descripcion, p_id_usuario_crea } = req.body;
        const result = await pool.query('call SP_Crear_Seccion($1,$2,$3)', [p_titulo, p_descripcion, p_id_usuario_crea]);
        return res.status(200).json({ message: "Se creó la sección" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}

//listar las secciones disponibles para ser seleccionadas a un test 
const secciones_disponibles_test = async (req, res, next) => {
    try {
        const result = await pool.query('select * from fu_secciones_disponibles_test()');
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//listar el numero de preguntas por niveles que posee una seccion 
const preguntas_niveles_seccion_id = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_numeros_preguntas_validad_seccion($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}


module.exports = {
    secciones_usuario,
    crear_seccion_usuario,
    secciones_disponibles_test,
    preguntas_niveles_seccion_id
};
