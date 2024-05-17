const pool = require("../../db");
const PDFDocument = require("pdfkit");

//funcion que retorne los participantes de un test
const crear_reporte = async (req, res, next) => {
  try {
    const { codigoFormulario, codigoReporte, codigoTipo } = req.body;
    //console.log(codigoFormulario);

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

//funcion que retorne los participantes de un test
const reporte_progreso_preg = async (req, res, next) => {
  try {
    const { codigoFormulario, codigoReporte } = req.body;
    //console.log(codigoFormulario);

    //codigoFormulario codigo del test
    //codigoReporte si es participante, progreso , etc

    if (codigoReporte == "ListProgresoPreg") {
      const result = await pool.query(
        "select * from fu_reporte_progreso_preguntas_de_un_test2($1)",
        [codigoFormulario]
      );
      return res.status(200).json(result.rows);
    } else if (codigoReporte == "ListProgresoPart") {

    }
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};

module.exports = {
  crear_reporte,
  reporte_progreso_preg,
};
