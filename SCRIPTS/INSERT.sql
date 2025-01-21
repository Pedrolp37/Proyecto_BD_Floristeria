BEGIN;
INSERT INTO pais (id_pais, nombre_pais, continente) VALUES
(3, 'Paises Bajos', 'EUROPA'),
(4, 'Estados Unidos', 'AMERICA'),
(5, 'Colombia', 'AMERICA'),
(6, 'Ecuador', 'AMERICA'),
(7, 'España', 'EUROPA'),
(35, 'Italia', 'EUROPA'),
(36, 'Francia', 'EUROPA');
COMMIT;

begin;
 INSERT INTO subastadora (id_subastadora,nombre_subas,direccion_pppal,sub_idpais)VALUES 
 (1,'Verenigde Bloemenveiling Nederland','paises bajos',3),
 (2,'Aalsmeer Flower Auction','paises bajos',3),
 (3,'Royal Flora Holland Naaldwijk','paises bajos',3);
commit;

begin;
INSERT INTO flor_corte (id_corte,nombre_comun,genero_especie,etimologia,colores,temperatura)
VALUES
--Gladyflor
(1,'Orquidea','Orchidaceae','Del griego "orchis" (testículo) debido a la forma de sus raíces','blanco, amarillo, rojo, rosa, púrpura, azul','entre 18°C y 24°C durante el día'),
(2,'Clavel','Dianthus','Del griego "dios" y "flor"','Blanco,rosa,rojo,purpura','Entre 15°C y 25°C'),
(3,'Lirio','Lilium','Del latín "lilium"','Blanco, amarillo, naranja, rosa, rojo','Entre 15°C y 25°C'),
-- Dummen
(4,'Rosa','Rosa','Del latin "Rosa"','Blanco,rosado,rojo,morado','Entre 15°C y 25°C'),
(5,'Gerbera','Gerbera','En honor a Traugott Gerber, un amigo de Carlos Linneo','Blanco, amarillo, naranja, rojo, morado, azul','Entre 15°C y 25°C'),
(6,'Crisantemo','Chrysanthemum','Del griego "chrysos" (oro) y "anthemos" (flor)','Blanco, amarillo, rosa, púrpura, rojo, anaranjado','Entre 10°C y 20°C'),
- Ballseed
(7,'Escabiosa','Scabiosa','Del latín "scabiosus" (áspero, árido)','Blanco, rosa, lavanda, púrpura, azul','Entre 15°C y 25°C'),
(8,'Geranio','Geranium','Del griego "geranion" (grulla)','Blanco, rosa, rojo, morado, azul','Entre 15°C y 20°C'),
(9,'Flor de nube','Gypsophila','Del griego "gypsos" (yeso) y "philos" (amigo)','Blanco,rosa','Entre 15°C y 25°C');
commit;

BEGIN;
INSERT INTO productor (id_productor, nombre_productor, pagina_web, ubicacion_ppal, pro_idpais) VALUES
(14, 'Gradyflor', 'www.gradyflor.com/es/catalogo/catalogo-flor', 'Calle mar báltico, 16, 28830 San Fernando de Henares, Madrid', 7),
(15, 'Dummen Orange', 'https://latam.dummenorange.com/site/en', 'Carrera 49B # 106A-33, Bogotá D.C.', 5),
(16, 'Ballseed', 'www.ballseed.com', '622 Town Road, West Chicago, Illinois 60185', 4);
COMMIT;

Begin;
INSERT INTO catalogo_pro (cp_idpro,codigo_vbn,nombre_flor_pro,logo_flor,cp_idcorte,descripcion)
VALUES
-- Para gladyflor son orquidea, clavel y rosa
(14,'654321','Dendrobrium','/images/dendro',26,'flor de corte dendrobium'),
(14,'823456','Mojito','/images/mojito',27,'Flor de color de la bebida'),
(14,'735928','Oriental Rosa','/images/oriental',28,'lirio'),
-- 15 es dummen orange
(15,'774980','Garota','/images/garota',29,'rosa anaranjada'),
(15,'530710','Alcatraz','/images/alcatraz',30,'gerbera llamada alcolea'),
(15,'666920','Dotan','/images/dotan',31,'color rosa para decoracion'),
--16 BallSeed
(16,'467839','Caucasia Deep Blue','/images/scacaucasia',32,'grandes con tallos fuertes y hojas verdes y texturizadas'),
(16,'578432','cantabrigiense Biokovo','/images/biokovo',33,' en forma de montículo produce numerosas flores blancas con un rubor rosado y venas'),
(16,'694725','XLence','/images/XLence',34,'excepcionalmente grande, de color blanco brillante puro');
commit;

