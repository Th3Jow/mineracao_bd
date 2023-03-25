--==============================================================================================================
--  Caetano Traina Júnior -- maio de 2021 ------------ =========================================================
--  Criar um ESQUEMA para cada hospital, um para todos e um para apenas 2 hospitais                           ==
-- tempo aproximado: 17 Min.                                                                                  ==
/*------------------------------------------------------------------------------------------------------------==
AS tabelas são obtidas do site do repositório USP-Fapesp Dataset Covid-19:
https://repositoriodatasharingfapesp.uspdigital.usp.br/handle/item/1
Não é necessário descompactar os arquivos de cada hospital.
ATENÇÃO: Os dados devem ser obtidos individualmente, diretamente do site fa FAPESP,
         atendendo aos requisitos de direito de uso indicados no site.

Este script permite ler as 3 tabelas (paciente, exame e desfecho) de cada hospital, cada hospital no seu 
respectivo ESQUEMA: HSL HFL HEI HCSP BPSP.
Antes de executar este script, é necessário que as 3 tabelas já estejam declaradas: 
    Rodar antes COVID19_Define-21-02.sql (versão fevereiro 2021)
-  Para um hospital ser carregado, o local onde o arquivo (.zip) correspondente está armazenado deve estar 
   indicado na variável FilePath*.
- A seguir, os hositais são integrados dois outros esquemas: TODOS e D2. Esses esquemas são criados 
   se a variável Cria contiver: T cria TODOS, 2 Cria D2.
- Os hospitais a serem incluídos em D2 devem estar indicados na variável Hosp
- Se desejado, os esquemas de cada hospital pode ser apagado manualmente depois.
*/
--==============================================================================================================
DO $$ DECLARE ZipPath TEXT; Cria TEXT; Hosp2 TEXT;
    FilePathHSL TEXT; FilePathHFL TEXT; FilePathHEI TEXT; FilePathHCSP TEXT; FilePathBPSP TEXT; 

-- Editar para indicar os parâmetros necessários: VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
BEGIN
-- Inicializar as variáveis de controle:
-- DEVEM ser declarados os endereços (path) do aplicativo 7ZIP para extração dos arquivos compactados, 
--      e os endereços dos arquivos com os dados fontes dos vários hospitais.
-- COMENTAR os paths dos hopitais que não devem ser carregados.
    ZipPath:=     '/usr/bin/7z';  -- NÃO COMENTAR --
	FilePathHSL:= 'path-do-repo/Covid19/HSL_Junho2021.zip';
	FilePathHFL:= 'path-do-repo/Covid19/GrupoFleury_Junho2021.zip';
	FilePathHEI:= 'path-do-repo/Covid19/EINSTEINAgosto.zip';
	FilePathHCSP:='path-do-repo/Covid19/HC_Janeiro2021.zip';
	FilePathBPSP:='path-do-repo/Covid19/BPSP.zip';
    Cria:='T2';  -- Inclui 'T' se deve criar Schema TODOS, Inclui '2' se deve criar Schema de 2 hospitais
	Hosp2:='HSL BPSP';
-- Editar só até aqui. AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

--==============================================================================================================
--==============================================================================================================
    IF Cria~'T' THEN 
        DROP SCHEMA IF EXISTS TODOS CASCADE; CREATE SCHEMA TODOS; -- Todos integrados
        CREATE TABLE TODOS.Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE TODOS.ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        CREATE TABLE TODOS.Desfechos AS TABLE Public.Desfechos WITH NO DATA;
        ALTER TABLE TODOS.Pacientes ADD COLUMN DE_Hospital TEXT;
        ALTER TABLE TODOS.ExamLabs ADD COLUMN DE_Hospital TEXT;
        ALTER TABLE TODOS.Desfechos ADD COLUMN DE_Hospital TEXT;
    	END IF;

    IF Cria~'2' THEN 
        DROP SCHEMA IF EXISTS D2    CASCADE; CREATE SCHEMA D2;    -- HSL + HCSP
        CREATE TABLE D2.Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE D2.ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        CREATE TABLE D2.Desfechos AS TABLE Public.Desfechos WITH NO DATA;
        ALTER TABLE D2.Pacientes ADD COLUMN DE_Hospital TEXT;
        ALTER TABLE D2.ExamLabs ADD COLUMN DE_Hospital TEXT;
        ALTER TABLE D2.Desfechos ADD COLUMN DE_Hospital TEXT;
    	END IF;

