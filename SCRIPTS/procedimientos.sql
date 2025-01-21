-- call ganancia_neta_mensual(37,'12','2024')

CREATE OR REPLACE PROCEDURE ganancia_neta_mensual(idfloris IN floristeria.id_floristeria%type, mes IN varchar(10), anualidad IN varchar(4))
LANGUAGE plpgsql 
AS $$
DECLARE
    compras RECORD;
    ventas RECORD;
    tipo_flor RECORD;
    ventas_floristeria RECORD;
    total_compras NUMERIC := 0;
    total_ventas NUMERIC := 0;
    total_envio NUMERIC := 0;
	total_neto NUMERIC :=0;
    fecha_factura_anterior DATE := NULL;
	fecha_factura_anterior_floris DATE :=NULL;
    productor_anterior TEXT := NULL;
    total_facturas NUMERIC := 0;
    total_lotes NUMERIC := 0;
    diferencia NUMERIC := 0;
	mes_nombre TEXT := TO_CHAR(TO_DATE(mes, 'MM'),'Month');
    cursor_compra CURSOR FOR
        SELECT fecha_factura, precio_total, envio
        FROM factura_subasta
        WHERE afi_idFloris = idfloris AND TO_CHAR(fecha_factura, 'MM') = mes AND TO_CHAR(fecha_factura, 'YYYY') = anualidad
        ORDER BY fecha_factura;
    cursor_ventas CURSOR FOR
        SELECT monto_total
        FROM factura_compradora
        WHERE factura_idFloris = idfloris AND TO_CHAR(fecha_factura, 'MM') = mes AND TO_CHAR(fecha_factura, 'YYYY') = anualidad;
    cursor_detalle_subasta CURSOR FOR
        SELECT l.numerolote,fs.fecha_factura, p.nombre_productor, SUM(l.cantidad_lote) AS cantidad_total, SUM(l.precio_final) AS suma_total, fs.precio_total
        FROM factura_subasta fs
        JOIN lote l ON fs.cod_fac_sub = l.lote_idFactura
        JOIN catalogo_pro cp ON l.lote_idCVBN = cp.codigo_vbn
        JOIN flor_corte f ON f.id_corte = cp.cp_idCorte
        JOIN productor p ON l.lote_idPro = p.id_productor
        WHERE fs.afi_idFloris = idfloris AND TO_CHAR(fs.fecha_factura, 'MM') = mes AND TO_CHAR(fs.fecha_factura, 'YYYY') = anualidad
        GROUP BY fs.fecha_factura, p.nombre_productor, fs.precio_total,l.numerolote
        ORDER BY fs.fecha_factura, p.nombre_productor, l.numerolote;
    cursor_detalle_ventas CURSOR FOR
        SELECT fp.codigo,fp.monto_total,fp.fecha_factura, SUM(df.cantidad) AS cantidad_total
        FROM factura_compradora fp
        JOIN det_fact_comp df ON fp.codigo = df.det_idFactura AND fp.factura_idFloris = df.det_floris
        JOIN catalogo_floris cf ON df.det_cfID = cf.cf_id AND df.det_cfFloris = cf.cf_idFloristeria
        JOIN flor_corte fc ON cf.idFlorCorte = fc.id_corte
        WHERE fp.factura_idFloris = idfloris
        AND TO_CHAR(fp.fecha_factura, 'MM') = mes
        AND TO_CHAR(fp.fecha_factura, 'YYYY') = anualidad
        GROUP BY fp.codigo,fp.monto_total,fp.fecha_factura;
