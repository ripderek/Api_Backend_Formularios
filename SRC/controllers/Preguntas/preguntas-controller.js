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
    crear_respuesta_MEMRZAR
};