-- Criar e carregar as tabelas de cada hospital ==========================================================
--      Copia em ~6 min.
-- Campos estão separados pelo caractere pipe - “|” (ascii 124). 
-- Character set: UTF-8
SET datestyle to DMY, ISO;
--SET Client_encoding TO 'Latin1';
--SET Client_encoding TO 'UTF8';

-- Carrega dados Hospital Sírio-Libanês: HSL --------------------------------------------------
-----------------------------------------------------------------------------------
    IF FilePathHSL IS NOT NULL THEN
        DROP SCHEMA IF EXISTS HSL   CASCADE; CREATE SCHEMA HSL;   -- Sírio-Libanês 
        RAISE NOTICE 'Carregando dados de HSL';
        SET search_path = HSL, public;
        CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        CREATE TABLE Desfechos AS TABLE Public.Desfechos WITH NO DATA;
        PERFORM LoadZIPFile(ZipPath, FilePathHSL, 'HSL_Pacientes_4.csv'::TEXT, 'Pacientes'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathHSL, 'HSL_Exames_4.csv'::TEXT,    'ExamLabs'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathHSL, 'HSL_Desfechos_4.csv'::TEXT, 'Desfechos'::TEXT);
        ANALYSE Pacientes, ExamLabs, Desfechos;
    END IF;

-- Carrega dados Hospital Fleury: HFL  --------------------------------------------------------
    IF FilePathHFL IS NOT NULL THEN
        DROP SCHEMA IF EXISTS HFL   CASCADE; CREATE SCHEMA HFL;   -- Fleury 
        RAISE NOTICE 'Carregando dados de HFL';
        SET search_path = HFL, public;
        CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        PERFORM LoadZIPFile(ZipPath, FilePathHFL, 'GrupoFleury_Pacientes_4.csv'::TEXT, 'Pacientes'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathHFL, 'GrupoFleury_Exames_4.csv'::TEXT,    'ExamLabs'::TEXT);
        --PERFORM LoadZIPFile(ZipPath, FilePathHFL, 'HSL_Desfechos_3.csv'::TEXT, 'Desfechos'::TEXT);
        ANALYSE Pacientes, ExamLabs;
    END IF;
        
-- Carrega dados Hospital Einstein: HEI -------------------------------------------------------
    IF FilePathHEI IS NOT NULL THEN
        DROP SCHEMA IF EXISTS HEI   CASCADE; CREATE SCHEMA HEI;   -- Einstein 
        RAISE NOTICE 'Carregando dados de HEI';
        SET search_path = HEI, public;
        CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        PERFORM LoadZIPFile(ZipPath, FilePathHEI, 'EINSTEIN_Pacientes_2.csv'::TEXT, 'Pacientes(ID_Paciente, IC_Sexo, AA_Nasc, CD_UF, CD_Municipio, CD_Distrito, CD_Pais)'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathHEI, 'EINSTEIN_Exames_2.csv'::TEXT,    'ExamLabs(ID_Paciente, DT_Coleta, DE_Origem, DE_Exame, DE_Analito, DE_Resultado, CD_Unidade, CD_ValorReferencia)'::TEXT);
        -- PERFORM LoadZIPFile(ZipPath, FilePathHEI, 'HSL_Desfechos_3.csv'::TEXT, 'Desfechos'::TEXT);
        ANALYSE Pacientes, ExamLabs;
    END IF;
        
