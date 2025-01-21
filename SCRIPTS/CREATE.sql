BEGIN;

CREATE TABLE PAIS(
	id_pais numeric(3) PRIMARY KEY,
	nombre_pais VARCHAR(20) NOT NULL UNIQUE,
	continente VARCHAR(7) NOT NULL,

	CONSTRAINT continentes CHECK(continente IN('AMERICA','AFRICA','EUROPA',
												'ASIA','OCEANIA'))
);

CREATE TABLE SUBASTADORA(
	id_subastadora numeric(5) PRIMARY KEY,
	nombre_subas VARCHAR(40) NOT NULL UNIQUE,
	direccion_pppal VARCHAR(60) NOT NULL,
	sub_idPais numeric(3) NOT NULL,

	CONSTRAINT fk_pais_subastadora FOREIGN KEY (sub_idPais) REFERENCES PAIS(id_pais)
);

CREATE TABLE PRODUCTOR(
	id_productor numeric(5) PRIMARY KEY,
	nombre_productor VARCHAR(40) NOT NULL UNIQUE,
	pagina_web VARCHAR(60) NOT NULL UNIQUE,
	ubicacion_ppal VARCHAR(60) NOT NULL,
	pro_idPais numeric(3) NOT NULL,

	CONSTRAINT fk_pais_productor FOREIGN KEY (pro_idPais) REFERENCES PAIS(id_pais)
);

CREATE TABLE FLOR_CORTE(
	id_corte numeric(4) PRIMARY KEY,
	nombre_comun VARCHAR(30) NOT NULL UNIQUE,
	genero_especie VARCHAR(20) NOT NULL UNIQUE,
	etimologia VARCHAR(80) NOT NULL,
	colores VARCHAR(100) NOT NULL,
	temperatura varchar(60) NOT NULL
);

CREATE TABLE CATALOGO_PRO(
	cp_idPro NUMERIC(5) NOT NULL,
	codigo_vbn VARCHAR(12) NOT NULL,
	nombre_flor_pro VARCHAR(30) NOT NULL,
	logo_flor VARCHAR(255) NOT NULL,
	cp_idCorte numeric(4) NOT NULL,
	descripcion VARCHAR(100),

	CONSTRAINT pk_cp PRIMARY KEY(cp_idPro, codigo_vbn),
	CONSTRAINT fk_cp_productor FOREIGN KEY (cp_idPro) REFERENCES PRODUCTOR (id_productor),
	CONSTRAINT fk_cp_corte FOREIGN KEY (cp_idCorte) REFERENCES FLOR_CORTE(id_corte)
);

CREATE TABLE FLORISTERIA(
	id_floristeria numeric(4) PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL UNIQUE,
	correo VARCHAR(40) NOT NULL UNIQUE,
	idPais_floris NUMERIC(3) NOT NULL,
	direccion VARCHAR(60) NOT NULL
);

CREATE TABLE AFILIACION(
	afi_id_floristeria NUMERIC(4) NOT NULL,
	afi_id_subastadora NUMERIC(5) NOT NULL,

	CONSTRAINT pk_afiliacion PRIMARY KEY(afi_id_floristeria,afi_id_subastadora)
);

CREATE TABLE CONTRATO(
	idSubas NUMERIC(5) NOT NULL,
	idPro NUMERIC(5) NOT NULL,
	id_contrato NUMERIC(8) NOT NULL,
	fecha_ini DATE NOT NULL,
	clasificacion VARCHAR(2) NOT NULL,
	porcentaje NUMERIC(3) NOT NULL,
	cancelado BOOLEAN,
	id_renovaContrato NUMERIC(8),
	id_renovaSubas NUMERIC(5),
	id_renovaPro NUMERIC(5),

	CONSTRAINT pk_contrato PRIMARY KEY(idSubas,idPro,id_contrato),
	CONSTRAINT fk_cont_subastadora FOREIGN KEY (idSubas) REFERENCES SUBASTADORA(id_subastadora),
	CONSTRAINT fk_cont_productor FOREIGN KEY (idPro) REFERENCES PRODUCTOR (id_productor),
	CONSTRAINT ck_clasificacion CHECK (clasificacion IN('CA','CB','CC','CG','KA')),
	CONSTRAINT renovacion FOREIGN KEY (id_renovaContrato,id_renovaSubas,id_renovaPro) REFERENCES CONTRATO (id_contrato,idSubas,idPro)
);