BEGIN

    -- Calcular total de compras
    OPEN cursor_compra; 
    LOOP 
        FETCH cursor_compra INTO compras; 
        EXIT WHEN NOT FOUND; 
        total_compras := total_compras + compras.precio_total;
        IF compras.envio THEN
            total_envio := total_envio + (compras.precio_total * 0.1);
        END IF;
    END LOOP; 
    CLOSE cursor_compra; 

	 OPEN cursor_ventas; 
    LOOP 
        FETCH cursor_ventas INTO ventas; 
        EXIT WHEN NOT FOUND; 
        total_ventas := total_ventas + ventas.monto_total;
    END LOOP;
    CLOSE cursor_ventas;

    RAISE NOTICE '-----------------------------------------------------------------------------------';
    RAISE NOTICE '|########################### Saldo por compras en subastas ###########################';

    -- Calcular y mostrar resumen por tipo de flor comprada, agrupado por fecha y productor
    OPEN cursor_detalle_subasta; 
    LOOP
        FETCH cursor_detalle_subasta INTO tipo_flor; 
        EXIT WHEN NOT FOUND; 
        IF fecha_factura_anterior IS DISTINCT FROM tipo_flor.fecha_factura THEN
            RAISE NOTICE '-----------------------------------------------------';
            RAISE NOTICE 'gastado para la fecha de: %', tipo_flor.fecha_factura;
            RAISE NOTICE '-----------------------------------------------------';
            fecha_factura_anterior := tipo_flor.fecha_factura;
            productor_anterior := NULL;
        END IF;
       
        RAISE NOTICE 'Numero lote: %, Precio Lote: %€', tipo_flor.numerolote, tipo_flor.suma_total; 
        total_lotes := total_lotes + tipo_flor.suma_total;
    END LOOP; 
    CLOSE cursor_detalle_subasta;

	RAISE NOTICE '-----------------------------------------------------------------------------------';
	RAISE NOTICE '|Total de gastado para el mes de % de %',mes_nombre,anualidad;
    RAISE NOTICE '|Total pagado por envío: %€', total_envio;
	RAISE NOTICE '|Total de Compras sin recargo de envio: %€', total_compras; 
	RAISE NOTICE '|Total de Compras mas el recargo de envio: %€', total_compras+total_envio; 
	RAISE NOTICE '-----------------------------------------------------------------------------------';

    RAISE NOTICE '-----------------------------------------------------------------------------------';
    RAISE NOTICE '|####################### Saldo por venta de flores #########################';
    RAISE NOTICE '-----------------------------------------------------------------------------------';
   
    OPEN cursor_detalle_ventas;
    LOOP
        FETCH cursor_detalle_ventas INTO ventas_floristeria;
        EXIT WHEN NOT FOUND;
		 IF fecha_factura_anterior_floris IS DISTINCT FROM ventas_floristeria.fecha_factura THEN
            RAISE NOTICE '-----------------------------------------------------';
            RAISE NOTICE 'vendido para la fecha de: %', ventas_floristeria.fecha_factura;
            RAISE NOTICE '-----------------------------------------------------';
            fecha_factura_anterior_floris := ventas_floristeria.fecha_factura;
            productor_anterior := NULL;
        END IF;
        RAISE NOTICE 'Total: %€', ventas_floristeria.monto_total;
    END LOOP;
    CLOSE cursor_detalle_ventas; 
	 RAISE NOTICE '-----------------------------------------------------';
	 RAISE NOTICE 'Saldo final de ventas para el mes de % de %',mes_nombre,anualidad;
	 RAISE NOTICE '|Total de Ventas: %€', total_ventas;
	 RAISE NOTICE '-----------------------------------------------------';
    -- Mostrar resultados 
	total_neto := total_ventas - total_compras;
	RAISE NOTICE '################################################################';
    RAISE NOTICE '################## SALDO FINAL OBTENIENDO UNA ##################';
	RAISE NOTICE 'Total en gastos: %€',total_compras+total_envio;
	RAISE NOTICE 'Total en venas: %€', total_ventas;	
	IF total_neto >=0 THEN
    RAISE NOTICE 'Ganancia Neta: %€', total_neto;
	END IF;
	IF total_neto <0 THEN
	RAISE NOTICE 'Perdida Neta: %', total_neto;
	END IF;
	RAISE NOTICE '###############################################################';
END;
$$;




-- call historico_precio_flor(37,46)

CREATE OR REPLACE PROCEDURE historico_precio_flor(idfloristeria IN floristeria.id_floristeria%type, florcorte IN catalogo_floris.cf_id%type)
LANGUAGE plpgsql 
AS $$
DECLARE
    cursor_hist CURSOR FOR
        SELECT cf.nombre, fc.nombre_comun, h.tamano_tallo, h.precio_hist, h.fecha_ini
        FROM flor_corte fc, catalogo_floris cf, historico_precio h
        WHERE cf_id = florcorte  
        AND cf.cf_idFloristeria = idfloristeria 
        AND fc.id_corte = cf.idFlorCorte 
        AND cf.cf_id = h.cfID
        AND cf.cf_idFloristeria = h.cf_floristeria
        GROUP BY cf.nombre,fc.nombre_comun, h.tamano_tallo, h.precio_hist, h.fecha_ini;
    nombre_comun VARCHAR(30);
    tamano_tallo VARCHAR(30);
    precio_historico NUMERIC;
    fecha TIMESTAMP;
    last_nombre_comun VARCHAR(30) := '';
    last_tamano_tallo NUMERIC := -1;