-- Carrega dados Hospital das Clínicas-SP: HCSP -------------------------------------------------
    IF FilePathHCSP IS NOT NULL THEN
        DROP SCHEMA IF EXISTS HCSP    CASCADE; CREATE SCHEMA HCSP;    -- HC SP
        RAISE NOTICE 'Carregando dados de HCSP';
        SET search_path = HCSP, public;
        CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        PERFORM LoadZIPFile(ZipPath, FilePathHCSP, 'HC_Pacientes_1.csv'::TEXT, 'Pacientes'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathHCSP, 'HC_Exames_1.csv'::TEXT,    'ExamLabs'::TEXT);
        -- PERFORM LoadZIPFile(ZipPath, FilePathHCSP, 'HSL_Desfechos_3.csv'::TEXT, 'Desfechos'::TEXT);
        ANALYSE Pacientes, ExamLabs;
    END IF;
        
-- Carrega dados Hospital Beneficencia Portuguesa ---------------------------------------------
    IF FilePathBPSP IS NOT NULL THEN
        DROP SCHEMA IF EXISTS BPSP  CASCADE; CREATE SCHEMA BPSP;  -- Beneficência Portuguesa SP
        RAISE NOTICE 'Carregando dados de BPSP';
        SET search_path = BPSP, public;
        CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
        CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
        CREATE TABLE Desfechos AS TABLE Public.Desfechos WITH NO DATA;
        PERFORM LoadZIPFile(ZipPath, FilePathBPSP, 'bpsp_pacientes_01.csv'::TEXT, 'Pacientes'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathBPSP, 'bpsp_exames_01.csv'::TEXT,    'ExamLabs'::TEXT);
        PERFORM LoadZIPFile(ZipPath, FilePathBPSP, 'bpsp_desfecho_01.csv'::TEXT, 'Desfechos'::TEXT);
        ANALYSE Pacientes, ExamLabs, Desfechos;
    END IF;

