--==============================================================================================================
--  Caetano Traina Júnior -- maio de 2021 ------------ =========================================================
-- Prepara as tabelas de dados COVID19 para hospitais: esquema publico                                        ==
-- tempo aproximado: 150 ms.                                                                                  ==
--------------------------------------------------------------------------------------------------------------==

DROP TABLE IF EXISTS Public.Pacientes CASCADE;
CREATE TABLE Public.Pacientes(
	ID_Paciente TEXT,   --  PRIMARY KEY,
	IC_Sexo CHAR,
	AA_Nasc CHAR(4),   -- deveria ser INT ???,
	CD_Pais TEXT,
	CD_UF CHAR(2),
	CD_Municipio TEXT,
	CD_Distrito TEXT
);

DROP TABLE IF EXISTS Public.ExamLabs CASCADE;
CREATE TABLE Public.ExamLabs(
	ID_Paciente TEXT,
	ID_Atendimento TEXT,
	DT_Coleta DATE,
	DE_Origem TEXT,
	DE_Exame TEXT,
	DE_Analito TEXT,
	DE_Resultado TEXT,
	CD_Unidade TEXT,
	CD_ValorReferencia TEXT
	-- FOREIGN KEY (id_paciente) 
	--     REFERENCES pacientes(id_paciente) 
	--     ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS Public.Desfechos CASCADE;
CREATE TABLE Public.Desfechos(
	ID_Paciente TEXT,
	ID_Atendimento TEXT,
	DT_Atendimento DATE,
	DE_TipoAtendimento TEXT,
	ID_Clinica INT,
	DE_Clinica TEXT,
	DT_Desfecho TEXT,  -- deveria ser DATE???
	DE_Desfecho TEXT
	-- PRIMARY KEY (id_paciente, id_atendimento),
	-- FOREIGN KEY (id_paciente) 
	--     REFERENCES pacientes(id_paciente)
	--     ON UPDATE CASCADE ON DELETE CASCADE
);

--===========================================================================
CREATE OR REPLACE FUNCTION Public.LoadZIPFile (Prog TEXT, ZipF TEXT, FP TEXT, Tab TEXT) 
    RETURNS INT AS $$
  DECLARE
    CMDZIP Text; CMD Text;
	Tot INT:=0;
  BEGIN
    RAISE NOTICE 'Carregando %', Tab;
    CMD:='"'||Prog||'" e -so "'||ZipF||'" ';
    IF FP IS NOT NULL THEN
	    CMD='COPY '||Tab||' FROM program '''||CMD||FP||'''
    	WITH (DELIMITER ''|'', NULL '''', ENCODING ''UTF8'', HEADER true, FORMAT CSV)';
        EXECUTE CMD;
		CMD:=Substring(Tab, '(.+)\(.'); 
		IF CMD IS NULL THEN CMD:=Tab; END IF;
        CMD:='SELECT COUNT(*) FROM '|| CMD;
        EXECUTE CMD INTO Tot;
        RAISE NOTICE 'Carregada Tabela %:= %', Tab, Tot;
		END IF;
	RETURN Tot;
    END;
$$  LANGUAGE plpgsql VOLATILE RETURNS NULL ON NULL INPUT;