BEGIN
    FOR record IN cursor_hist LOOP
        IF record.nombre != last_nombre_comun THEN
            RAISE NOTICE 'Nombre de la flor: %', record.nombre;
            last_nombre_comun := record.nombre;
        END IF;

        IF record.tamano_tallo != last_tamano_tallo THEN
            RAISE NOTICE '  Tamaño del tallo: %', record.tamano_tallo;
            last_tamano_tallo := record.tamano_tallo;
        END IF;

        RAISE NOTICE '    Precio histórico: % | Fecha: %', record.precio_hist, TO_CHAR(record.fecha_ini, 'DD "de" Month "de" YYYY');
    END LOOP;
END;
$$;


--call historico_precio_flortallo(46,20)
-- PROCEDIMIENTO PARA HISTORICO DE PRECIO DE UNA FLOR DE UN TALLO ESPECIFICO
CREATE OR REPLACE PROCEDURE historico_precio_flortallo(florcorte IN catalogo_floris.cf_id%type, tallo IN historico_precio.tamano_tallo%type)
LANGUAGE plpgsql 
AS $$
DECLARE
    cursor_tallo CURSOR FOR
        SELECT cf.nombre, fc.nombre_comun, h.tamano_tallo, h.precio_hist, h.fecha_ini, h.fecha_fin
        FROM flor_corte fc, catalogo_floris cf, historico_precio h
        WHERE cf.cf_id = florcorte  
        AND h.tamano_tallo = tallo
        AND fc.id_corte = cf.idFlorCorte 
        AND cf.cf_id = h.cfID
        AND cf.cf_idFloristeria = h.cf_floristeria
        ORDER BY h.fecha_ini desc;

    is_first_record BOOLEAN := TRUE;
BEGIN
    FOR record IN cursor_tallo LOOP
        IF is_first_record THEN
            RAISE NOTICE 'Nombre de la flor: %', record.nombre;
            RAISE NOTICE '  Tamaño del tallo: %', record.tamano_tallo;
            is_first_record := FALSE;
        END IF;

        IF record.fecha_fin IS NULL THEN
            RAISE NOTICE '    Precio histórico: % | Fecha de inicio: % | Fecha de fin: Aun está vigente', 
                         record.precio_hist, 
                         TO_CHAR(record.fecha_ini, 'DD "de" Month "de" YYYY');
        ELSE
            RAISE NOTICE '    Precio histórico: % | Fecha de inicio: % | Fecha de fin: %', 
                         record.precio_hist, 
                         TO_CHAR(record.fecha_ini, 'DD "de" Month "de" YYYY'), 
                         TO_CHAR(record.fecha_fin, 'DD "de" Month "de" YYYY');
        END IF;
    END LOOP;
END;
$$;

--MUESTRA EL HISTORICO DE PRECIOS DE UNA FLOR DE UN TALLO EN UN MES DADO
-- call historico_flor_tallo_mes(46,20,'01','2025')
-- Procedimiento para historico precio de flor por tallo en un mes dado
CREATE OR REPLACE PROCEDURE historico_flor_tallo_mes(florcorte IN catalogo_floris.cf_id%type, tallo IN historico_precio.tamano_tallo%type, mes IN VARCHAR(4), anualidad IN VARCHAR(4))
LANGUAGE plpgsql 
AS $$
DECLARE
    cursor_tallo_mes CURSOR FOR
        SELECT f.nombre as floristeria, cf.nombre, fc.nombre_comun, h.tamano_tallo, h.precio_hist, h.fecha_ini, h.fecha_fin
        FROM flor_corte fc, catalogo_floris cf, historico_precio h,floristeria f
        WHERE cf.cf_id = florcorte 
		AND f.id_floristeria = cf.cf_idFloristeria
        AND h.tamano_tallo = tallo
        AND fc.id_corte = cf.idFlorCorte 
        AND cf.cf_id = h.cfID
        AND cf.cf_idFloristeria = h.cf_floristeria
        AND TO_CHAR(h.fecha_ini, 'MM') = mes  -- Filtro por mes introducido
        AND TO_CHAR(h.fecha_ini, 'YYYY') = anualidad  -- Filtro por año introducido
        ORDER BY h.fecha_ini desc;

    is_first_record BOOLEAN := TRUE;
    mes_nombre TEXT;
