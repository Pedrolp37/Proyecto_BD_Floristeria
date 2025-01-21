import { Router } from "express";
import { getFloristerias, getColores, postCatalogoFloristeria,
        getFlorFloristeria, getFlorEspecifica, getBouquets,
        getFechasFacturas, getFactura, getLoteByFacturaId} from '../controllers/floristeriacontroller.js';

const router = Router();

router.get('/floristerias',getFloristerias);

router.get('/colores',getColores);

router.post('/post-catalogo-floristeria',postCatalogoFloristeria);

router.get('/flores-floristeria/:id_floris',getFlorFloristeria);

router.get('/catalogo-floristeria/:id_floris',getFlorEspecifica);

router.get('/det-bouquet/:id_floris',getBouquets);

router.get('/fechas-facturas/:id_floristeria',getFechasFacturas);

router.get('/factura/:factura_id',getFactura);

router.get('/lote/:factura_id', getLoteByFacturaId);

export default router;