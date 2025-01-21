-- ROLES AREA DE SUBASTA
CREATE ROLE gerente_subastas with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT INSERT,SELECT,UPDATE,DELETE ON
		subastadora, contrato,pagos_multas,detalle_contrato,
		factura_subasta,lote,afiliacion,productor,catalogo_pro
		to gerente_subastas;
COMMIT;
GRANT SELECT ON 
		catalogo_pro to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_afiliaciones to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_contrato_vbn to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_floristerias to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_productores to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_subastadoras to gerente_subastas;
COMMIT;
GRANT EXECUTE ON FUNCTION verificar_estatus_contratos to gerente_subastas;
COMMIT;

CREATE ROLE contratista with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT INSERT,SELECT,UPDATE,DELETE ON
		contrato,detalle_contrato,pagos_multas
		to contratista;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_productores to contratista;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_subastadoras to contratista; 
COMMIT;
GRANT EXECUTE ON FUNCTION verificar_estatus_contratos to contratista; 
COMMIT;
GRANT EXECUTE ON FUNCTION listar_catalogo_productor to contratista; 
COMMIT;

CREATE ROLE cajero_subasta with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT INSERT,SELECT,UPDATE,DELETE ON
		factura_subasta,lote
		to cajero_subasta;
COMMIT;
GRANT EXECUTE ON PROCEDURE establecer_factura_subasta to cajero_subasta;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_productores to cajero_subasta;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_subastadoras to cajero_subasta; 
COMMIT;
GRANT EXECUTE ON FUNCTION listar_afiliaciones to cajero_subasta;
COMMIT;
 
CREATE ROLE productor with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT INSERT,SELECT,UPDATE,DELETE ON
		productor,catalogo_pro
		to productor;
COMMIT;
GRANT SELECT ON flor_corte,contrato,detalle_contrato to productor;
COMMIT;
GRANT SELECT ON pagos_multas to productor;
COMMIT;

CREATE ROLE visor_productor with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;
GRANT SELECT ON catalogo_pro,contrato,detalle_contrato,pagos_multas to visor_productor;
COMMIT;

CREATE ROLE subastador with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;
GRANT SELECT ON subastadora,contrato,afiliacion to subastador;
COMMIT;

-- ROLES AREA DE FLORISTERIA
CREATE ROLE gerente_floristeria with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT SELECT, INSERT,UPDATE,DELETE ON
		floristeria,empleado,telefono,factura_compradora,cliente_nat,cliente_empresa,det_fact_comp,
		catalogo_floris,det_bouquet,historico_precio
		to gerente_floristeria;
COMMIT;
GRANT SELECT ON flor_corte,color,enlace,significado,factura_subasta,lote to gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE agregar_precio TO gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE ganancia_neta_mensual TO gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_flor_tallo_mes TO gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_precio_flor TO gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_precio_flortallo TO gerente_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE recomendacion TO gerente_floristeria;
COMMIT;

CREATE ROLE inventario with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT INSERT,SELECT,UPDATE,DELETE ON
		catalogo_floris,det_bouquet,historico_precio
		to inventario;
COMMIT;
GRANT SELECT ON flor_corte,color 
		to inventario;
COMMIT;
GRANT EXECUTE ON PROCEDURE agregar_precio to inventario;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_flor_tallo_mes to inventario;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_precio_flor to inventario;
COMMIT;
GRANT EXECUTE ON PROCEDURE historico_precio_flortallo to inventario;
COMMIT;

CREATE ROLE cajero_floristeria with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;

GRANT SELECT, INSERT,UPDATE,DELETE ON
		factura_compradora,det_fact_comp 
		to cajero_floristeria;
COMMIT;

GRANT SELECT ON catalogo_floris,det_bouquet, historico_precio
		to cajero_floristeria;
COMMIT;
GRANT INSERT, SELECT,UPDATE ON cliente_nat,cliente_empresa 
		to cajero_floristeria;
COMMIT;
GRANT EXECUTE ON PROCEDURE recomendacion to cajero_floristeria;
COMMIT;

CREATE ROLE cliente with
       nosuperuser
       nocreatedb
       noreplication;
COMMIT;
GRANT SELECT ON factura_compradora,det_fact_comp,floristeria, catalogo_floris, det_bouquet
			to cliente;
COMMIT;
GRANT EXECUTE ON FUNCTION listar_floristerias to cliente;
COMMIT;
GRANT EXECUTE ON PROCEDURE recomendacion to cliente;
COMMIT;

-- USUARIOS CREADOS
CREATE USER user_gerencia_subasta with encrypted password '1234';
grant gerente_subastas to user_gerencia_subasta;

CREATE USER user_caja_floristeria with encrypted password 'cajerofloris';
grant cajero_floristeria to user_caja_floristeria;

CREATE USER user_inventario with encrypted password 'almacen';
grant inventario to user_inventario;

CREATE USER user_cliente_cotidiano with encrypted password 'client';
grant cliente to user_cliente_cotidiano;

CREATE USER user_contratista with encrypted password 'contratos';
grant contratista to user_contratista;

CREATE USER user_caja_subasta with encrypted password 'cajerosubas';
grant cajero_subasta to user_caja_subasta;

CREATE USER user_productor with encrypted password 'produccion';
grant productor to user_productor;

CREATE USER user_visor_productor with encrypted password 'visor1';
grant visor_productor to user_visor_productor;

CREATE USER user_subastador with encrypted password 'subas1';
grant subastador to user_subastador;