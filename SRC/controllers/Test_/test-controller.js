const pool = require("../../db");

//funcion para crear un test
const crear_test = async (req, res, next) => {
  try {
    const {
      p_Titulo,
      p_Fecha_hora_cierre,
      p_Fecha_hora_inicio,
      p_ID_User_crea,
      p_Descripcion,
      p_Ingresos_Permitidos,
      p_cualquier_entrar,
      p_aleatoria,
    } = req.body;
    const result = await pool.query(
      "call sp_insertar_test($1,$2,$3,$4,$5,$6,$7,$8)",
      [
        p_Titulo,
        p_Fecha_hora_cierre,
        p_Fecha_hora_inicio,
        p_ID_User_crea,
        p_Descripcion,
        p_Ingresos_Permitidos,
        p_cualquier_entrar,
        p_aleatoria,
      ]
    );
    return res.status(200).json({ message: "Se creó el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};

//listar los test segun usuarios
const test_usuario = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from FU_test_usuario($1)", [id]);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//listar los ingresos de un usuario
const ingresos_usuario = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "select * from FU_Ingresos_participantes($1)",
      [id]
    );
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//para ver el progreso seccion de un usuario
const progreso_seccion_usuario = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "select * from FU_Progreso_seccion_usuario_monitoreo($1)",
      [id]
    );
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//para ver las preguntas que ha contestado el usuario
//progreso_seccion_usuario progreso_preguntas_usuario
const progreso_preguntas_usuario = async (req, res, next) => {
  try {
    const { id, id2 } = req.params;
    const result = await pool.query(
      "select * from FU_Progreso_usuario_monitoreo($1,$2)",
      [id, id2]
    );
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//listar los errores de un test mediante el id del test
const errores_test = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from FU_errores_test($1)", [id]);
    console.log(result);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion que retorna el detalle de un test
const test_detalle_id = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from fu_detalle_test_id($1)", [
      id,
    ]);
    console.log(result);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para retornar los participantes de un test mediante el id del test
const participantes_test = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "select * from Fu_participantes_test_id($1)",
      [id]
    );
    console.log(result);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para retornar todos los participantes creados
const lista_participantes = async (req, res, next) => {
  try {
    const result = await pool.query("select * from Fu_lista_participantes()");
    console.log(result);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para listar los participantes mediante palabra clave
const lista_participantes_busqueda = async (req, res, next) => {
  try {
    const { clave } = req.params;
    console.log("Aqui entra");
    console.log(clave);
    const result = await pool.query(
      "select * from Fu_lista_participantes_bucar($1)",
      [clave]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para devolver los datos de un formulario por el token enviando de la URL por parametro
//
const datos_formulario_token = async (req, res, next) => {
  try {
    const { token } = req.params;
    const result = await pool.query("select * from form_data($1)", [token]);
    console.log(result.rows);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//preguntas de un formulario
const preguntas_formulario = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from preguntas_de_un_test($1)", [
      id,
    ]);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//estadistica_por_pregunta
const grafica1 = async (req, res, next) => {
  try {
    console.log("Qui para buscar las preguntas");
    const { id, id2 } = req.params;
    const result = await pool.query(
      "select * from estadistica_por_pregunta($1,$2)",
      [id, id2]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};
//crear una funcion para registrar al participante en el test
//ingresar_participante_test
const ingreso_participante_test = async (req, res, next) => {
  try {
    const {
      p_token_id_participante,
      p_token_id_test,
      p_facultad,
      p_carrera,
      p_semestre,
    } = req.body;
    console.log(
      p_token_id_participante +
        "-" +
        p_token_id_test +
        "-" +
        p_facultad +
        "-" +
        p_carrera +
        "-" +
        p_semestre
    );

    //dentro de la base de datos crear un cursor que ingrese todas las secciones que va a realizar un participante
    const result = await pool.query(
      "call ingresar_participante_test($1,$2,$3,$4,$5)",
      [
        p_token_id_participante,
        p_token_id_test,
        p_facultad,
        p_carrera,
        p_semestre,
      ]
    );

    return res.status(200).json({ message: "Se ha registro en el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//verificar si el usuario ya se encuentra registrado en el test
const verificacion_ingreso_participante = async (req, res, next) => {
  try {
    const { token_participante, token_test } = req.params;
    const result = await pool.query(
      "select * from verificacion_participante_test($1,$2)",
      [token_participante, token_test]
    );
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para retornar todas las secciones que contiene un test
const secciones_test = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from secciones_test_id($1)", [
      id,
    ]);
    return res.status(200).json(result.rows);
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

//funcion para una seccion con un test
const agregar_seccion_test = async (req, res, next) => {
  try {
    //agregar el JSON como parametro que contiene el id del nivel y el numero de preguntas a registrar
    //el JSON es el p_numero_preguntas
    const { p_id_test, p_id_seccion, p_numero_preguntas } = req.body;

    const result = await pool.query("call SP_Ingresar_seccion_test($1,$2,$3)", [
      p_id_test,
      p_id_seccion,
      JSON.stringify(p_numero_preguntas),
    ]);

    return res
      .status(200)
      .json({ message: "Se ha agregado la seccion al test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para eidtarlas
const sp_actualizar_niveles_preguntas_seccion_test = async (req, res, next) => {
  try {
    //agregar el JSON como parametro que contiene el id del nivel y el numero de preguntas a registrar
    //el JSON es el p_numero_preguntas
    const { p_id_test, p_id_seccion, p_numero_preguntas } = req.body;

    const result = await pool.query(
      "call sp_actualizar_niveles_preguntas_seccion_test($1,$2,$3)",
      [p_id_test, p_id_seccion, JSON.stringify(p_numero_preguntas)]
    );

    return res
      .status(200)
      .json({ message: "Se ha actualizado el numero de preguntas del test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para eliminar un test mediante el id del test
const eliminar_test = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("call SP_Eliminar_Test($1)", [id]);
    return res.status(200).json({ message: "Se ha eliminado el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para expulsar o eliminar participante del test, esto conlleva eliminar todo su progreso
const eliminar_participante_test = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "call SP_Eliminar_o_expulsar_participante_test($1)",
      [id]
    );
    return res
      .status(200)
      .json({ message: "Se ha eliminado el participante del  test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};

//funcion que devuelve el progreso
const progreso_secciones_participante = async (req, res, next) => {
  try {
    const { p_id_toke_particiapnta, p_id_token_test } = req.params;
    // console.log("error aqui");
    // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query(
      "select * from FU_progreso_secciones_tokens($1,$2)",
      [p_id_toke_particiapnta, p_id_token_test]
    );
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion que retorne los datos del test mediandte token id
const datos_token_id_test = async (req, res, next) => {
  try {
    const { p_id_token_test } = req.params;
    // console.log("error aqui");
    // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query(
      "select * from FU_datos_test_token_id($1)",
      [p_id_token_test]
    );
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//FUNCION PARA GENERAR UN EXCEL CON TODAS LAS RESPUESTAS DE TODOS LOS PARTICIPANTES DE TODAS LAS SECCIONES DE UN TEST
const Excel = require("exceljs");

const Generate_Excel_TODOS = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query("select * from FU_Generate_Excel($1)", [
      id,
    ]);
    // Crear un nuevo libro de Excel
    const workbook = new Excel.Workbook();
    const worksheet = workbook.addWorksheet("Datos");
    // Agregar encabezados de columnas
    // const columnas = Object.keys(result.rows[0]);
    // Agregar filas de datos
    result.rows.forEach((row) => {
      worksheet.addRow(Object.values(row));
    });

    // Guardar el archivo Excel
    // await workbook.xlsx.writeFile('datos.xlsx');
    //worksheet.addRow(columnas);
    const buffer = await workbook.xlsx.writeBuffer();

    // Enviar el archivo Excel como respuesta
    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );
    res.setHeader("Content-Disposition", "attachment; filename=datos.xlsx");
    res.send(buffer);
    //res.contentType("application/pdf");
    //res.send(data);
    //return res.status(200).json({ message: "Excel Generado skere modo diablo" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion para saber si un test es o no editable skere modo diablo
const test_editable = async (req, res, next) => {
  try {
    const { id } = req.params;
    // console.log("error aqui");
    // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query("select * from FU_IS_EDITABLE_TEST($1)", [
      id,
    ]);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};

//funcion para obtener el progreso de una seccion para poder obtener el id de la pregunta siguiente
const progreso_seccion_siguiente_pregunta = async (req, res, next) => {
  try {
    const { p_id_user, p_id_token_test, id_seccion } = req.params;
    console.log("error aqui");
    console.log(p_id_user + "-" + p_id_token_test + "-" + id_seccion);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query(
      "select * from fu_lista_preguntas_faltan_resolver($1,$2,$3)",
      [p_id_user, p_id_token_test, id_seccion]
    );
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion para saber si hay mas preguntas por revolser
const mas_preguntas = async (req, res, next) => {
  try {
    const { p_id_user, p_id_token_test, id_seccion } = req.params;
    // console.log("error aqui");
    // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query(
      "select * from fu_verificar_hay_mas_preguntas($1,$2,$3)",
      [p_id_user, p_id_token_test, id_seccion]
    );
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};

//funcion para registrar una respuesta unica
const registrar_respuesta_unica = async (req, res, next) => {
  try {
    const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } =
      req.body;

    // Verificar si p_respuesta está vacía
    if (!p_respuesta.trim()) {
      // Si la respuesta está vacía, enviar una respuesta 404 con un mensaje
      return res.status(404).json({ message: "No se permite respuesta vacía" });
    }

    const result = await pool.query(
      "call SP_REGISTRAR_RESPUESTA_UNICA($1,$2,$3)",
      [p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta]
    );
    return res.status(200).json({ message: "Se creó el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//Fucion para registrar respuestas multiples en forma de JSON
const registrar_respuestas_multiples = async (req, res, next) => {
  //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
  try {
    const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } =
      req.body;
    const result = await pool.query(
      "call SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON($1,$2,$3)",
      [p_id_progreso_pregunta, JSON.stringify(p_respuesta), p_tiempo_respuesta]
    );
    return res.status(200).json({ message: "Se registro la respuesta" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//Funcion para registrar las repuestas de tipo Clave Valor 1
const registrar_respuestas_CLAVE_VALOR1 = async (req, res, next) => {
  //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
  try {
    const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } =
      req.body;
    const result = await pool.query(
      "call sp_registrar_respuesta_multiple_json_CLAVE_VALOR1($1,$2,$3)",
      [p_id_progreso_pregunta, JSON.stringify(p_respuesta), p_tiempo_respuesta]
    );
    return res.status(200).json({ message: "Se registro la respuesta" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//registrar_ingreso
const registrar_ingreso = async (req, res, next) => {
  //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
  try {
    const { user_id_token, test_id_token, user_age } = req.body;
    const ip = req.ip;

    const result = await pool.query("call registrar_ingreso($1,$2,$3,$4)", [
      user_id_token,
      test_id_token,
      ip,
      user_age,
    ]);
    return res.status(200).json({ message: "Se registro la respuesta" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//FUNCION PARA registrar las respuestas de tipo clave valor 2
const registrar_respuestas_CLAVE_VALOR2 = async (req, res, next) => {
  //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
  try {
    const { p_id_progreso_pregunta, p_respuesta, p_tiempo_respuesta } =
      req.body;
    const result = await pool.query(
      "call sp_registrar_respuesta_multiple_json_CLAVE_VALOR2($1,$2,$3)",
      [p_id_progreso_pregunta, JSON.stringify(p_respuesta), p_tiempo_respuesta]
    );
    return res.status(200).json({ message: "Se registro la respuesta" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para retornar el progreso completo de los participantes en forma de lista, es decir, el general y los especificos de cada seccion
const Lista_Progreso_Participantes = async (req, res, next) => {
  try {
    const { p_id_test } = req.params;
    // console.log("error aqui");
    // console.log(p_id_toke_particiapnta + "-" + p_id_token_test);
    //p_id_toke_particiapnta/:p_id_token_test
    const result = await pool.query(
      "select * from obtener_progreso_participantes($1)",
      [p_id_test]
    );
    console.log(result.rows[0].obtener_progreso_participantes);
    return res.status(200).json(result.rows[0].obtener_progreso_participantes);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//procedimiento almacenado para editar un test sin cambiar las fechas xq eso se hace en otra funcion XD
const editar_test_no_fechas = async (req, res, next) => {
  //SP_REGISTRAR_RESPUESTA_MULTIPLE_JSON
  try {
    const {
      Titulo,
      ID_test,
      Descripcion,
      Ingresos,
      Acceso,
      GeneracionPreguntas,
    } = req.body;
    const result = await pool.query("call sp_editar_test($1,$2,$3,$4,$5,$6)", [
      Titulo,
      ID_test,
      Descripcion,
      Ingresos,
      Acceso,
      GeneracionPreguntas,
    ]);
    console.log("Ver los estados  ");
    console.log(req.body);
    return res.status(200).json({ message: "Se edito el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(req.body);
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para editar la fecha de inicio o de fin de un test skere modo diablo
const editar_fechas_test = async (req, res, next) => {
  try {
    const { p_fecha_hora_update, p_id_test, cual_fecha_editar } = req.body;
    const result = await pool.query(
      "call sp_cambiar_fecha_hora_test($1,$2,$3)",
      [p_fecha_hora_update, p_id_test, cual_fecha_editar]
    );
    console.log("A editar:");
    console.log({ p_fecha_hora_update, p_id_test, cual_fecha_editar });
    return res.status(200).json({ message: "Se edito las fechas del el test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion para eliminar una secion de un test
const eliminar_seccion_test = async (req, res, next) => {
  try {
    const { p_id_test, p_id_seccion } = req.body;
    const result = await pool.query("call SP_Eliminar_seccion_test($1,$2)", [
      p_id_test,
      p_id_seccion,
    ]);

    return res.status(200).json({ message: "Se elimino la seccion del test" });
    //return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  }
};
//funcion que devuelve la lista actual del numero de preguntas por nivel de una seccion-test
const fu_listar_niveles_num_preguntas = async (req, res, next) => {
  try {
    const { p_id_seccion, p_id_test } = req.params;
    // console.log("error aqui");
    console.log(req.params);
    const result = await pool.query(
      "select * from fu_listar_niveles_num_preguntas($1,$2)",
      [p_id_seccion, p_id_test]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion que devuelva en un JSON las posibilidades de reportes de un test, por ejemplo si tiene participantes, si tiene secciones si se esta resolviendo, etc
const fu_posibilidades_reportes_formulario = async (req, res, next) => {
  try {
    const { p_token_test } = req.params;
    // console.log("error aqui");
    console.log(req.params);
    const result = await pool.query(
      "select * from fu_posibilidades_reportes_formulario($1)",
      [p_token_test]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//funcion para listar los saltos de una seccion de un test
const fu_listar_saltos_seccion = async (req, res, next) => {
  try {
    const { id_test, id_seccion } = req.params;
    // console.log("error aqui");
    console.log(req.params);
    const result = await pool.query(
      "select * from fu_listar_saltos_seccion($1,$2)",
      [id_test, id_seccion]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
const fu_ver_detalle_salto = async (req, res, next) => {
  try {
    const { p_id_test, p_id_nivel, p_id_seccion } = req.params;
    // console.log("error aqui");
    console.log(req.params);
    const result = await pool.query(
      "select * from fu_ver_detalle_salto($1,$2,$3)",
      [p_id_test, p_id_nivel, p_id_seccion]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
//fu_listar_niveles_saltos_seleccion
const fu_listar_niveles_saltos_seleccion = async (req, res, next) => {
  try {
    const { p_id_test } = req.params;
    // console.log("error aqui");
    console.log(req.params);
    const result = await pool.query(
      "select * from fu_listar_niveles_saltos_seleccion($1)",
      [p_id_test]
    );
    console.log(result.rows);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ message: error.message });
  }
};
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
  registrar_respuestas_multiples,
  registrar_respuestas_CLAVE_VALOR1,
  registrar_respuestas_CLAVE_VALOR2,
  preguntas_formulario,
  grafica1,
  eliminar_test,
  registrar_ingreso,
  ingresos_usuario,
  progreso_seccion_usuario,
  progreso_preguntas_usuario,
  eliminar_participante_test,
  test_editable,
  Generate_Excel_TODOS,
  Lista_Progreso_Participantes,
  editar_test_no_fechas,
  editar_fechas_test,
  eliminar_seccion_test,
  fu_listar_niveles_num_preguntas,
  sp_actualizar_niveles_preguntas_seccion_test,
  fu_posibilidades_reportes_formulario,
  fu_listar_saltos_seccion,
  fu_ver_detalle_salto,
  fu_listar_niveles_saltos_seleccion,
};
