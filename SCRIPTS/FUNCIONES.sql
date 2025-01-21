-- Programas almacenados
CREATE OR REPLACE FUNCTION listar_subastadoras()
RETURNS TABLE(id NUMERIC, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_subastadora, nombre_subas FROM SUBASTADORA;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_productores()
RETURNS TABLE(id NUMERIC, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_productor, nombre_productor FROM PRODUCTOR;
END;
$$ LANGUAGE plpgsql;

select establecer_contrato(productor_id INT,subastador_id INT,porcentaje numeric(10,0));

CREATE OR REPLACE PROCEDURE establecer_contrato(pro_id IN contrato.idpro%type,subas_id IN contrato.idsubas%type,
												porcentaje IN contrato.porcentaje%type)
LANGUAGE plpgsql 
AS $$
DECLARE
	clas contrato.clasificacion%type;
BEGIN
	-- Determinar la clasificación basada en el porcentaje 
	IF porcentaje = 100 THEN 
		clas := 'KA';-- Productor extranjero que ofrece el 100% de su producción 
	ELSIF porcentaje > 50 THEN 
		clas := 'CA'; -- Productor que ofrece más del 50% de su producción 
	ELSIF porcentaje >= 20 AND porcentaje <= 50 THEN 
		clas := 'CB'; -- Productor que ofrece entre el 20% y el 50% de su producción 
	ELSIF porcentaje < 20 AND porcentaje > 0 THEN 
		clas := 'CC'; -- Productor que ofrece menos del 20% de su producción 
	ELSE clas := 'CG'; -- Productor que tiene contratos con varias compañías subastadoras
	END IF;

	INSERT INTO CONTRATO (idsubas,idpro,id_contrato,fecha_ini,clasificacion,porcentaje,cancelado)
	VALUES
	(subas_id,pro_id,nextval('secuencia_contrato'),NOW(),clas,porcentaje,FALSE);

	-- Mensaje de exito
	RAISE NOTICE 'Contrato creado exitosamente: idpro=%, idsubas=%, porcentaje=%, clasificacion=%', 
    pro_id, subas_id, porcentaje, clas;

	EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al crear el contrato: %', SQLERRM;
END;
$$;


CREATE OR REPLACE FUNCTION listar_catalogo_productor(pro_id numeric(5,0))
RETURNS TABLE(codigo_vbn VARCHAR(12), nombre_flor_pro VARCHAR(30),nombre_comun VARCHAR(30)) AS $$
BEGIN
    RETURN QUERY
	SELECT cp.codigo_vbn AS "codigo vbn", cp.nombre_flor_pro, fc.nombre_comun FROM flor_corte fc, catalogo_pro cp
	WHERE fc.id_corte =cp.cp_idcorte AND cp.cp_idpro = pro_id
	ORDER BY fc.nombre_comun;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE ingresar_detalle_contrato(
    id_contrato detalle_contrato.det_cont%type,
	id_productor detalle_contrato.det_pro%type,
	id_subastadora detalle_contrato.det_subas%type,
    id_flores VARCHAR[],
    cantidades NUMERIC(10,0)[]
) 
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN
    -- Verificar que ambos arrays tengan la misma longitud
    IF array_length(id_flores, 1) != array_length(cantidades, 1) THEN
        RAISE EXCEPTION 'Los arrays no tienen la misma longitud';
    END IF;

    -- Insertar los datos en la tabla detalle_contrato
    FOR i IN 1 .. array_length(id_flores, 1) LOOP
        INSERT INTO detalle_contrato (det_subas, det_pro, det_cont,det_idPro,det_vbn,cantidad_anual)
        VALUES (id_subastadora,id_productor,id_contrato,id_productor, id_flores[i], cantidades[i]);

		-- Mensaje de éxito para cada inserción 
		RAISE NOTICE 'Detalle del contrato insertado exitosamente: id_contrato=%, id_flora=%, cantidad_anual=%', 
		id_contrato, id_flores[i], cantidades[i];
    END LOOP;

	-- Mensaje final de éxito 
	RAISE NOTICE 'Todos los detalles del contrato fueron insertados exitosamente para id_contrato=%',
	id_contrato;

	EXCEPTION 
	-- Manejo de errores
	WHEN OTHERS THEN
		RAISE EXCEPTION 'Error al insertar detalles del contrato: %', SQLERRM;
END;
$$;


-- ############## PROCESO DE COMPRA EN SUBASTA ###########################
-- ####################### CONTROL DE FACTURA ######################

CREATE OR REPLACE FUNCTION listar_floristerias()
RETURNS TABLE(id NUMERIC, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT f.id_floristeria, f.nombre FROM FLORISTERIA f;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_afiliaciones(id_floris floristeria.id_floristeria%type)
RETURNS TABLE(id_floristeria NUMERIC, floristeria VARCHAR, id_subastadora NUMERIC, subastadora VARCHAR) AS $$
BEGIN
	RETURN QUERY SELECT f.id_floristeria,f.nombre,s.id_subastadora,s.nombre_subas FROM subastadora s, floristeria f, afiliacion a
				WHERE  a.afi_id_floristeria = id_floris AND a.afi_id_subastadora = s.id_subastadora
				AND f.id_floristeria = id_floris;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_contrato_vbn(subastadora_id NUMERIC)
RETURNS TABLE( codigo_vbn VARCHAR,id_contrato NUMERIC) AS $$
BEGIN
	RETURN QUERY SELECT dc.det_vbn, c.id_contrato FROM contrato c, detalle_contrato dc,productor p, catalogo_pro cp
					WHERE c.idsubas = dc.det_subas AND dc.det_vbn = cp.codigo_vbn
					AND dc.det_pro = p.id_productor
					AND c.idsubas = subastadora_id AND c.cancelado =FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE establecer_factura_subasta(
	id_subastadora afiliacion.afi_id_subastadora%type,
	id_floristeria afiliacion.afi_id_floristeria%type,
	ids_contrato NUMERIC[],
	vbn_flor VARCHAR[],
	cantidad_lote NUMERIC[],
	precio_final NUMERIC[],
	precio_inicial NUMERIC[],
	indice_bl NUMERIC[],
	envio boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
	j INT;
	precio_total NUMERIC :=0;
	factura_id NUMERIC;
	num_lote NUMERIC;
	id_productor NUMERIC;
BEGIN
	-- Calcular el precio total
	FOR J IN 1 .. array_length(precio_final, 1) LOOP
		precio_total := precio_total + precio_final[j];
	END LOOP;
	-- Aplicar el 10% adicional si envio es TRUE
	IF envio THEN
    precio_total := precio_total * 1.10;
	END IF;

	
		INSERT INTO FACTURA_SUBASTA (cod_fac_sub, fecha_factura, precio_total,afi_idfloris, afi_idsubas,envio)
		VALUES
		 (nextval('secuencia_facturas'),NOW(),precio_total,id_floristeria,id_subastadora,envio)
		 RETURNING cod_fac_sub INTO factura_id;

	FOR i IN 1 .. array_length(ids_contrato, 1) LOOP 
		SELECT c.idpro INTO id_productor FROM contrato c WHERE c.id_contrato = ids_contrato[i] 
		LIMIT 1;
	END LOOP;
		 
    -- Insertar los datos en la tabla detalle_contrato
    FOR i IN 1 .. array_length(ids_contrato, 1) LOOP
        INSERT INTO LOTE (lote_idfactura, lote_idsubas, lote_idpro, lote_idcont, lote_idcpro, lote_idcvbn,numerolote,
							cantidad_lote,precio_final,precio_inicial,indice_bl)
        VALUES (factura_id,id_subastadora,id_productor,ids_contrato[i],id_productor, vbn_flor[i], nextval('secuencia_lote'),
				 cantidad_lote[i],precio_final[i],precio_inicial[i],indice_bl[i])
		RETURNING numerolote INTO num_lote;
		-- Mensaje de éxito para cada inserción 
		RAISE NOTICE 'El Lote se ha generado exitosamente: numero lote=%, precio final lote=%, cantidad=%', 
		num_lote, precio_final[i],cantidad_lote[i];
    END LOOP;

	-- Mensaje final de éxito 
	RAISE NOTICE 'La Factura se ha generado con exito numero factura =%',
	factura_id;

	EXCEPTION 
	-- Manejo de errores
	WHEN OTHERS THEN
		RAISE EXCEPTION 'Error al insertar detalles de la factura: %', SQLERRM;
END;
$$;

-- #########################################################################3


-- ########################### PROCESO DE PAGOS Y MULTAS ###############################

CREATE OR REPLACE FUNCTION verificar_estatus_contratos()
RETURNS TABLE(
   id_productor NUMERIC,
   nombre_productor VARCHAR, 
   id_contrato NUMERIC,
   clasificacion VARCHAR, 
   tipo VARCHAR,
   monto NUMERIC,
   id_subas NUMERIC
) AS $$
BEGIN
    RETURN QUERY
   SELECT DISTINCT ON (c.id_contrato) p.id_productor,p.nombre_productor, c.id_contrato, c.clasificacion, pm.tipo,
   										pm.monto,pm.pago_subas
FROM productor p
JOIN contrato c ON p.id_productor = c.idpro
JOIN pagos_multas pm ON p.id_productor = pm.pago_pro
WHERE 
    c.cancelado = FALSE 
    AND pm.fecha_pagos BETWEEN (current_date - interval '1 month - 5 days') AND current_date
    AND p.id_productor = pm.pago_pro
GROUP BY
	c.id_contrato,p.id_productor, p.nombre_productor, c.clasificacion, pm.tipo,pm.id_pagos,pm.monto,
	pm.pago_subas
ORDER BY
c.id_contrato,pm.id_pagos DESC;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE establecer_accion_pago(
    p_id_productor NUMERIC,
    p_clasificacion VARCHAR,
    p_tipo VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    contrato RECORD;
    monto_multa NUMERIC;
    comision NUMERIC;
    total_comision NUMERIC;
BEGIN
    -- Obtener el contrato correspondiente al productor
    FOR contrato IN
        SELECT * FROM verificar_estatus_contratos()
        WHERE id_productor = p_id_productor AND clasificacion = p_clasificacion
    LOOP
        CASE p_tipo
            WHEN 'MULTA' THEN
                -- Aplicar una multa del 20% del monto del contrato
                monto_multa := contrato.monto * 0.20;
                INSERT INTO pagos_multas (pago_subas, pago_pro, pago_contrato, id_pagos,tipo, fecha_pagos, monto)
                VALUES (contrato.id_subas, p_id_productor, contrato.id_contrato,nextval('secuencia_pagos'), 'MULTA', current_date, monto_multa);
                RAISE NOTICE 'Multa aplicada a contrato %: %', contrato.id_contrato, monto_multa;

            WHEN 'COMISION' THEN
                -- Calcular la comisión basada en la clasificación
                comision := CASE p_clasificacion
                    WHEN 'CA' THEN contrato.monto * 0.005
                    WHEN 'CB' THEN contrato.monto * 0.01
                    WHEN 'CC' THEN contrato.monto * 0.02
                    WHEN 'CG' THEN contrato.monto * 0.05
                    WHEN 'KA' THEN contrato.monto * 0.0025
                    ELSE 0
                END;

                -- Verificar si existen registros previos en pagos_multas
                IF NOT EXISTS (
                    SELECT 1 
                    FROM pagos_multas 
                    WHERE pago_contrato = contrato.id_contrato
                ) THEN
                    -- Usar fecha_ini del contrato y establecer nueva comisión
                    total_comision := comision;
                    INSERT INTO pagos_multas (pago_subas, pago_pro, pago_contrato, id_pagos,tipo, fecha_pagos, monto)
                    VALUES (contrato.id_subas, contrato.id_productor, contrato.id_contrato,nextval('secuencia_pagos'), 'COMISION', contrato.fecha_ini, total_comision);
                    RAISE NOTICE 'Nueva comisión aplicada a contrato %: %', contrato.id_contrato, total_comision;
                ELSE
                    -- Sumar la comisión no pagada a cualquier multa existente
                    SELECT SUM(monto) INTO monto_multa 
                    FROM pagos_multas 
                    WHERE tipo = 'MULTA' AND pago_contrato = contrato.id_contrato;

                    total_comision := comision + COALESCE(monto_multa, 0);

                    -- Insertar la comisión total
                    INSERT INTO pagos_multas (pago_subas, pago_pro, pago_contrato, id_pagos,tipo, fecha_pagos, monto)
                    VALUES (contrato.id_subas, contrato.id_productor, contrato.id_contrato, nextval('secuencia_pagos'),'COMISION', current_date, total_comision);
                    RAISE NOTICE 'Comisión aplicada a contrato %: %', contrato.id_contrato, total_comision;
                END IF;

            WHEN 'MEMBRESIA' THEN
                -- Registrar el pago de membresía
                INSERT INTO pagos_multas (pago_subas, pago_pro, pago_contrato,id_pagos, tipo, fecha_pagos, monto)
                VALUES (contrato.id_subas, contrato.id_productor, contrato.id_contrato, nextval('secuencia_pagos'),'MEMBRESIA', current_date, contrato.monto);
                RAISE NOTICE 'Membresía registrada para contrato %', contrato.id_contrato;

            WHEN 'CANCELACION' THEN
                -- Cancelar el contrato
                UPDATE contrato
                SET cancelado = TRUE
                WHERE id_contrato = contrato.id_contrato;
                RAISE NOTICE 'Contrato % cancelado', contrato.id_contrato;
        END CASE;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ocurrió un error: %', SQLERRM;
END;
$$;


-- ##################### PROCESO DE RECOMENDACIONES ##################################

CREATE OR REPLACE FUNCTION listar_significado(floristeria_id NUMERIC, s_tipo significado.tipo%type)
RETURNS TABLE(
    id significado.id_significado%type,
    significado significado.descripcion%type
) AS $$
BEGIN
    RETURN QUERY 
    SELECT DISTINCT ON(s.id_significado) 
        s.id_significado, 
        s.descripcion 
    FROM 
        SIGNIFICADO s
    JOIN 
        ENLACE e ON e.idSignificado = s.id_significado
    JOIN 
        CATALOGO_FLORIS cf ON (cf.idFlorCorte = e.idCorte OR cf.idColor = e.idColorEnlace)
    WHERE 
        cf.cf_idFloristeria = floristeria_id
        AND s.tipo = s_tipo;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE recomendacion(
    p_id_corte NUMERIC,
    p_id_color VARCHAR,
    p_id_sentimiento NUMERIC,
    p_id_ocasion NUMERIC,
    p_id_floristeria NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
	count_results INTEGER := 0;
BEGIN
    FOR rec IN
        SELECT 
            f.nombre_comun AS Flor,
            c.color AS Color,
            s1.descripcion AS Sentimiento,
            s2.descripcion AS Ocasion,
            cf.nombre AS Floristeria,
			cf.idflorcorte AS Corte_id
        FROM 
            CATALOGO_FLORIS cf
        LEFT JOIN 
            FLOR_CORTE f ON cf.idFlorCorte = f.id_corte
        LEFT JOIN 
            COLOR c ON cf.idColor = c.codigo_color
        LEFT JOIN 
            ENLACE e ON (e.idCorte = f.id_corte OR e.idColorEnlace = c.codigo_color)
        LEFT JOIN 
            SIGNIFICADO s1 ON e.idSignificado = s1.id_significado AND s1.tipo = 'SENTIMIENTO'
        LEFT JOIN 
            SIGNIFICADO s2 ON e.idSignificado = s2.id_significado AND s2.tipo = 'OCASION'
        WHERE 
            cf.cf_idFloristeria = p_id_floristeria
            AND (p_id_corte IS NULL OR cf.idFlorCorte = p_id_corte)
            AND (p_id_color IS NULL OR cf.idColor = p_id_color)
            AND (p_id_sentimiento IS NULL OR s1.id_significado = p_id_sentimiento)
            AND (p_id_ocasion IS NULL OR s2.id_significado = p_id_ocasion)
        ORDER BY 
            f.nombre_comun, c.color, s1.descripcion, s2.descripcion, cf.nombre
    LOOP
        RAISE NOTICE 'Floristeria: %, id flor: %, Flor: %, Color: %, Sentimiento: %, Ocasion: %', 
                    rec.Floristeria,rec.Corte_id ,rec.Flor, rec.Color, rec.Sentimiento, rec.Ocasion;
		count_results := count_results + 1;
    END LOOP;

	IF count_results = 0 THEN 
		RAISE NOTICE 'No se encontraron resultados para los criterios proporcionados.';
	END IF;
END;
$$;