CREATE TABLE PAGOS_MULTAS(
	pago_subas NUMERIC(5) NOT NULL,
	pago_pro NUMERIC(5) NOT NULL,
	pago_contrato NUMERIC(8) NOT NULL,
	id_pagos numeric(10) NOT NULL,
	tipo VARCHAR(10) NOT NULL,
	fecha_pagos DATE NOT NULL,
	monto NUMERIC(10,2) NOT NULL,

	CONSTRAINT pk_pagos PRIMARY KEY(pago_subas,pago_pro,pago_contrato,id_pagos),
	CONSTRAINT fk_conlleva FOREIGN KEY(pago_subas,pago_pro,pago_contrato) REFERENCES CONTRATO(idSubas,idPro,id_contrato),
	CONSTRAINT ck_tipo CHECK(tipo IN('MEMBRESIA','COMISION','MULTA'))
);

CREATE TABLE DETALLE_CONTRATO(
	--RELACION DE CONTRATO
	det_subas NUMERIC(5) NOT NULL,
	det_pro NUMERIC(5) NOT NULL,
	det_cont NUMERIC(8) NOT NULL,
	--RELACION DE CATALOGO_PRODUCTOR
	det_idPro NUMERIC(5) NOT NULL,
	det_vbn VARCHAR(12) NOT NULL,
	cantidad_anual NUMERIC(10) NOT NULL,

	CONSTRAINT pk_detalle_contrato PRIMARY KEY(det_subas,det_pro,det_cont,det_idPro,det_vbn),
	CONSTRAINT fk_otorga FOREIGN KEY (det_idPro,det_vbn) REFERENCES CATALOGO_PRO(cp_idPro, codigo_vbn),
	CONSTRAINT fk_posee FOREIGN KEY (det_subas,det_pro,det_cont)REFERENCES CONTRATO(idSubas,idPro,id_contrato)
);

CREATE TABLE FACTURA_SUBASTA(
	cod_fac_sub NUMERIC(10) PRIMARY KEY,
	fecha_factura DATE NOT NULL,
	precio_total NUMERIC(12,2) NOT NULL,
	envio boolean,
	afi_idFloris NUMERIC(4) NOT NULL,
	afi_idSubas NUMERIC(5) NOT NULL,

	CONSTRAINT fk_afiliado FOREIGN KEY(afi_idFloris,afi_idSubas)REFERENCES AFILIACION(afi_id_floristeria,afi_id_subastadora)
);

CREATE TABLE LOTE(
	--RELACION FACTURA
	lote_idFactura NUMERIC(10) NOT NULL,
	--RELACION DETALLE_CONTRATO
	lote_idSubas NUMERIC(5) NOT NULL,
	lote_idPro NUMERIC(5) NOT NULL,
	lote_idCont NUMERIC(8) NOT NULL,
	lote_idCPro NUMERIC(5) NOT NULL,
	lote_idCVBN VARCHAR(12) NOT NULL,
	--ATRIBUTOS DE LOTE
	numerolote NUMERIC(12) NOT NULL,
	cantidad_lote NUMERIC(8) NOT NULL,
	precio_final NUMERIC(10,2) NOT NULL,
	precio_inicial NUMERIC(10,2) NOT NULL,
	indice_bl NUMERIC(2,1) NOT NULL,

	CONSTRAINT pk_lote PRIMARY KEY(lote_idFactura,lote_idSubas,lote_idPro,lote_idCont,lote_idCPro,lote_idCVBN,numerolote),
	CONSTRAINT fk_factura FOREIGN KEY(lote_idFactura) REFERENCES FACTURA_SUBASTA(cod_fac_sub),
	CONSTRAINT fk_detalle FOREIGN KEY(lote_idSubas,lote_idPro,lote_idCont,lote_idCPro,lote_idCVBN) REFERENCES DETALLE_CONTRATO(det_subas,det_pro,det_cont,det_idPro,det_vbn),
	CONSTRAINT ck_indiceBL CHECK(indice_bl >=0.5 AND indice_bl<=1)
);

CREATE TABLE SIGNIFICADO(
	id_significado NUMERIC(3) PRIMARY KEY,
	tipo VARCHAR(12) NOT NULL,
	descripcion VARCHAR(100),

	CONSTRAINT ck_tipo CHECK(tipo IN('OCASION','SENTIMIENTO'))
);

CREATE TABLE COLOR(
	codigo_color VARCHAR(7) PRIMARY KEY,
	color VARCHAR(20) NOT NULL UNIQUE,
	descripcion  VARCHAR(80) NOT NULL
);