--=============================================================================================
-----------------------------------------------------------------------------------------------
-- Copiar os dados carregados para os Schemas TODOS e D2.
    IF FilePathHSL IS NOT NULL THEN
        IF Cria~'T' THEN
            RAISE NOTICE 'Copiando dados de HSL Para TODOS';
            INSERT INTO TODOS.Pacientes SELECT *, 'HSL' FROM HSL.Pacientes;
            INSERT INTO TODOS.ExamLabs SELECT *, 'HSL' FROM HSL.ExamLabs;
            INSERT INTO TODOS.Desfechos SELECT *, 'HSL' FROM HSL.Desfechos;
            END IF;
        IF Cria~'2' AND Hosp2~'HSL' THEN
            RAISE NOTICE 'Copiando dados de HSL Para D2';
            INSERT INTO D2.Pacientes SELECT *, 'HSL' FROM HSL.Pacientes;
            INSERT INTO D2.ExamLabs SELECT *, 'HSL' FROM HSL.ExamLabs;
            INSERT INTO D2.Desfechos SELECT *, 'HSL' FROM HSL.Desfechos;
            END IF;
        END IF;

    IF FilePathHFL IS NOT NULL THEN
        IF Cria~'T' THEN
            RAISE NOTICE 'Copiando dados de HFL Para TODOS';
            INSERT INTO TODOS.Pacientes SELECT *, 'HFL' FROM HFL.Pacientes;
            INSERT INTO TODOS.ExamLabs SELECT *, 'HFL' FROM HFL.ExamLabs;
            -- INSERT INTO TODOS.Desfechos SELECT *, 'HFL' FROM HFL.Desfechos;
            END IF;
        IF Cria~'2' AND Hosp2~'HFL' THEN
            RAISE NOTICE 'Copiando dados de HFL Para D2';
            INSERT INTO D2.Pacientes SELECT *, 'HFL' FROM HFL.Pacientes;
            INSERT INTO D2.ExamLabs SELECT *, 'HFL' FROM HFL.ExamLabs;
            -- INSERT INTO D2.Desfechos SELECT *, 'HFL' FROM HFL.Desfechos;
            END IF;
        END IF;

    IF FilePathHEI IS NOT NULL THEN
        IF Cria~'T' THEN
            RAISE NOTICE 'Copiando dados de HEI Para TODOS';
            INSERT INTO TODOS.Pacientes SELECT *, 'HEI' FROM HEI.Pacientes;
            INSERT INTO TODOS.ExamLabs SELECT *, 'HEI' FROM HEI.ExamLabs;
            -- INSERT INTO TODOS.Desfechos SELECT *, 'HEI' FROM HEI.Desfechos;
            END IF;
        IF Cria~'2' AND Hosp2~'HEI' THEN
            RAISE NOTICE 'Copiando dados de HEI Para D2';
            INSERT INTO D2.Pacientes SELECT *, 'HEI' FROM HEI.Pacientes;
            INSERT INTO D2.ExamLabs SELECT *, 'HEI' FROM HEI.ExamLabs;
            -- INSERT INTO D2.Desfechos SELECT *, 'HEI' FROM HEI.Desfechos;
            END IF;
        END IF;

    IF FilePathHCSP IS NOT NULL THEN
        IF Cria~'T' THEN
            RAISE NOTICE 'Copiando dados de HCSP Para TODOS';
            INSERT INTO TODOS.Pacientes SELECT *, 'HCSP' FROM HCSP.Pacientes;
            INSERT INTO TODOS.ExamLabs SELECT *, 'HCSP' FROM HCSP.ExamLabs;
            -- INSERT INTO TODOS.Desfechos SELECT *, 'HCSP' FROM HCSP.Desfechos;
            END IF;
        IF Cria~'2' AND Hosp2~'HCSP' THEN
            RAISE NOTICE 'Copiando dados de HCSP Para D2';
            INSERT INTO D2.Pacientes SELECT *, 'HCSP' FROM HCSP.Pacientes;
            INSERT INTO D2.ExamLabs SELECT *, 'HCSP' FROM HCSP.ExamLabs;
            -- INSERT INTO D2.Desfechos SELECT *, 'HCSP' FROM HCSP.Desfechos;
            END IF;
        END IF;

    IF FilePathBPSP IS NOT NULL THEN
        IF Cria~'T' THEN
            RAISE NOTICE 'Copiando dados de BPSP Para TODOS';
            INSERT INTO TODOS.Pacientes SELECT *, 'BPSP' FROM BPSP.Pacientes;
            INSERT INTO TODOS.ExamLabs SELECT *, 'BPSP' FROM BPSP.ExamLabs;
            INSERT INTO TODOS.Desfechos SELECT *, 'BPSP' FROM BPSP.Desfechos;
            END IF;
        IF Cria~'2' AND Hosp2~'BPSP' THEN
            RAISE NOTICE 'Copiando dados de BPSP Para D2';
            INSERT INTO D2.Pacientes SELECT *, 'BPSP' FROM BPSP.Pacientes;
            INSERT INTO D2.ExamLabs SELECT *, 'BPSP' FROM BPSP.ExamLabs;
            INSERT INTO D2.Desfechos SELECT *, 'BPSP' FROM BPSP.Desfechos;
            END IF;
        END IF;

    IF Cria~'2' THEN SET search_path = D2, public;
        RAISE NOTICE 'Criar índices para D2';
        ALTER TABLE D2.Pacientes ADD CONSTRAINT PK_Pacient PRIMARY KEY (ID_Paciente);
        --ALTER TABLE D2.ExamLabs ADD CONSTRAINT PK_ExamLabs PRIMARY KEY (ID_Paciente, ID_ATENDIMENTO);
        CREATE INDEX ExamLabs_IDPacient ON D2.ExamLabs(ID_Paciente); -- in 2 min 45 secs.
        ALTER TABLE D2.Desfechos ADD CONSTRAINT PK_Desfechos PRIMARY KEY (ID_Paciente, ID_Atendimento);
        END IF;

    IF Cria~'T' THEN SET search_path = TODOS, public;
        RAISE NOTICE 'Criar índices para TODOS';
        ALTER TABLE TODOS.Pacientes ADD CONSTRAINT PK_Pacient PRIMARY KEY (ID_Paciente);
        --ALTER TABLE TODOS.ExamLabs ADD CONSTRAINT PK_ExamLabs PRIMARY KEY (ID_Paciente, ID_ATENDIMENTO);
        CREATE INDEX ExamLabs_IDPacient ON TODOS.ExamLabs(ID_Paciente); -- in 2 min 45 secs.
        ALTER TABLE TODOS.Desfechos ADD CONSTRAINT PK_Desfechos PRIMARY KEY (ID_Paciente, ID_Atendimento);
        END IF;

