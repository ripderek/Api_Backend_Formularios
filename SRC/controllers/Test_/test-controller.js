const pool = require('../../db');

//funcion para crear un test
const crear_test = async (req, res, next) => {
    try {
        const { p_Titulo, p_Fecha_hora_cierre, p_Fecha_hora_inicio, p_ID_User_crea ,p_Descripcion, p_Ingresos_Permitidos} = req.body;
        const result = await pool.query('call sp_insertar_test($1,$2,$3,$4,$5,$6)',
         [p_Titulo, p_Fecha_hora_cierre, p_Fecha_hora_inicio,p_ID_User_crea,p_Descripcion,p_Ingresos_Permitidos]);
        return res.status(200).json({ message: "Se creó el test" });
        //return res.status(200).json(result.rows);
    } catch (error) {
        console.log(error);
        return res.status(404).json({ error: error.message });
    }
}


module.exports = {
    crear_test
};