begin;
INSERT INTO color (codigo_color, color, descripcion) VALUES
('FF0000', 'Rojo', 'Un color vibrante que simboliza pasión, amor y energía.'),
('0000FF', 'Azul', 'Un color calmante que simboliza tranquilidad y confianza.'),
('00FF00', 'Verde', 'Un color refrescante que simboliza crecimiento y naturaleza.'),
('FFFF00', 'Amarillo', 'Un color brillante que simboliza felicidad y optimismo.'),
('FF5733', 'Rojo Anaranjado', 'Este color vibrante y cálido evoca sensaciones de energía y entusiasmo.'),
('33FF57', 'Verde Lima', 'Un tono fresco y revitalizante que simboliza crecimiento y renovación.'),
('3357FF', 'Azul Eléctrico', 'Un azul brillante y audaz que transmite dinamismo y modernidad.'),
('FF33A8', 'Rosa Fucsia', 'Un rosa intenso y juguetón que sugiere creatividad y diversión.'),
('FFD700', 'Dorado', 'Este color dorado resplandeciente simboliza riqueza y lujo.'),
('8A2BE2', 'Azul Violeta', 'Un azul profundo con matices púrpura que evoca misterio y sofisticación.'),
('FF4500', 'Naranja Ardiente', 'Un naranja intenso que representa pasión y entusiasmo.'),
('2E8B57', 'Verde Marino', 'Un verde oscuro que refleja tranquilidad y conexión con la naturaleza.'),
('800000', 'Marrón', 'Un color terroso que simboliza estabilidad y calidez.'),
('FFFFFF', 'Blanco', 'Un color puro que simboliza limpieza y simplicidad.'),
('808080', 'Gris', 'Un tono neutral que denota equilibrio y sofisticación.');
commit;

begin;
 INSERT INTO floristeria(id_floristeria,nombre,correo,idpais_floris,direccion) VALUES
(1,'Italian Flora','info@floraitaliana.com',35,'Via Leonidion, 5 (Sur de italia)'),
(2,'Flower Market','order@myglobalflowers.es',36,'Paris'),
(3,'FlorAccess','floraccess@gmail.com',3,'Amnsterdam'),
(4,'Fresh shelf','hello@fresh-shelf.com',6,'Quito'),
(5,'Floreloy','gerencia@floreloy.com',5,'Bogota'),
(,'Viveros Projadrin','clientes@viverosprojardin.com',7,'Av Mostoles, Alcorcon');
commit;

begin;
INSERT INTO CLIENTE_NAT (id_cliente_nat, doc_identidad, p_nombre, s_apellido) VALUES
(101, 'V12345678', 'Carlos', 'Martínez'),
(102, 'V87654321', 'Ana', 'Pérez'),
(103, 'V23456789', 'María', 'González'),
(104, 'V98765432', 'Luis', 'Rodríguez'),
(105, 'V34567890', 'José', 'Fernández'),
(106, 'V45678901', 'Laura', 'Hernández'),
(107, 'V56789012', 'Pedro', 'López'),
(108, 'V67890123', 'Marta', 'Díaz'),
(109, 'V78901234', 'Jorge', 'García');
commit;

begin;
INSERT INTO CLIENTE_EMPRESA (id_empresa, nombre_empresa) VALUES
(201, 'Tech Solutions'),
(202, 'Global Industries'),
(203, 'EcoFriendly Ltd.'),
(204, 'HealthCare Inc.'),
(205, 'FinTech Innovations'),
(206, 'TravelExperts'),
(207, 'EduTech'),
(208, 'AutoMotive Co.'),
(209, 'AgroWorld');
commit;

begin;
INSERT INTO FACTURA_COMPRADORA (factura_idFloris, codigo, fecha_factura, monto_total, idCliente_nat, idCliente_emp) VALUES
(37, 1001, '2024-12-01', 12.50, 101, NULL),
(37, 1002, '2024-12-02', 20.00, NULL, 201),
(39, 2001, '2024-12-01', 15.75, 102, NULL),
(39, 2002, '2024-12-03', 18.00, NULL, 202),
(40, 3001, '2024-12-01', 22.50, 103, NULL),
(41, 4001, '2024-12-04', 10.00, NULL, 203),
(41, 4002, '2024-12-05', 13.50, 104, NULL),
(43, 5001, '2024-12-06', 16.25, NULL, 204),
(44, 6001, '2024-12-07', 19.50, 105, NULL);

