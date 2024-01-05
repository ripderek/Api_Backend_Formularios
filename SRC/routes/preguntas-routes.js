const { Router } = require('express');
const router = Router();
const { preguntas_nivel, tipos_maestros_preguntas, plantillas_disponibles, icono_plantilla, crear_pregunta, MEMRZAR_dato_pregunta, ver_imagen_pregunta, MEMRZAR_dato_pregunta_id_pregunta, opciones_respuestas_MEMRZAR, ver_img_respuesta_MEMRZAR, crear_respuesta_MEMRZAR, crear_pregunta_SELCIMG, SELCIMG_dato_pregunta, SELCIMG_dato_pregunta_id_pregunta } = require('../controllers/Preguntas/preguntas-controller');
const { upload } = require('../middleware/multer-preguntas');
const { uploadRes } = require('../middleware/multer-respuestas');

//router.post('/Login', verificaUser);
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
router.post('/Crear_respuestaMEMRZAR', uploadRes.single('file'), crear_respuesta_MEMRZAR);

router.get('/MEMRZAR_Datos_pregunta/:id', MEMRZAR_dato_pregunta);
router.get('/MEMRZAR_Datos_pregunta_id_pregunta/:id', MEMRZAR_dato_pregunta_id_pregunta);
router.get('/SELCIMG_Datos_pregunta/:id', SELCIMG_dato_pregunta);
router.get('/SELCIMG_Datos_pregunta_id_pregunta/:id', SELCIMG_dato_pregunta_id_pregunta);

//SELCIMG_dato_pregunta_id_pregunta

module.exports = router; 