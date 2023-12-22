const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const cookieParser = require('cookie-parser');
const http = require('http');


//Este middleware se ejecuta antes de entrar a una ruta protegida, es decir, se necesita un token valido para acceder
const { authenticateToken } = require('./middleware/authorization.js');

//variables donde se importa las rutas
const authRoutes = require('./routes/auth-routes.js');
const userRoutes = require('./routes/user-routes.js');
const seccionesRoutes = require('./routes/secciones-routes.js');
const nivelesRoutes = require('./routes/niveles-routes.js');
const preguntasRoutes = require('./routes/preguntas-routes.js');
const participantesRoutes=require('./routes/participantes-routes.js');
const testRoutes = require('./routes/test-routes.js');

//config entorno
dotenv.config();


//Consfigurar el puerto donde se va abrir la API
const app = express();

const PORT = 4099;

const corsOptions = { credentials: true, origin: "http://26.158.133.96:3000" };

//config del server
app.use(cors(corsOptions));
app.use(express.json());
app.use(cookieParser());

//Las rutas estan separadas por archivos 
//esta ruta no estara protegida por un middleware ya que serivira para verificar el

//Rutas publicas sin token
//inicio de sesion
app.use('/auth', authRoutes);

//rutas protegidas con token
//ruta para los usuarios
app.use('/users', authenticateToken, userRoutes)
app.use('/secciones', authenticateToken, seccionesRoutes)
app.use('/niveles', authenticateToken, nivelesRoutes);
app.use('/preguntas', authenticateToken, preguntasRoutes);
app.use('/participantes',authenticateToken, participantesRoutes);
app.use('/test',authenticateToken,testRoutes);

//rutas protegidas con middleare, es decir, se necesita un token valido para acceder
//app.use('/api/user', authenticateToken, userRoutes);


//Iniciar la API
app.listen(PORT, () => console.log('SERVER ON PORT' + PORT));