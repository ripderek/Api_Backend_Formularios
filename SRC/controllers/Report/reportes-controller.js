const pool = require("../../db");
const PDFDocument = require("pdfkit");

//funcion que retorne los participantes de un test
const crear_reporte = async (req, res, next) => {
  try {
    const { codigoFormulario, codigoReporte, codigoTipo } = req.body;
    console.log(codigoFormulario);

    //codigoFormulario codigo del test
    //codigoReporte si es participante, progreso , etc
    //codigoTipo si es pdf o exel

    if (codigoReporte == "ListParticipantes") {
      const result = await pool.query(
        "select * from fu_report_lista_participantes_test($1)",
        [codigoFormulario]
      );
      return res.status(200).json(result.rows);

    } else if (codigoReporte == "ListParticipantes2") {

    }

  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};

module.exports = {
  crear_reporte,
};
