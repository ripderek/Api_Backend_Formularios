const pool = require('../../db');
const fs = require('fs');

//let ipFileServer = "../../uploads/areas/perfiles/";
const path = require('path');
//recibe el id de la seccion y devuelve todas las preguntas de un nivel skere modo diablo
const preguntas_nivel = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_preguntas_nivel1($1)', [id]);
        console.log(result.rows);

        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//develve todos los tipos de preguntas maestras 
//FU_tipos_preguntas_maestras
const tipos_maestros_preguntas = async (req, res, next) => {
    try {
        const result = await pool.query('select * from FU_tipos_preguntas_maestras()');
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//devuelve las plantillas disponibles para crear una pregunta
const plantillas_disponibles = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_plantilla_preguntas_id_maestro($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}

//devuelve el icono de la plantilla 
const icono_plantilla = async (req, res, next) => {
    try {

        const { id } = req.params;
        /// const users = await pool.query('select * from area_logo($1)', [id]);
        //   '../../uploads/iconos/memorizar.png';'
        let ext = path.extname("7.jpg");

        let fd = fs.createReadStream(path.join(__dirname, "../../../uploads/iconos/" + id + '.png'));
        res.setHeader("Content-Type", "image/" + ext.substr(1));
        fd.pipe(res);
    } catch (error) {
        return res.status(404).json({ message: "No se encuentra la imagen " });
    }
}
//directorio de los perfiles 
let ipFileServer = "../../uploads/preguntas/";
//funcion para crear una pregunta y enviar la URL de la imagen a la base de datos 
const crear_pregunta = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        const { p_tiempo_img } = req.body;

        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });


        if (p_tiempo_img <= 0)
            return res.status(404).json({ message: "El tiempo en para memorizar la imagen no puede ser menor o igual a 0 segundos" });
        const users = await pool.query('Call SP_Crear_Pregunta_MEMRZAR($1,$2,$3,$4,$5,$6)', [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_tiempo_img]);
        console.log(users);
        //Llamar a la funcion que enviar el correo
        //enviarMail(nombres, identificacion, correo2);
        return res.status(200).json({ message: "Se creo la pregunta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//nueva funcion para crear las preguntas con el numero de columanas para ver xd skere modo diablo
const crear_pregunta_columnas = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        const { p_tiempo_img } = req.body;
        const { p_columnas } = req.body;

        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });


        if (p_tiempo_img <= 0)
            return res.status(404).json({ message: "El tiempo en para memorizar la imagen no puede ser menor o igual a 0 segundos" });
        const users = await pool.query('Call sp_crear_pregunta_columnas($1,$2,$3,$4,$5,$6,$7)', [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_tiempo_img, p_columnas]);
        console.log(users);
        //Llamar a la funcion que enviar el correo
        //enviarMail(nombres, identificacion, correo2);
        return res.status(200).json({ message: "Se creo la pregunta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//funcion para crear la pregunta de tipo ingresar numero mediante input 
const crear_pregunta_input_num = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        //esta es la respuesta
        const { p_tiempo_img } = req.body;

        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });


        if (!p_tiempo_img || isNaN(parseInt(p_tiempo_img)))
            return res.status(404).json({ message: "La repuesta numerica no puede estar vacia" });

        const users = await pool.query('Call sp_crear_pregunta_INGRNUM($1,$2,$3,$4,$5,$6)', [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_tiempo_img]);
        console.log(users);

        //Llamar a la funcion que enviar el correo
        //enviarMail(nombres, identificacion, correo2);

        return res.status(200).json({ message: "Se creo la pregunta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}


//funcion para crear una pregunta de tipo SELCIMG
const crear_pregunta_SELCIMG = async (req, res, next) => {
    try {
        //crear el user en la BD
        const { p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel } = req.body;


        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });


        const users = await pool.query('Call SP_Crear_Pregunta_SELCIMG($1,$2,$3,$4)', [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel]);
        console.log(users);

        //Llamar a la funcion que enviar el correo
        //enviarMail(nombres, identificacion, correo2);

        return res.status(200).json({ message: "Se creo la pregunta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}



//funcion para crear respuesta de MEMRZAR 
let ipFileServerRES = "../../uploads/respuestas/";

const crear_respuesta_MEMRZAR = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServerRES}${file?.filename}`;
        //crear el user en la BD
        const { id_pregunta } = req.body;
        const { p_correcta } = req.body;

        const users = await pool.query('Call SP_anadir_respuesta_MEMRZAR($1,$2,$3)', [id_pregunta, foto, p_correcta]);

        return res.status(200).json({ message: "Se creo la respuesta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
const crear_respuesta_text = async (req, res, next) => {
    try {

        //file de la foto
        const { respuesta, id_pregunta, p_correcta } = req.body;

        const users = await pool.query('Call SP_anadir_respuesta_MEMRZAR($1,$2,$3)', [id_pregunta, respuesta, p_correcta]);

        return res.status(200).json({ message: "Se creo la respuesta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//funcion que devuelve los datos de una pregunta de tipo MEMRZAR
const MEMRZAR_dato_pregunta = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_datos_pregunta_MEMRZAR($1)', [id]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//funcion que devuelve los datos de una pregunta de tipo MEMRZAR segun el id de la pregunta
const MEMRZAR_dato_pregunta_id_pregunta = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_datos_pregunta_MEMRZAR_id_pregunta($1)', [id]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//funcion que devuelve los datos de una pregunta de tipo SELCIMG
const SELCIMG_dato_pregunta = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from fu_datos_pregunta_selcimg($1)', [id]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//funcion que devuelve los datos de una pregunta de tipo MEMRZAR segun el id de la pregunta
const SELCIMG_dato_pregunta_id_pregunta = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from fu_datos_pregunta_selcimg_id_pregunta($1)', [id]);
        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//ver imagen de una pregunta  ../../uploads/preguntas cf2d46d58ba5259da38c8b218703f57a86665e6dcf8759dce10261b6e81dc0b8-1703216694648.png
//
const ver_imagen_pregunta = async (req, res, next) => {
    try {
        const { id } = req.params;
        const users = await pool.query('select * from FU_imagen_pregunta($1)', [id]);
        let ext = path.extname("7.jpg");
        let fd = fs.createReadStream(path.join(__dirname, "../" + users.rows[0].r_url_img));
        res.setHeader("Content-Type", "image/" + ext.substr(1));
        fd.pipe(res);
    } catch (error) {
        return res.status(404).json({ message: "No se encuentra la imagen " });
    }
}

//funcion para ver las opciones de respuesta de una pregunta de tipo MEMRZAR
const opciones_respuestas_MEMRZAR = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from FU_repuestas_MEMRZAR($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
// FUNCION PARA VER LAS REPUESTAS DE UNA PREGUNTA CON UNA SOLA CLAVE VALOR
const opciones_respuestas_1_CLAVE_VALOR = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from fu_repuestas_con_valores1($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//fu_repuestas_con_valores2
const opciones_respuestas_2_CLAVE_VALOR = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from fu_repuestas_con_valores2($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//funcion para ver la respuesta de tipo img en MEMRZAR
const ver_img_respuesta_MEMRZAR = async (req, res, next) => {
    try {
        const { id } = req.params;
        const users = await pool.query('select * from FU_ver_img_respuesta_MEMRZAR($1)', [id]);
        let ext = path.extname("7.jpg");
        let fd = fs.createReadStream(path.join(__dirname, "../" + users.rows[0].r_url_img));
        res.setHeader("Content-Type", "image/" + ext.substr(1));
        fd.pipe(res);
    } catch (error) {
        return res.status(404).json({ message: "No se encuentra la imagen " });
    }
}

//Funcion para crear pregunta con Claves Multiples 
const SP_crear_pregunta_clave_valor_OPCLAVA = async (req, res, next) => {
    //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
    try {
        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        const { p_claves_valor } = req.body;
        console.log(foto);
        console.log(p_enunciado);
        console.log(p_claves_valor);
        console.log(JSON.stringify(p_claves_valor));
        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });

        const users = await pool.query('Call SP_crear_pregunta_clave_valor_OPCLAVA($1,$2,$3,$4,$5,$6)',
            [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_claves_valor]);
        console.log(users);




        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
//CREAR PREGUNTA DE TIPO CLAVE VALOR PERO DE TIPO 1 ES DECIR CON UN SOLO CAMPO
//SP_crear_pregunta_clave_valor_OPCLAVA_no_JSON
const SP_crear_pregunta_clave_valor_OPCLAVA_no_json = async (req, res, next) => {
    //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
    try {
        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        const { p_clave } = req.body;
        const { p_tiempo_enunciado } = req.body;

        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });

        const users = await pool.query('Call SP_crear_pregunta_clave_valor_OPCLAVA_no_JSON($1,$2,$3,$4,$5,$6,$7)',
            [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_clave, p_tiempo_enunciado]);
        // console.log(users);
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}
const SP_crear_pregunta_clave_valor_OPCLAV2_no_json = async (req, res, next) => {
    //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
    try {
        //file de la foto
        const { file } = req
        const foto = `${ipFileServer}${file?.filename}`;
        //crear el user en la BD
        const { p_enunciado } = req.body;
        const { p_tiempos_segundos } = req.body;
        const { p_tipo_pregunta } = req.body;
        const { p_id_nivel } = req.body;
        const { p_clave } = req.body;
        //p_clave2
        const { p_clave2 } = req.body;
        const { p_tiempo_enunciado } = req.body;

        if (p_tiempos_segundos <= 0)
            return res.status(404).json({ message: "El tiempo en de respuesta no puede ser menor o igual a 0 segundos" });

        const users = await pool.query('Call SP_crear_pregunta_clave_valor_OPCLAV2_no_JSON($1,$2,$3,$4,$5,$6,$7,$8)',
            [p_enunciado, p_tiempos_segundos, p_tipo_pregunta, p_id_nivel, foto, p_clave, p_clave2, p_tiempo_enunciado]);
        // console.log(users);
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}


//funcion que retorner las claves de una pregunta 
const Claves_Preguntas = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await pool.query('select * from claves_preguntas_id($1)', [id]);
        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//Crear Repuesta Con una clave Valor 
//SP_anadir_respuesta_una_CLAVE_VALOR
const crear_respuesta_CLAVE_VALOR = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServerRES}${file?.filename}`;
        //crear el user en la BD
        const { id_pregunta } = req.body;
        const { r_id_clave } = req.body;
        const { r_valor } = req.body;

        const users = await pool.query('Call SP_anadir_respuesta_una_CLAVE_VALOR($1,$2,$3,$4)', [id_pregunta, foto, r_id_clave, r_valor]);

        return res.status(200).json({ message: "Se creo la respuesta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
//SP_anadir_respuesta_dos_CLAVE_VALOR
const crear_respuesta_CLAVE_VALOR_2 = async (req, res, next) => {
    try {

        //file de la foto
        const { file } = req
        const foto = `${ipFileServerRES}${file?.filename}`;
        //crear el user en la BD
        const { id_pregunta } = req.body;
        const { r_id_clave } = req.body;
        const { r_valor } = req.body;
        const { r_id_clave1 } = req.body;
        const { r_valor1 } = req.body;

        const users = await pool.query('Call SP_anadir_respuesta_dos_CLAVE_VALOR($1,$2,$3,$4,$5,$6)', [id_pregunta, foto, r_id_clave, r_valor, r_id_clave1, r_valor1]);

        return res.status(200).json({ message: "Se creo la respuesta" });
    } catch (error) {
        console.log(error);
        return res.status(404).json({ message: error.message });
    }
}
module.exports = {
    preguntas_nivel,
    tipos_maestros_preguntas,
    plantillas_disponibles,
    icono_plantilla,
    crear_pregunta,
    MEMRZAR_dato_pregunta,
    ver_imagen_pregunta,
    MEMRZAR_dato_pregunta_id_pregunta,
    opciones_respuestas_MEMRZAR,
    ver_img_respuesta_MEMRZAR,
    crear_respuesta_MEMRZAR,
    crear_pregunta_SELCIMG,
    SELCIMG_dato_pregunta,
    SELCIMG_dato_pregunta_id_pregunta,
    crear_respuesta_text,
    crear_pregunta_input_num,
    SP_crear_pregunta_clave_valor_OPCLAVA,
    Claves_Preguntas,
    SP_crear_pregunta_clave_valor_OPCLAVA_no_json,
    crear_respuesta_CLAVE_VALOR,
    opciones_respuestas_1_CLAVE_VALOR,
    SP_crear_pregunta_clave_valor_OPCLAV2_no_json,
    crear_respuesta_CLAVE_VALOR_2,
    opciones_respuestas_2_CLAVE_VALOR,
    crear_pregunta_columnas
};
