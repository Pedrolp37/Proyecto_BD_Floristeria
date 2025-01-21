-- TRIGGERS
-- TRIGGER antes de insertar un nuevo contrato que verifica si el productor tiene un contrato 
-- vigente 
CREATE OR REPLACE FUNCTION verificar_contrato_establecido() RETURNS TRIGGER AS $$
DECLARE
    contrato_existente RECORD;
BEGIN
    RAISE NOTICE 'Verificando contrato para idpro=%', NEW.idpro;

    -- Buscar un contrato con el mismo idpro, clasificacion diferente de 'CG' y que no esté cancelado
    SELECT *
    INTO contrato_existente
    FROM contrato
    WHERE idpro = NEW.idpro AND cancelado = FALSE AND clasificacion != 'CG'
    LIMIT 1;

    IF contrato_existente IS NULL THEN
		  -- Permitir la inserción del nuevo contrato
    RETURN NEW;
	ELSE
		 RAISE EXCEPTION 'Ya existe un contrato vigente: idpro=%, idsubas=%, id_contrato=%, fecha_ini=%, clasificacion=%, cancelado=%', 
            contrato_existente.idpro, contrato_existente.idsubas, contrato_existente.id_contrato, 
            contrato_existente.fecha_ini, contrato_existente.clasificacion, contrato_existente.cancelado;
    END IF;

  
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER control_ingreso_contrato
BEFORE INSERT ON contrato
FOR EACH ROW
EXECUTE FUNCTION verificar_contrato_establecido();