BEGIN
    -- Verificar si el identificador de flor es incorrecto
    PERFORM 1 FROM catalogo_floris WHERE cf_id = florcorte;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Identificador de flor incorrecto: %', florcorte;
    END IF;

    -- Verificar si el tamaño del tallo existe en los registros
    PERFORM 1 FROM historico_precio WHERE tamano_tallo = tallo;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tamaño de tallo inexistente: %', tallo;
    END IF;

    -- Convertir el número del mes al nombre del mes en español
    SELECT TO_CHAR(TO_DATE(mes, 'MM'), 'TMMonth') INTO mes_nombre;

    -- Verificar si el mes y el año tienen registros
    PERFORM 1 FROM historico_precio 
    WHERE TO_CHAR(fecha_ini, 'MM') = mes AND TO_CHAR(fecha_ini, 'YYYY') = anualidad 
    AND cfID = florcorte AND tamano_tallo = tallo;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay registros para el mes % del año %', mes_nombre, anualidad;
    END IF;

    FOR record IN cursor_tallo_mes LOOP
        IF is_first_record THEN
			RAISE NOTICE '--------------------------------------------------------------------------------------------------------------';
            RAISE NOTICE '|FLORISTERIA: %', record.floristeria;
			RAISE NOTICE '--------------------------------------------------------------------------------------------------------------';
            RAISE NOTICE '|Nombre de la flor: % de tipo: %', record.nombre,record.nombre_comun;
            RAISE NOTICE '|Tamaño del tallo: %cm', record.tamano_tallo;
            RAISE NOTICE '|Del mes: % del año: %', mes_nombre, anualidad;
			RAISE NOTICE '--------------------------------------------------------------------------------------------------------------';
            is_first_record := FALSE;
        END IF;

        IF record.fecha_fin IS NULL THEN
            RAISE NOTICE '|Precio histórico: %€ | Fecha de inicio: % | Fecha de fin: Aun está vigente', 
                         record.precio_hist, 
                         TO_CHAR(record.fecha_ini, 'DD "de" Month "de" YYYY');
        ELSE
            RAISE NOTICE '|Precio histórico: % | Fecha de inicio: % | Fecha de fin: %', 
                         record.precio_hist, 
                         TO_CHAR(record.fecha_ini, 'DD "de" Month "de" YYYY'), 
                         TO_CHAR(record.fecha_fin, 'DD "de" Month "de" YYYY');
        END IF;
    END LOOP;
			RAISE NOTICE '--------------------------------------------------------------------------------------------------------------';
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ocurrió un error: %', SQLERRM;
END;
$$;


-- call agregar_precio(37,46,20,1.60)
-- Agregar nuevo precio a flor
CREATE OR REPLACE PROCEDURE agregar_precio(
    id_floris IN historico_precio.cf_floristeria%type,
    p_cfid IN historico_precio.cfID%type,
    tallo IN historico_precio.tamano_tallo%type,
    precio_nuevo IN historico_precio.precio_hist%type
)
LANGUAGE plpgsql 
AS $$
DECLARE
    v_fecha_ini TIMESTAMP;
    v_precio_actual NUMERIC(5,2);
    v_fecha_fin TIMESTAMP;
    v_nombre VARCHAR(30);
    v_diferencia_dias INTEGER;
    v_dias_restantes INTEGER;
    v_fecha_formateada VARCHAR;
    hprecio NUMERIC(5,2);
    fecha_precio DATE;
    floris_nombre VARCHAR(30);
    v_fecha_fin_msg VARCHAR;
    v_precio_hist_msg VARCHAR;
    v_fecha_ini_msg VARCHAR;
    v_nombre_floris VARCHAR;
    v_nombre_flor VARCHAR;
