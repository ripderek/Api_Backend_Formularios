const { Router } = require('express');
const router = Router();
const { preguntas_nivel, tipos_maestros_preguntas, plantillas_disponibles, icono_plantilla, crear_pregunta } = require('../controllers/Preguntas/preguntas-controller');
const { upload } = require('../middleware/multer-preguntas');

//router.post('/Login', verificaUser);
router.get('/Preguntas_nivel/:id', preguntas_nivel);
router.get('/Tipos_preguntas_maestras', tipos_maestros_preguntas);
router.get('/Plantillas/:id', plantillas_disponibles);
router.get('/Icono/:id', icono_plantilla);

//ruta para crear una pregunta y guardar la imagen 
router.post('/Crear_pregunta', upload.single('file'), crear_pregunta);

module.exports = router; 