INSERT INTO DET_FACT_COMP (det_floris, det_idFactura, det_cod, cantidad, det_cfID, det_cfFloris, det_bouquet, det_bouFloris, det_bouCF, valor_calidad, valor_precio, valor_promedio) VALUES
(37, 1001, 1, 10, 46, 37, NULL, NULL, NULL, 4.0, 4.5, 4.2),
(37, 1002, 2, 15, 46, 37, NULL, NULL, NULL, 4.2, 4.7, 4.4),
(39, 2001, 3, 12, 48, 39, NULL, NULL, NULL, 3.8, 4.2, 4.0),
(39, 2002, 4, 14, 48, 39, NULL, NULL, NULL, 3.9, 4.3, 4.1),
(40, 3001, 5, 20, 49, 40, NULL, NULL, NULL, 4.1, 4.6, 4.3),
(41, 4001, 6, 8, 50, 41, NULL, NULL, NULL, 3.5, 4.0, 3.8),
(41, 4002, 7, 10, 51, 41, NULL, NULL, NULL, 3.6, 4.1, 3.9),
(43, 5001, 8, 11, 53, 43, NULL, NULL, NULL, 4.0, 4.5, 4.2),
(44, 6001, 9, 13, 54, 44, NULL, NULL, NULL, 4.2, 4.7, 4.4);
commit;

begin;
INSERT INTO AFILIACION (afi_id_floristeria, afi_id_subastadora)
VALUES
    (37, 1), (37, 2), -- FlorAccess afiliada a Verenigde Bloemenveiling Nederland y Aalsmeer Flower Auction
    (39, 1), (39, 3), -- Fresh shelf afiliada a Verenigde Bloemenveiling Nederland y Royal Flora Holland Naaldwijk
    (40, 2), (40, 3), -- Floreloy afiliada a Aalsmeer Flower Auction y Royal Flora Holland Naaldwijk
    (41, 1), (41, 2), -- Viveros Projadrin afiliada a Verenigde Bloemenveiling Nederland y Aalsmeer Flower Auction
    (43, 2), (43, 3), -- Italian Flora afiliada a Aalsmeer Flower Auction y Royal Flora Holland Naaldwijk
    (44, 1), (44, 3); -- Flower Market afiliada a Verenigde Bloemenveiling Nederland y Royal Flora Holland Naaldwijk

commit;

BEGIN;
-- Significados para OCASION
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (1, 'OCASION', 'Cumpleaños');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (2, 'OCASION', 'Boda');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (3, 'OCASION', 'Aniversario');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (4, 'OCASION', 'Graduación');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (5, 'OCASION', 'Día de la Madre');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (6, 'OCASION', 'Día del Padre');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (7, 'OCASION', 'San Valentín');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (8, 'OCASION', 'Navidad');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (9, 'OCASION', 'Fiesta de Jubilación');

-- Significados para SENTIMIENTO
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (10, 'SENTIMIENTO', 'Amor');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (11, 'SENTIMIENTO', 'Amistad');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (12, 'SENTIMIENTO', 'Alegría');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (13, 'SENTIMIENTO', 'Tristeza');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (14, 'SENTIMIENTO', 'Gratitud');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (15, 'SENTIMIENTO', 'Esperanza');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (16, 'SENTIMIENTO', 'Admiración');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (17, 'SENTIMIENTO', 'Perdón');
INSERT INTO SIGNIFICADO (id_significado, tipo, descripcion) VALUES (18, 'SENTIMIENTO', 'Felicidad');

COMMIT;

BEGIN;
-- Enlaces para Orquídea
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (1, 1, 26, NULL); -- Orquídea para Bodas
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (10, 2, 26, NULL); -- Orquídea para Amor

-- Enlaces para Clavel
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (2, 3, 27, NULL); -- Clavel para Aniversario
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (11, 4, 27, NULL); -- Clavel para Amistad

-- Enlaces para Lirio
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (3, 5, 28, NULL); -- Lirio para Graduación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (12, 6, 28, NULL); -- Lirio para Alegría

