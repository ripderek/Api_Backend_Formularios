const { Router } = require('express');
const router = Router();
const { preguntas_nivel, tipos_maestros_preguntas, plantillas_disponibles, icono_plantilla, crear_pregunta, MEMRZAR_dato_pregunta, ver_imagen_pregunta, MEMRZAR_dato_pregunta_id_pregunta, opciones_respuestas_MEMRZAR, ver_img_respuesta_MEMRZAR, crear_respuesta_MEMRZAR, crear_pregunta_SELCIMG, SELCIMG_dato_pregunta, SELCIMG_dato_pregunta_id_pregunta, crear_respuesta_text, crear_pregunta_input_num, SP_crear_pregunta_clave_valor_OPCLAVA, Claves_Preguntas, SP_crear_pregunta_clave_valor_OPCLAVA_no_json, crear_respuesta_CLAVE_VALOR, opciones_respuestas_1_CLAVE_VALOR, SP_crear_pregunta_clave_valor_OPCLAV2_no_json, crear_respuesta_CLAVE_VALOR_2, opciones_respuestas_2_CLAVE_VALOR, crear_pregunta_columnas, eliminar_pregunta, eliminar_respuesta, SP_Editar_pregunta_SELCCMA, respuesta_data_id, SP_Editar_respuesta_SELCCMA
,Editar_parametros_pregunta,ActualizarImagenPregunta,ActualizarImagenRespuesta,Editar_estadp_correcto_incorrecto_respuesta,sp_editar_respuesta_selccla } = require('../controllers/Preguntas/preguntas-controller');
const { upload } = require('../middleware/multer-preguntas');
const { uploadRes } = require('../middleware/multer-respuestas');

//router.post('/Login', verificaUser);
//simon
router.get('/Preguntas_nivel/:id', preguntas_nivel);
router.get('/Tipos_preguntas_maestras', tipos_maestros_preguntas);
router.get('/Ver_ImagenPregunta/:id', ver_imagen_pregunta);
router.get('/Plantillas/:id', plantillas_disponibles);
router.get('/Icono/:id', icono_plantilla);
router.get('/RespuestasMEMRZAR/:id', opciones_respuestas_MEMRZAR);
router.get('/Ver_ImagenRespuestaMEMRZAR/:id', ver_img_respuesta_MEMRZAR);
router.post('/CrearPreguntaSELCIMG', crear_pregunta_SELCIMG);

//ruta para crear una pregunta y guardar la imagen 
router.post('/Crear_pregunta', upload.single('file'), crear_pregunta);
//crear_pregunta_columnas
router.post('/Crear_pregunta_Columnas', upload.single('file'), crear_pregunta_columnas);

router.post('/Crear_respuestaMEMRZAR', uploadRes.single('file'), crear_respuesta_MEMRZAR);
router.post('/Crea_respuesta_text', crear_respuesta_text);
router.get('/MEMRZAR_Datos_pregunta/:id', MEMRZAR_dato_pregunta);
router.get('/MEMRZAR_Datos_pregunta_id_pregunta/:id', MEMRZAR_dato_pregunta_id_pregunta);
router.get('/SELCIMG_Datos_pregunta/:id', SELCIMG_dato_pregunta);
router.get('/SELCIMG_Datos_pregunta_id_pregunta/:id', SELCIMG_dato_pregunta_id_pregunta);
router.post('/Crear_pregunta_input_num', upload.single('file'), crear_pregunta_input_num)
router.post('/Crear_pregunta_clave_valor', upload.single('file'), SP_crear_pregunta_clave_valor_OPCLAVA)
router.get('/Obtener_Claves/:id', Claves_Preguntas);
router.post('/Crear_pregunta_clave_valor_noJSON', upload.single('file'), SP_crear_pregunta_clave_valor_OPCLAVA_no_json)
//SP_crear_pregunta_clave_valor_OPCLAV2_no_json
router.post('/Crear_pregunta_clave_valor_noJSON2', upload.single('file'), SP_crear_pregunta_clave_valor_OPCLAV2_no_json)

router.post('/Crear_respuesta1ClaveValor', uploadRes.single('file'), crear_respuesta_CLAVE_VALOR);
//crear_respuesta_CLAVE_VALOR_2
router.post('/Crear_respuesta1ClaveValor2', uploadRes.single('file'), crear_respuesta_CLAVE_VALOR_2);

//opciones_respuestas_1_CLAVE_VALOR
router.get('/Respuestas1CALVEVALOR/:id', opciones_respuestas_1_CLAVE_VALOR);
//opciones_respuestas_2_CLAVE_VALOR
router.get('/Respuestas2CALVEVALOR/:id', opciones_respuestas_2_CLAVE_VALOR);
router.post('/EliminarPregunta/:id', eliminar_pregunta);
//eliminar_respuesta
router.post('/EliminarRespuesta/:id', eliminar_respuesta);
//SP_Editar_pregunta_SELCCMA
router.post('/EditaerPreguntaSELCCMA', SP_Editar_pregunta_SELCCMA);

//Editar_parametros_pregunta
router.post('/Editar_parametros_pregunta', Editar_parametros_pregunta);

//respuesta_data_id
router.get('/DataRespuestaID/:id', respuesta_data_id);
//SP_Editar_respuesta_SELCCMA
router.post('/EditaerRespuestaSELCCMA', SP_Editar_respuesta_SELCCMA);
//sp_editar_respuesta_selccla
router.post('/sp_editar_respuesta_selccla', sp_editar_respuesta_selccla);
//ActualizarImagenPregunta
router.post('/ActualizarImagenPregunta', upload.single('file'), ActualizarImagenPregunta);
//ActualizarImagenRespuesta
router.post('/ActualizarImagenRespuesta', uploadRes.single('file'), ActualizarImagenRespuesta);
//Editar_estadp_correcto_incorrecto_respuesta
router.post('/Editar_estadp_correcto_incorrecto_respuesta',  Editar_estadp_correcto_incorrecto_respuesta);

//SELCIMG_dato_pregunta_id_pregunta
module.exports = router;
/*
        |I'M NOT IN DANGER SKYLER ------
        \\I'M THE DANGER
    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠜⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⠿⠿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⣿
    '⣿⣿⡏⠁⠀⠀⠀⠀⠀⣀⣠⣤⣤⣶⣶⣶⣶⣶⣦⣤⡄⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿
    '⣿⣿⣷⣄⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⡧⠇⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣾⣮⣭⣿⡻⣽⣒⠀⣤⣜⣭⠐⢐⣒⠢⢰⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⣏⣿⣿⣿⣿⣿⣿⡟⣾⣿⠂⢈⢿⣷⣞⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣷⣶⣾⡿⠿⣿⠗⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠻⠋⠉⠑⠀⠀⢘⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⣿⡿⠟⢹⣿⣿⡇⢀⣶⣶⠴⠶⠀⠀⢽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⣿⣿⣿⡿⠀⠀⢸⣿⣿⠀⠀⠣⠀⠀⠀⠀⠀⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    '⣿⣿⣿⡿⠟⠋⠀⠀⠀⠀⠹⣿⣧⣀⠀⠀⠀⠀⡀⣴⠁⢘⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿
    '⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⠗⠂⠄⠀⣴⡟⠀⠀⡃⠀⠉⠉⠟⡿⣿⣿⣿⣿
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⠾⠛⠂⢹⠀⠀⠀⢡⠀⠀⠀⠀⠀⠙⠛⠿⢿'
*/