CREATE TABLE ENLACE(
	idSignificado NUMERIC(3) NOT NULL,
	id_enlace NUMERIC(3) NOT NULL,
	idCorte NUMERIC(4),
	idColorEnlace VARCHAR(7),

	CONSTRAINT pk_enlace PRIMARY KEY (idSignificado,id_enlace),
	CONSTRAINT fk_color FOREIGN KEY(idColorEnlace) REFERENCES COLOR(codigo_color),
	CONSTRAINT fk_florCorte FOREIGN KEY(idCorte) REFERENCES FLOR_CORTE(id_corte)
);

CREATE TABLE CATALOGO_FLORIS(
	cf_idFloristeria NUMERIC(4) NOT NULL,
	cf_id NUMERIC(8) NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	idFlorCorte NUMERIC(4) NOT NULL,
	idColor VARCHAR(7) NOT NULL,
	descripcion VARCHAR(100),

	CONSTRAINT pk_cf PRIMARY KEY(cf_idFloristeria,cf_id),
	CONSTRAINT fk_floris FOREIGN KEY(cf_idFloristeria) REFERENCES FLORISTERIA(id_floristeria),
	CONSTRAINT fk_cfCorte FOREIGN KEY(idFlorCorte) REFERENCES FLOR_CORTE(id_corte),
	CONSTRAINT fk_cfColor FOREIGN KEY(idColor) REFERENCES COLOR (codigo_color)
);

CREATE TABLE HISTORICO_PRECIO(
	cf_floristeria NUMERIC(4) NOT NULL,
	cfID NUMERIC(8) NOT NULL,
	fecha_ini TIMESTAMP NOT NULL,
	precio_hist NUMERIC(5,2),
	fecha_fin DATE,
	tamano_tallo NUMERIC(2),

	CONSTRAINT pk_hp PRIMARY KEY(cf_floristeria,cfID,fecha_ini),
	CONSTRAINT fk_precio_historico FOREIGN KEY(cf_floristeria,cfID) REFERENCES CATALOGO_FLORIS(cf_idFloristeria,cf_id)
);

CREATE TABLE DET_BOUQUET(
	idFloris NUMERIC(4) NOT NULL,
	cfID NUMERIC(8) NOT NULL,
	id_bouquet NUMERIC(6) NOT NULL,
	cantidad NUMERIC(3) NOT NULL,
	tallo_tamano NUMERIC(2),
	descripcion VARCHAR(100),

	CONSTRAINT pk_bouquet PRIMARY KEY(idFloris,cfID,id_bouquet),
	CONSTRAINT fk_bouquets FOREIGN KEY(idFloris,cfID) REFERENCES CATALOGO_FLORIS(cf_idFloristeria,cf_id)
);

CREATE TABLE CLIENTE_NAT(
	id_cliente_nat NUMERIC(6) PRIMARY KEY,
	doc_identidad VARCHAR(10) NOT NULL UNIQUE,
	p_nombre VARCHAR(20) NOT NULL,
	s_apellido VARCHAR(20) NOT NULL
);

CREATE TABLE CLIENTE_EMPRESA(
	id_empresa NUMERIC(6) PRIMARY KEY,
	nombre_empresa VARCHAR(20) NOT NULL
);

CREATE TABLE FACTURA_COMPRADORA(
	factura_idFloris NUMERIC(4) NOT NULL,
	codigo NUMERIC(10) NOT NULL,
	fecha_factura DATE NOT NULL,
	monto_total NUMERIC(12,2) NOT NULL,
	idCliente_nat NUMERIC(6),
	idCliente_emp NUMERIC(6),

	CONSTRAINT pk_factura_floris PRIMARY KEY(factura_idFloris,codigo),
	CONSTRAINT fk_factura_floris FOREIGN KEY(factura_idFloris) REFERENCES FLORISTERIA(id_floristeria),
	CONSTRAINT fk_clienteNat FOREIGN KEY(idCliente_nat) REFERENCES CLIENTE_NAT(id_cliente_nat),
	CONSTRAINT fk_clienteEmp FOREIGN KEY(idCliente_emp) REFERENCES CLIENTE_EMPRESA(id_empresa),
	CONSTRAINT ck_cliente CHECK((idCliente_nat IS NOT NULL AND idCliente_emp IS NULL) OR 
								(idCliente_nat IS NULL AND idCliente_emp IS NOT NULL))
);