BEGIN
    -- Llamar a la función para cerrar el periodo de precios, si aplica
    PERFORM cerrar_periodo_precio(id_floris, p_cfid, tallo);

    -- Verificar si existe un registro previo con el tamaño del tallo ingresado y calcular la diferencia de días
    -- Modificado para considerar registros con fecha_fin no nula
    SELECT 
        fecha_ini, 
        precio_hist,  
        EXTRACT(DAY FROM (CURRENT_TIMESTAMP - fecha_ini)), 
        to_char(fecha_ini, 'DD "de" FMMonth "de" YYYY'),
        fecha_fin
    INTO 
        v_fecha_ini, 
        v_precio_actual, 
        v_diferencia_dias, 
        v_fecha_formateada,
        v_fecha_fin
    FROM 
        historico_precio hp
    JOIN 
        catalogo_floris cf ON hp.cf_floristeria = cf.cf_idFloristeria AND hp.cfID = cf.cf_id
    WHERE 
        hp.cf_floristeria = id_floris 
        AND hp.cfID = p_cfid 
        AND hp.tamano_tallo = tallo 
        AND (hp.fecha_fin IS NULL OR hp.fecha_fin = CURRENT_DATE)
    ORDER BY hp.fecha_ini DESC 
    LIMIT 1;

    -- Calcular los días restantes
    v_dias_restantes := 7 - v_diferencia_dias;

    -- Verificar si existe un registro y si la diferencia de días es menor o igual a 7
    IF FOUND AND v_diferencia_dias <= 7 THEN
        RAISE NOTICE '-----------------------------------------------------------------------------------------------------';
        RAISE NOTICE 'Ya existe un registro con menos de 7 días.';
        RAISE NOTICE 'Último precio registrado: %€ - Fecha de registro: %', v_precio_actual, v_fecha_formateada;
        RAISE NOTICE '-----------------------------------------------------------------------------------------------------';
        RAISE EXCEPTION 'No se puede agregar un nuevo precio para este tallo, en % días podrá agregar un nuevo.', v_dias_restantes;
    ELSE
        -- Insertar el nuevo registro con la fecha de inicio actual
        INSERT INTO historico_precio (cf_floristeria, cfID, fecha_ini, precio_hist, tamano_tallo)
        VALUES (id_floris, p_cfid, CURRENT_TIMESTAMP, precio_nuevo, tallo);

        SELECT 
            cf.nombre, 
            h.precio_hist, 
            h.fecha_fin,
            f.nombre
        INTO 
            v_nombre, 
            hprecio, 
            fecha_precio,
            floris_nombre
        FROM 
            catalogo_floris cf
        JOIN 
            historico_precio h ON cf.cf_id = h.cfID 
        JOIN 
            floristeria f ON cf.cf_idFloristeria = f.id_floristeria
        WHERE 
            cf.cf_idFloristeria = id_floris 
            AND cf.cf_id = p_cfid 
            AND h.fecha_fin IS NULL 
            AND h.tamano_tallo = tallo;

        -- Asignar mensaje a v_fecha_fin_msg 
        v_fecha_fin_msg := COALESCE(to_char(v_fecha_fin, 'DD "de" FMMonth "de" YYYY'),'No existe registro anterior');
        v_fecha_ini_msg := COALESCE(to_char(v_fecha_ini, 'DD "de" FMMonth "de" YYYY'),'No existe registro anterior');
        -- Asignar mensaje a v_precio_hist_msg
        IF v_precio_actual IS NULL THEN 
            v_precio_hist_msg := 'No existe registro anterior'; 
        ELSE 
            v_precio_hist_msg := to_char(v_precio_actual, 'FM99999.00'); 
        END IF;

        -- Mostrar el nuevo registro
        RAISE NOTICE '--------------------------------------------------------';
        RAISE NOTICE 'FLORISTERIA: %', floris_nombre;
        RAISE NOTICE '--------------------------------------------------------';
        RAISE NOTICE 'Flor: %, con un tallo de: %cm', v_nombre, tallo;
        RAISE NOTICE '--------------------------------------------------------';
        RAISE NOTICE 'Cierre de precio anterior:';
        RAISE NOTICE 'Precio anterior: %', v_precio_hist_msg;
        RAISE NOTICE 'Fecha de inicio del precio anterior: %', v_fecha_ini_msg;
        RAISE NOTICE 'Fecha de cierre del registro anterior: %', v_fecha_fin_msg;
        RAISE NOTICE '--------------------------------------------------------';
        RAISE NOTICE 'Precio actual a insertar para %: %€', v_nombre, precio_nuevo;
        RAISE NOTICE '--------------------------------------------------------';
        RAISE NOTICE 'Nuevo precio para la flor % de tallo %cm es %€', v_nombre, tallo, precio_nuevo;
    END IF;
END;
$$;



