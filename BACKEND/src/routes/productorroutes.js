import { Router } from "express";
import {getProductores, getFlorCorte, postFlorCatalogo,
    getFloresProductor, getFlorProductor, getTipoFlorProductor,
    getTipoFloresProductor } from '../controllers/productorcontroller.js';
    import multer from 'multer';
    import path from 'path';
    import { fileURLToPath } from 'url'; 
    import { dirname } from 'path';

const router = Router();

// Definir __dirname usando import.meta.url
 const __filename = fileURLToPath(import.meta.url); 
 const __dirname = dirname(__filename);

// Configuración de multer para guardar las imágenes en la carpeta 'images'
const storage = multer.diskStorage({ 
    destination: (req, file, cb) => { 
        cb(null, path.join(__dirname, '../../images/')); 
    }, 
    filename: (req, file, cb) => { 
        cb(null, Date.now() + path.extname(file.originalname)); // Usar el timestamp como nombre de archivo 
    } 
}); 
    
const upload = multer({ storage: storage });

//Rutas
router.get('/productores',getProductores);

router.get('/florCorte',getFlorCorte);

router.post('/post-catalogo-productor',upload.single('logo'),postFlorCatalogo);

router.get('/flores-productor/:id_productor',getFloresProductor);

router.get('/flor-productor/:id_flor',getFlorProductor);

router.get('/productor/tipo-flor/:productor_id',getTipoFlorProductor);

router.get('/flores-productor/:productorId/tipo/:tipoFlorId?',getTipoFloresProductor);

export default router;