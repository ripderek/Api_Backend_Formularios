const pool = require('../../db');

//funcion para crear un test
const crear_test = async (req, res, next) => {
    try {
        const { p_Titulo, p_Fecha_hora_cierre, p_Fecha_hora_inicio, p_ID_User_crea, p_Descripcion, p_Ingresos_Permitidos } = req.body;
        const result = await pool.query('call sp_insertar_test($1,$2,$3,$4,$5,$6)',
            [p_Titulo, p_Fecha_hora_cierre, p_Fecha_hora_inicio, p_ID_User_crea, p_Descripcion, p_Ingresos_Permitidos]);
        return res.status(200).json({ message: "Se creó el test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}

//listar los test segun usuarios 
const test_usuario = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_test_usuario($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//listar los errores de un test mediante el id del test
const errores_test = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_errores_test($1)', [id]);
        console.log(result);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion que retorna el detalle de un test 
const test_detalle_id = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from fu_detalle_test_id($1)', [id]);
        console.log(result);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para retornar los participantes de un test mediante el id del test
const participantes_test = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from Fu_participantes_test_id($1)', [id]);
        console.log(result);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para retornar todos los participantes creados 
const lista_participantes = async (req, res, next) => {
    try {
        const result = await pool.query('select * from Fu_lista_participantes()');
        console.log(result);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para listar los participantes mediante palabra clave 
const lista_participantes_busqueda = async (req, res, next) => {
    try {
        const { clave } = req.params;
        console.log("Aqui entra");
        console.log(clave);
        const result = await pool.query('select * from Fu_lista_participantes_bucar($1)', [clave]);
        console.log(result.rows);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}


module.exports = {
    crear_test,
    test_usuario,
    errores_test,
    test_detalle_id,
    participantes_test,
    lista_participantes,
    lista_participantes_busqueda
};