-- call ultimo_precio(46,20)
CREATE OR REPLACE PROCEDURE ultimo_precio(
    p_cfid IN historico_precio.cfID%type,
    tallo IN historico_precio.tamano_tallo%type
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nombre catalogo_floris.nombre%type;
    hprecio historico_precio.precio_hist%type;
    fecha_inicial historico_precio.fecha_ini%type;
    floris_nombre floristeria.nombre%type;
    dias_vigencia INTEGER;
    v_count INTEGER;
BEGIN
    -- Verificar si existe un registro con los parámetros dados
    SELECT COUNT(*)
    INTO v_count
    FROM historico_precio h
    JOIN catalogo_floris cf ON cf.cf_id = h.cfID 
    JOIN floristeria f ON cf.cf_idFloristeria = f.id_floristeria
    WHERE 
        cf.cf_id = p_cfid 
        AND h.tamano_tallo = tallo;

    -- Si no se encuentra registro, enviar mensaje de error
    IF v_count = 0 THEN
        RAISE NOTICE 'No se encontró una flor con el ID % y tallo de %cm.', p_cfid, tallo;
        RETURN;
    END IF;

    -- Obtener los detalles del precio más reciente
    SELECT 
        cf.nombre, 
        h.precio_hist, 
        h.fecha_ini,
        f.nombre
    INTO 
        v_nombre, 
        hprecio, 
        fecha_inicial,
        floris_nombre
    FROM 
        catalogo_floris cf
    JOIN 
        historico_precio h ON cf.cf_id = h.cfID 
    JOIN 
        floristeria f ON cf.cf_idFloristeria = f.id_floristeria
    WHERE 
        cf.cf_id = p_cfid 
        AND h.fecha_fin IS NULL 
        AND h.tamano_tallo = tallo;

    -- Calcular los días de vigencia desde fecha_ini hasta hoy 
    dias_vigencia := CURRENT_DATE - DATE_TRUNC('day', fecha_inicial)::DATE;

    RAISE NOTICE '----------------------------------------------------------------------------';
    RAISE NOTICE '| FLORISTERIA: %', floris_nombre;
    RAISE NOTICE '----------------------------------------------------------------------------';
    RAISE NOTICE '| Flor: %, con un tallo de: %cm', v_nombre, tallo;
    RAISE NOTICE '----------------------------------------------------------------------------';
    RAISE NOTICE '| Precio actual es de %€', hprecio;
    RAISE NOTICE '----------------------------------------------------------------------------';
    RAISE NOTICE '| Precio vigente desde: % conlleva % días en vigencia', to_char(fecha_inicial, 'DD "de" FMMonth "de" YYYY'), dias_vigencia;
    RAISE NOTICE '----------------------------------------------------------------------------';
END;
$$;




----CERRAR UN PRECIO----

CREATE OR REPLACE FUNCTION cerrar_periodo_precio(
    p_id_floristeria NUMERIC,
    p_id_flor NUMERIC,
	tallo NUMERIC
) RETURNS VOID AS $$
DECLARE
    v_fecha_inicio DATE;
	v_nombre_floris VARCHAR;
	v_nombre_flor VARCHAR;
BEGIN
    -- Obtener la fecha de inicio del precio activo
    SELECT fecha_ini,f.nombre,cf.nombre INTO v_fecha_inicio,v_nombre_floris,v_nombre_flor
    FROM historico_precio h, floristeria f, catalogo_floris cf
    WHERE h.cf_floristeria = p_id_floristeria
	AND h.cf_floristeria = f.id_floristeria
	AND h.cfID = cf.cf_id
    AND h.cfID = p_id_flor
	AND h.tamano_tallo = tallo
    AND h.fecha_fin IS NULL; -- Solo precios activos

    -- Si no hay un precio activo, devolver sin hacer nada
    IF v_fecha_inicio IS NULL THEN
        RAISE NOTICE 'No existe registro previo';
    END IF;

    -- Verificar si el precio ha estado activo durante al menos 7 días
    IF (CURRENT_DATE - v_fecha_inicio) < 7 THEN
        RAISE EXCEPTION 'No se puede cerrar el periodo de precios para la flor % de la floristeria % porque ha estado activo menos de 7 días.',  v_nombre_flor,v_nombre_floris;
    END IF;

    -- Cerrar el precio activo
    UPDATE historico_precio
    SET fecha_fin = CURRENT_DATE
    WHERE cf_floristeria = p_id_floristeria
    AND cfID = p_id_flor
    AND fecha_fin IS NULL;

    RAISE NOTICE 'Periodo de precios cerrado correctamente para la flor % de la floristeria % con fecha fin: %', v_nombre_flor, v_nombre_floris, CURRENT_DATE;
	RAISE NOTICE 'con tallo de %cm ',tallo;
END;
$$ LANGUAGE plpgsql;
