import { pool } from "../bd_connection/bd_floristeria.js";

export const getFloristerias = async(req,res) =>{
  try{
    const {rows} = await pool.query(`select id_floristeria,nombre
      from floristeria`);

// Verificar si no hay registros o si algún campo es null
if (!rows.length) {
return res.status(200).json([]);
}

return res.status(200).json(rows);
  }catch(error){
        return res.status(500).json(error);
    }
}

export const getColores = async(req,res) =>{
  try{
    const {rows} = await pool.query(`select codigo_color,color
      from color`);

// Verificar si no hay registros o si algún campo es null
if (!rows.length) {
return res.status(200).json([]);
}

return res.status(200).json(rows);
  }catch(error){
        return res.status(500).json(error);
    }
}

export const postCatalogoFloristeria = async(req,res)=>{
  try{
    const {  floristeriaID, florCorte, color_id,
      nombre, descripcion} = req.body;

     const result = await pool.query(`INSERT INTO catalogo_floris (cf_idfloristeria, cf_id, nombre, idflorcorte, idcolor, descripcion)
                          VALUES($1,nextval('secuencia_general'),$2,$3,$4,$5) RETURNING *`,
                          [floristeriaID,nombre,florCorte,color_id,descripcion]);

      // Devolver el registro insertado y un mensaje de éxito al front-end
      return res.status(201).json({
        message: 'Flor añadida al catálogo exitosamente',
        data: result.rows[0]
      });
  }catch(error){
        return res.status(500).json({
          message: 'Error al añadir la flor al catálogo',
          error: error.message
        });
    }
}

export const getFlorFloristeria = async(req, res) => {
  try {
    const { id_floris } = req.params;

    const { rows } = await pool.query(`
      SELECT 
        cf.cf_idFloristeria,
        cf.nombre,
        AVG(dfc.valor_promedio) AS promedio_venta,
        cf.cf_id,
        fc.nombre_comun AS flor_nombre,
        fc.genero_especie AS flor_genero_especie,
        fc.etimologia AS flor_etimologia,
        c.color AS color_nombre,
        c.descripcion AS color_descripcion
      FROM 
        catalogo_floris cf
      LEFT JOIN 
        det_fact_comp dfc ON cf.cf_idFloristeria = dfc.det_cfFloris AND cf.cf_id = dfc.det_cfID
      LEFT JOIN 
        flor_corte fc ON cf.idFlorCorte = fc.id_corte
      LEFT JOIN 
        color c ON cf.idColor = c.codigo_color
      WHERE 
        cf.cf_idFloristeria = $1
      GROUP BY 
        cf.cf_idFloristeria, cf.nombre, cf.cf_id, fc.nombre_comun, fc.genero_especie, fc.etimologia, c.color, c.descripcion
      ORDER BY 
        cf.nombre ASC, promedio_venta DESC
    `, [id_floris]);

    if (!rows.length) {
      return res.status(200).json([]);
    }

    return res.status(200).json(rows);
  } catch (error) {
    return res.status(500).json({
      message: 'Error al obtener las flores de la floristería',
      error: error.message
    });
  }
}

export const getFlorEspecifica = async(req,res)=>{
  try{
    const { id_floris } = req.params;

    const {rows} = await pool.query(`SELECT cf.*, hp.*
FROM catalogo_floris cf
LEFT JOIN historico_precio hp
ON cf.cf_id = hp.cfID
WHERE cf.cf_id = $1 AND hp.fecha_fin IS NULL;
`,[id_floris]);
          
                                      if (!rows.length) {
                                        return res.status(200).json([]);
                                      }
                                  
                                      return res.status(200).json(rows[0]);
  }catch (error) {
    return res.status(500).json({
      message: 'Error al obtener las flores de la floristería',
      error: error.message
    });
  }
}

export const getBouquets = async(req,res) =>{
  try{
    const { id_floris } = req.params;

    const {rows} = await pool.query(`SELECT b.*, hp.precio_hist FROM catalogo_floris cf
LEFT JOIN det_bouquet b
ON cf.cf_id = b.cfid
LEFT JOIN historico_precio hp
ON cf.cf_id = hp.cfID
WHERE cf.cf_id = $1 AND hp.fecha_fin IS NULL; `,[id_floris]);


if (!rows.length) {
  return res.status(200).json([]);
}

return res.status(200).json(rows);
  }catch (error) {
    return res.status(500).json({
      message: 'Error al obtener las flores de la floristería',
      error: error.message
    });
  }
}

export const getFechasFacturas = async(req, res) => {
  try {
    const { id_floristeria } = req.params;

    const { rows } = await pool.query(`
      SELECT TO_CHAR(fs.fecha_factura, 'YYYY-MM-DD') AS fecha_factura, fs.cod_fac_sub
      FROM factura_subasta fs
      WHERE fs.afi_idfloris = $1
    `, [id_floristeria]);

    if (!rows.length) {
      return res.status(200).json([]);
    }

    return res.status(200).json(rows);
  } catch (error) {
    return res.status(500).json({
      message: 'Error al obtener las fechas de facturas',
      error: error.message
    });
  }
}

export const getFactura = async(req, res) => {
  try {
    const { factura_id } = req.params;

    const { rows } = await pool.query(`
      SELECT fs.cod_fac_sub, fs.fecha_factura,fs.precio_total,
      fs.envio, f.*, s.id_subastadora, s.nombre_subas,s.direccion_pppal
      FROM factura_subasta fs
      JOIN floristeria f ON fs.afi_idfloris = f.id_floristeria
      JOIN subastadora s ON fs.afi_idsubas = s.id_subastadora
      WHERE fs.cod_fac_sub = $1
    `, [factura_id]);

    if (!rows.length) {
      return res.status(404).json({ message: 'Factura no encontrada' });
    }

    return res.status(200).json(rows[0]); // Devolver la primera (y única) fila
  } catch (error) {
    return res.status(500).json({
      message: 'Error al obtener la factura',
      error: error.message
    });
  }
}

export const getLoteByFacturaId = async(req,res) => {
  try{
    const {factura_id} = req.params;

      const {rows} = await pool.query(`SELECT l.*,p.*,cp.* FROM lote l, productor p,catalogo_pro cp
                                      WHERE l.lote_idpro = p.id_productor AND
                                       cp.codigo_vbn = l.lote_idcvbn AND
                                        l.lote_idfactura = $1`,[factura_id]);

                                        if (!rows.length) {
                                          return res.status(404).json({ message: 'Factura no encontrada' });
                                        }
                                    
                                        return res.status(200).json(rows); 
  } catch (error) {
    return res.status(500).json({
      message: 'Error al obtener la factura',
      error: error.message
    });
  }
}