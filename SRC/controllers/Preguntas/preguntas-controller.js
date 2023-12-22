const pool = require('../../db');
const fs = require('fs');

//let ipFileServer = "../../uploads/areas/perfiles/";
const path = require('path');
//recibe el id de la seccion y devuelve todas las preguntas de un nivel skere modo diablo
const preguntas_nivel = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_preguntas_nivel($1)', [id]);
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
        console.log("../../../uploads/iconos/" + id + '.png');

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

module.exports = {
    preguntas_nivel,
    tipos_maestros_preguntas,
    plantillas_disponibles,
    icono_plantilla,
    crear_pregunta
};