END $$;

ANALYSE; -- ALL

--====================================================================================================
-- Quantas tuplas tem em cada tabela? --------------------------------------- --  in 51 secs 872 msec.
SELECT 0 N,  'Pacientes public' Tabela, Count(*) Tuplas FROM public.Pacientes UNION
  SELECT 1,  'Pacientes TODOS', Count(*) FROM TODOS.Pacientes UNION
  SELECT 2,  'ExamLabs TODOS',  Count(*) FROM TODOS.ExamLabs  UNION
  SELECT 3,  'Desfechos TODOS', Count(*) FROM TODOS.Desfechos UNION
  SELECT 4,  'Pacientes D2', Count(*) FROM D2.Pacientes UNION
  SELECT 5,  'ExamLabs D2',  Count(*) FROM D2.ExamLabs  UNION
  SELECT 6,  'Desfechos D2', Count(*) FROM D2.Desfechos UNION
  SELECT 7,  'Pacientes HSL', Count(*) FROM HSL.Pacientes UNION
  SELECT 8,  'ExamLabs HSL', Count(*)  FROM HSL.ExamLabs  UNION
  SELECT 9,  'Desfechos HSL', Count(*) FROM HSL.Desfechos UNION
  SELECT 10, 'Pacientes Fleury', Count(*) FROM HFL.Pacientes UNION
  SELECT 11, 'ExamLabs Fleury', Count(*)  FROM HFL.ExamLabs  UNION
  SELECT 12, 'Pacientes Einstein', Count(*) FROM HEI.Pacientes UNION
  SELECT 13, 'ExamLabs Einstein', Count(*)  FROM HEI.ExamLabs  UNION
  SELECT 14, 'Pacientes HCSP', Count(*) FROM HCSP.Pacientes UNION
  SELECT 15, 'ExamLabs HCSP', Count(*)  FROM HCSP.ExamLabs  UNION
  SELECT 16, 'Pacientes BPSP', Count(*) FROM BPSP.Pacientes UNION
  SELECT 17, 'ExamLabs BPSP', Count(*)  FROM BPSP.ExamLabs  UNION
  SELECT 18, 'Desfechos BPSP', Count(*) FROM BPSP.Desfechos
      ORDER BY 1;


-- 1	"Paciente"			  563.552
-- 2	"ExamLabs"		   26.652.020
-- 3	"Desfechos"			   42.691


-- 1	"Pacientes TODOS"		0
-- 2	"ExamLabs TODOS"		0
-- 3	"Desfechos TODOS"		0
-- 4	"Pacientes D2"			0
-- 5	"ExamLabs D2"			0
-- 6	"Desfechos D2"			0
-- 7	"Pacientes HSL"			  8.971
-- 8	"ExamLabs HSL"		  1.463.834
-- 9	"Desfechos HSL"		 	 42.691
-- 10	"Pacientes Fleury"		470.967
-- 11	"ExamLabs Fleury"	 19.274.381
-- 12	"Pacientes Einstein"	 79.863
-- 13	"ExamLabs Einstein"	  3.415.155
-- 14	"Pacientes HCSP"	      3.751
-- 15	"ExamLabs HCSP"		  2.498.650
-- 16	"Pacientes BPSP"		 39.000
-- 17	"ExamLabs BPSP"		  5.339.293
-- 18	"Desfechos BPSP"		217.991
--====================================================================================================
-- SELECT * FROM IndexSizes('paciente') UNION
--             SELECT * FROM IndexSizes('examLab') UNION
--             SELECT * FROM IndexSizes('desfecho')
-- 	     ORDER BY 1


-- 7	"Pacientes HSL"			  8.971 --> 14.673
-- 8	"ExamLabs HSL"		  1.463.834 --> 2.952.999
-- 9	"Desfechos HSL"		 	 42.691 --> 89.937
-- 10	"Pacientes Fleury"		470.967 --> 
-- 11	"ExamLabs Fleury"	 19.274.381 --> 39.567.768
