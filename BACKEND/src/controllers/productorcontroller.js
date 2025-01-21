import { pool } from "../bd_connection/bd_floristeria.js";

export const getProductores = async(req,res)=>{
    try{
        const {rows} = await pool.query(`select id_productor,nombre_productor
                                        from productor`);

        // Verificar si no hay registros o si algún campo es null
        if (!rows.length) {
            return res.status(200).json([]);
          }

        return res.status(200).json(rows);
    }catch(error){
        return res.status(500).json(error);
    }
}

export const getFlorCorte = async(req,res) =>{
    try{
        const {rows} = await pool.query(`SELECT * FROM flor_corte`);

             // Verificar si no hay registros o si algún campo es null
        if (!rows.length) {
            return res.status(200).json([]);
          }

        return res.status(200).json(rows);
    }catch(error){
        return res.status(500).json(error);
    }
}

export const postFlorCatalogo = async(req,res) =>{
  try{
    const {  productorid, florCorte,vbn,
      nombre, descripcion} = req.body;
      const logoPath = req.file ? req.file.filename : null;

     const result = await pool.query(`INSERT INTO catalogo_pro (cp_idpro, codigo_vbn, nombre_flor_pro, logo_flor, cp_idCorte, descripcion)
                          VALUES($1,$2,$3,$4,$5,$6) RETURNING *`,
                          [productorid,vbn,nombre,logoPath,florCorte,descripcion]);

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

export const getFloresProductor = async(req,res) =>{
  try{
    const { id_productor } = req.params;

    const { rows } = await pool.query(`select * from catalogo_pro where cp_idpro = $1`,[id_productor]);

    return res.status(200).json(rows);
  }catch(error){
        return res.status(500).json({
          message: 'Error al obtener las flores del productor',
          error: error.message
        });
    }
}

export const getFlorProductor = async(req,res)=>{
  try{
    const {id_flor } = req.params;

     const {rows} = await pool.query(`SELECT * from flor_corte, catalogo_pro where id_corte = cp_idcorte 
                                                                and codigo_vbn = $1`,[id_flor]);

      if (!rows.length) {
       return res.status(200).json([]);
         }

      return res.status(200).json(rows[0]);
  }catch(error){
        return res.status(500).json({
          message: 'Error al obtener las flores del productor',
          error: error.message
        });
    }
}

export const getTipoFlorProductor = async(req,res) =>{
  try{
    const { productor_id } = req.params;

    const {rows} = await pool.query(`SELECT * from flor_corte, catalogo_pro WHERE id_corte = cp_idcorte
                                     AND cp_idpro= $1`,[productor_id]);

                                      if (!rows.length) {
                                        return res.status(200).json([]);
                                          }
                                 
                                       return res.status(200).json(rows);                                   
  }catch(error){
        return res.status(500).json({
          message: 'Error al obtener las flores del productor',
          error: error.message
        });
    }
}

export const getTipoFloresProductor = async (req, res) => {
  const { productorId, tipoFlorId } = req.params;

  try {
    let query = `SELECT * FROM flor_corte fc,catalogo_pro cp WHERE fc.id_corte = cp.cp_idcorte
                                      AND cp_idpro= $1`;
    const queryParams = [productorId];
    
    if (tipoFlorId) {
      query += ` AND fc.id_corte = $2`;
      queryParams.push(tipoFlorId);
    }

    const { rows } = await pool.query(query, queryParams);

    if (!rows.length) {
      return res.status(200).json([]);
    }

    return res.status(200).json(rows);
  } catch (error) {
    return res.status(500).json({
      message: 'Error al obtener los tipo de flores asociadas al productor',
      error: error.message
    });
  }
};
