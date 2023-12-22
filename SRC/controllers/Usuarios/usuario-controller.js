const pool = require('../../db');


const datos_Usuarios = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await pool.query('select * from FU_usuario_data($1)', [id]);
        console.log(id);
        console.log(result.rows[0]);

        return res.status(200).json(result.rows[0]);
    } catch (error) {
        return res.status(404).json({ message: error.message });
    }
}


module.exports = {
    datos_Usuarios
};