-- Enlaces para Rosa
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (4, 7, 29, NULL); -- Rosa para San Valentín
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (13, 8, 29, NULL); -- Rosa para Tristeza

-- Enlaces para Gerbera
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (5, 9, 30, NULL); -- Gerbera para Día de la Madre
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (14, 10, 30, NULL); -- Gerbera para Gratitud

-- Enlaces para Crisantemo
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (6, 11, 31, NULL); -- Crisantemo para Día del Padre
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (15, 12, 31, NULL); -- Crisantemo para Esperanza

-- Enlaces para Escabiosa
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (7, 13, 32, NULL); -- Escabiosa para Navidad
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (16, 14, 32, NULL); -- Escabiosa para Admiración

-- Enlaces para Geranio
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (8, 15, 33, NULL); -- Geranio para Fiesta de Jubilación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (17, 16, 33, NULL); -- Geranio para Perdón

-- Enlaces para Flor de Nube
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (9, 17, 34, NULL); -- Flor de Nube para Fiesta de Jubilación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (18, 18, 34, NULL); -- Flor de Nube para Felicidad

-- Enlaces para Rojo
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (1, 19, NULL, 'FF0000'); -- Rojo para Bodas
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (10, 20, NULL, 'FF0000'); -- Rojo para Amor

-- Enlaces para Azul
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (2, 21, NULL, '0000FF'); -- Azul para Aniversario
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (11, 22, NULL, '0000FF'); -- Azul para Amistad

-- Enlaces para Amarillo
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (3, 23, NULL, 'FFFF00'); -- Amarillo para Graduación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (12, 24, NULL, 'FFFF00'); -- Amarillo para Alegría

-- Enlaces para Rosa Fucsia
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (4, 25, NULL, 'FF33A8'); -- Rosa Fucsia para San Valentín
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (13, 26, NULL, 'FF33A8'); -- Rosa Fucsia para Tristeza

-- Enlaces para Verde Lima
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (5, 27, NULL, '33FF57'); -- Verde Lima para Día de la Madre
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (14, 28, NULL, '33FF57'); -- Verde Lima para Gratitud

-- Enlaces para Naranja Ardiente
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (6, 29, NULL, 'FF4500'); -- Naranja Ardiente para Día del Padre
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (15, 30, NULL, 'FF4500'); -- Naranja Ardiente para Esperanza

-- Enlaces para Azul Violeta
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (7, 31, NULL, '8A2BE2'); -- Azul Violeta para Navidad
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (16, 32, NULL, '8A2BE2'); -- Azul Violeta para Admiración

-- Enlaces para Blanco
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (8, 33, NULL, 'FFFFFF'); -- Blanco para Fiesta de Jubilación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (17, 34, NULL, 'FFFFFF'); -- Blanco para Perdón

-- Enlaces para Dorado
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (9, 35, NULL, 'FFD700'); -- Dorado para Fiesta de Jubilación
INSERT INTO ENLACE (idSignificado, id_enlace, idCorte, idColorEnlace) VALUES (18, 36, NULL, 'FFD700'); -- Dorado para Felicidad

COMMIT;

BEGIN;

INSERT INTO DET_BOUQUET (idFloris, cfID, id_bouquet, cantidad, tallo_tamano, descripcion) VALUES
(37, 46, nextval('secuencia_general'), 10, 12, 'Bouquet primaveral con Rosa PIIA'),
(39, 48, nextval('secuencia_general'), 15, 10, 'Bouquet de otoño con Excellence Inc'),
(40, 49, nextval('secuencia_general'), 12, 14, 'Bouquet vibrante con Rock Star'),
(41, 50, nextval('secuencia_general'), 8, 10, 'Bouquet perenne con Clavelina'),
(41, 51, nextval('secuencia_general'), 20, 12, 'Bouquet llamativo con Azucena'),
(41, 51, nextval('secuencia_general'), 14, 8, 'Bouquet llamativo con Azucena'),
(41, 52, nextval('secuencia_general'), 25, 11, 'Bouquet colorido con Margarita Africana'),
(43, 53, nextval('secuencia_general'), 10, 15, 'Bouquet elegante con Orquidea Amarilla'),
(44, 54, nextval('secuencia_general'), 18, 13, 'Bouquet tierno con Beso al Aire');
COMMIT;