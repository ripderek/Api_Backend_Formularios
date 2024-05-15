const pool = require("../../db");

const { PDFDocument, rgb } = require("pdf-lib");

// Función para crear el reporte en formato PDF
const crearReportePDF = async (codigoFormulario) => {
  try {
    const result = await pool.query(
      "select * from fu_report_lista_participantes_test($1)",
      [codigoFormulario]
    );
    const ListaParticipantes = result.rows;
    let contador = 1;
    const participantes = ListaParticipantes.map((participante) => [
      contador++,
      participante.r_nombres_apellidos,
      participante.r_correo_institucional,
      participante.r_supero_limite ? "Si" : "No",
      participante.r_fecha_add,
    ]);

    // Crear un nuevo documento PDF
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage();

    // Definir el contenido del PDF
    const fontSize = 12;
    const pageWidth = page.getWidth();
    const pageHeight = page.getHeight();
    const textOptions = { size: fontSize, color: rgb(0, 0, 0) }; // Cambia el color según tus preferencias

    let y = pageHeight - 40;
    let text = "Lista de Participantes del Test";
    page.drawText(text, { x: 50, y, ...textOptions });
    y -= fontSize * 2;

    // Agregar tabla de participantes
    const table = participantes;
    const tableHeight = table.length * fontSize;
    const tableWidth = pageWidth - 100;
    const cellMargin = 5;

    for (let i = 0; i < table.length; ++i) {
      const row = table[i];
      let x = 50;
      for (let j = 0; j < row.length; ++j) {
        const cell = row[j];
        const cellText = typeof cell === "string" ? cell : cell.toString();
        page.drawText(cellText, { x, y, ...textOptions });
        x += tableWidth / row.length;
      }
      y -= fontSize + cellMargin;
    }

    // Convertir el PDF a un buffer
    const pdfBytes = await pdfDoc.save();
    const pdfArray = Array.from(pdfBytes);

    return pdfArray;
  } catch (error) {
    console.error(error);
    throw new Error("Error al crear el reporte en PDF");
  }
};

// Controlador para manejar la solicitud de creación de reporte
const crear_reporte = async (req, res, next) => {
  try {
    const { codigoFormulario, codigoReporte, codigoTipo } = req.body;

    // Verificar el tipo de reporte
    if (codigoReporte === "ListParticipantes") {
      // Crear el reporte en formato PDF
      const pdfBuffer = await crearReportePDF(codigoFormulario);

      // Configurar los encabezados de la respuesta
      res.setHeader("Content-Type", "application/pdf");
      res.setHeader(
        "Content-Disposition",
        'attachment; filename="Reporte_Participantes.pdf"'
      );

      // Enviar el PDF como respuesta al cliente
      console.log(pdfBuffer);
      res.status(200).send(pdfBuffer);
    } else if (codigoReporte === "ListParticipantes2") {
      // Código para otro tipo de reporte si es necesario
    } else {
      // Código para manejar otros tipos de reporte
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al generar el reporte" });
  }
};

module.exports = {
  crear_reporte,
};