CREATE TABLE DET_FACT_COMP(
	det_floris NUMERIC(4) NOT NULL,
	det_idFactura NUMERIC(10) NOT NULL,
	det_cod NUMERIC(10) NOT NULL,
	cantidad NUMERIC(3) NOT NULL,
	--RELACION CON CATALOGO_FLORISTERIA
	det_cfID NUMERIC(6),
	det_cfFloris NUMERIC(8),
	--RELACION CON DET_BOUQUET
	det_bouquet NUMERIC(6),
	det_bouFloris NUMERIC(4),
	det_bouCF NUMERIC(8),
	valor_calidad NUMERIC(2,1),
	valor_precio NUMERIC(2,1),
	valor_promedio NUMERIC(2,1),

	CONSTRAINT pk_detalle_compradora PRIMARY KEY(det_floris,det_idFactura,det_cod),
	CONSTRAINT fk_factura_compradora FOREIGN KEY(det_floris,det_idFactura) REFERENCES FACTURA_COMPRADORA(factura_idFloris,codigo),
	CONSTRAINT fk_flor_unica FOREIGN KEY(det_cfFloris,det_cfID) REFERENCES CATALOGO_FLORIS(cf_idFloristeria,cf_id),
	CONSTRAINT fk_flor_bouquet FOREIGN KEY(det_bouquet,det_bouFloris,det_bouCF) REFERENCES DET_BOUQUET(id_bouquet,idFloris,cfID),
	CONSTRAINT ck_compradora CHECK(
    ((det_cfID IS NOT NULL AND det_cfFloris IS NOT NULL) AND 
     (det_bouquet IS NULL AND det_bouFloris IS NULL AND det_bouCF IS NULL)) OR 
    ((det_cfID IS NULL AND det_cfFloris IS NULL) AND 
     (det_bouquet IS NOT NULL AND det_bouFloris IS NOT NULL AND det_bouCF IS NOT NULL))
)
);

CREATE TABLE EMPLEADO(
  emp_idFloris NUMERIC(4) NOT NULL,
  id_emp NUMERIC(4) NOT NULL,
  doc_identidad VARCHAR(10) NOT NULL UNIQUE,
  p_nombre VARCHAR(25) NOT NULL,
  p_apellido VARCHAR(25),
  s_nombre VARCHAR(25),
  s_apellido VARCHAR(25),

  CONSTRAINT pk_empleado PRIMARY KEY(emp_idFloris,id_emp),
  CONSTRAINT fk_emplea FOREIGN KEY(emp_idFloris) REFERENCES FLORISTERIA(id_floristeria)
);

CREATE TABLE TELEFONO(
	cod_tel NUMERIC(6) NOT NULL,
	cod_area VARCHAR(3) NOT NULL,
	num_telefonico VARCHAR(12) NOT NULL,
	tipo VARCHAR(5) NOT NULL,
	tel_idFloris NUMERIC(4) NOT NULL,

	CONSTRAINT pk_telefono PRIMARY KEY(cod_tel,cod_area,num_telefonico),
	CONSTRAINT fk_telefono FOREIGN KEY(tel_idFloris) REFERENCES FLORISTERIA(id_floristeria),
	CONSTRAINT ck_tipo_tel CHECK(tipo IN('FIJO','MOVIL'))
);

COMMIT;

BEGIN;
CREATE SEQUENCE secuencia_contrato
    INCREMENT BY 1       -- Incremento de 1
    MINVALUE 1           -- Valor mínimo de 1
    START WITH 1         -- Comienza desde 1
    NO CYCLE;            -- No repetir los números una vez alcanzado el máximo

COMMIT;

BEGIN;
CREATE SEQUENCE secuencia_facturas
    INCREMENT BY 1       -- Incremento de 1
    MINVALUE 1           -- Valor mínimo de 1
    START WITH 1         -- Comienza desde 1
    NO CYCLE;            -- No repetir los números una vez alcanzado el máximo

COMMIT;

BEGIN;
CREATE SEQUENCE secuencia_lote
    INCREMENT BY 1       -- Incremento de 1
    MINVALUE 1           -- Valor mínimo de 1
    START WITH 1         -- Comienza desde 1
    NO CYCLE;            -- No repetir los números una vez alcanzado el máximo

COMMIT;

BEGIN;
CREATE SEQUENCE secuencia_pagos
    INCREMENT BY 1       -- Incremento de 1
    MINVALUE 1           -- Valor mínimo de 1
    START WITH 1         -- Comienza desde 1
    NO CYCLE;            -- No repetir los números una vez alcanzado el máximo

COMMIT

BEGIN;
CREATE SEQUENCE secuencia_general
    INCREMENT BY 1       -- Incremento de 1
    MINVALUE 1           -- Valor mínimo de 1
    START WITH 1         -- Comienza desde 1
    NO CYCLE;            -- No repetir los números una vez alcanzado el máximo

COMMIT;