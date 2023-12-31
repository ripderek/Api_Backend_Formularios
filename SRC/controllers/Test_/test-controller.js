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

//funcion para devolver los datos de un formulario por el token enviando de la URL por parametro 
//
const datos_formulario_token = async (req, res, next) => {
    try {
        const { token } = req.params;
        const result = await pool.query('select * from form_data($1)', [token]);
        console.log(result.rows);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//crear una funcion para registrar al participante en el test 
//ingresar_participante_test
const ingreso_participante_test = async (req, res, next) => {
    try {
        const { p_token_id_participante, p_token_id_test, p_facultad, p_carrera, p_semestre } = req.body;
        console.log(p_token_id_participante + "-" + p_token_id_test + "-" + p_facultad + "-" + p_carrera + "-" + p_semestre);

        //dentro de la base de datos crear un cursor que ingrese todas las secciones que va a realizar un participante
        const result = await pool.query('call ingresar_participante_test($1,$2,$3,$4,$5)',
            [p_token_id_participante, p_token_id_test, p_facultad, p_carrera, p_semestre]);


        return res.status(200).json({ message: "Se ha registro en el test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
//verificar si el usuario ya se encuentra registrado en el test 
const verificacion_ingreso_participante = async (req, res, next) => {
    try {
        const { token_participante, token_test } = req.params;
        const result = await pool.query('select * from verificacion_participante_test($1,$2)', [token_participante, token_test]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para retornar todas las secciones que contiene un test
const secciones_test = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from secciones_test_id($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//funcion para una seccion con un test 
const agregar_seccion_test = async (req, res, next) => {
    try {
        const { p_id_test, p_id_seccion, p_numero_preguntas } = req.body;


        const result = await pool.query('call SP_Ingresar_seccion_test($1,$2,$3)',
            [p_id_test, p_id_seccion, p_numero_preguntas]);


        return res.status(200).json({ message: "Se ha agregado la seccion al test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
//funcion que devuelve el progreso 
const progreso_secciones_participante = async (req, res, next) => {
    try {
        const { p_id_toke_particiapnta, p_id_token_test } = req.params;
        // console.log("error aqui");
        // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
        //p_id_toke_particiapnta/:p_id_token_test
        const result = await pool.query('select * from FU_progreso_secciones_tokens($1,$2)', [p_id_toke_particiapnta, p_id_token_test]);
        return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//funcion que retorne los datos del test mediandte token id 
const datos_token_id_test = async (req, res, next) => {
    try {
        const { p_id_token_test } = req.params;
        // console.log("error aqui");
        // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
        //p_id_toke_particiapnta/:p_id_token_test
        const result = await pool.query('select * from FU_datos_test_token_id($1)', [p_id_token_test]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}

//funcion para obtener el progreso de una seccion para poder obtener el id de la pregunta siguiente
const progreso_seccion_siguiente_pregunta = async (req, res, next) => {
    try {
        const { p_id_user, p_id_token_test, id_seccion } = req.params;
        console.log("error aqui");
        console.log(p_id_user + "-" + p_id_token_test + "-" + id_seccion);
        //p_id_toke_particiapnta/:p_id_token_test
        const result = await pool.query('select * from fu_lista_preguntas_faltan_resolver($1,$2,$3)', [p_id_user, p_id_token_test, id_seccion]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//funcion para saber si hay mas preguntas por revolser 
const mas_preguntas = async (req, res, next) => {
    try {
        const { p_id_user, p_id_token_test, id_seccion } = req.params;
        // console.log("error aqui");
        // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
        //p_id_toke_particiapnta/:p_id_token_test
        const result = await pool.query('select * from fu_verificar_hay_mas_preguntas($1,$2,$3)', [p_id_user, p_id_token_test, id_seccion]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}

//funcion para registrar una respuesta unica 
const registrar_respuesta_unica = async (req, res, next) => {
    try {
        const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } = req.body;
        const result = await pool.query('call SP_REGISTRAR_RESPUESTA_UNICA($1,$2,$3)',
            [p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta]);
        return res.status(200).json({ message: "Se creó el test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
//Fucion para registrar respuestas multiples en forma de JSON 
const registrar_respuestas_multiples = async (req, res, next) => {
    //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
    try {
        const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } = req.body;
        const result = await pool.query('call SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON($1,$2,$3)',
            [p_id_progreso_pregunta, JSON.stringify(p_respuesta), p_tiempo_respuesta]);
        return res.status(200).json({ message: "Se registro la respuesta" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}

module.exports = {
    crear_test,
    test_usuario,
    errores_test,
    test_detalle_id,
    participantes_test,
    lista_participantes,
    lista_participantes_busqueda,
    datos_formulario_token,
    ingreso_participante_test,
    verificacion_ingreso_participante,
    secciones_test,
    agregar_seccion_test,
    progreso_secciones_participante,
    datos_token_id_test,
    progreso_seccion_siguiente_pregunta,
    registrar_respuesta_unica,
    mas_preguntas,
    registrar_respuestas_multiples
};
