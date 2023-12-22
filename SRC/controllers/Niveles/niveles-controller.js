const pool = require('../../db');

//recibe el id de la seccion y devuelve todos los niveles disponibles de esa seccion Skere modo diablo
const niveles_seccion = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_Niveles_Preguntas($1)', [id]);
        console.log(result.rows);

        return res.status(200).json(result.rows);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}
//funcion para crear un nivel en una seccion solo recibe el id de la seccion 
const crear_nivel = async (req, res, next) => {
    try {
        //const { id } = req.params;
        const { id_seccion } = req.params;
        console.log("CREAR SECCION");
        const result = await pool.query('call sp_insertar_niveles($1)', [id_seccion]);
        return res.status(200).json({ message: "Se creó el nivel" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}

module.exports = {
    niveles_seccion,
    crear_nivel
};
