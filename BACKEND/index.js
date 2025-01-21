import express from 'express';
import { PORT, CorsOptions } from './config.js';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import cors from 'cors';
// ROUTES
import productorRoutes from './src/routes/productorroutes.js';
import floristeriaRoutes from './src/routes/floristeriaroutes.js';

const app = express();

app.use(express.json());
app.use(cors(CorsOptions));

// Obtener el nombre del archivo y el directorio actual
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configura Express para servir archivos estáticos desde la carpeta frontend
app.use(express.static(path.join(__dirname, '../frontend')));
app.use('/images', express.static(path.join(__dirname, 'images')));

app.use(productorRoutes);
app.use(floristeriaRoutes);

app.listen(PORT, () => {
    console.log(`Servidor escuchando en el puerto ${PORT}`);
});
