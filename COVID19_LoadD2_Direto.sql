--==============================================================================================================
--  Caetano Traina Júnior -- maio de 2021 ------------ =========================================================
--  Criar um ESQUEMA para cada hospital HSL e BPSP e o ESQUEM D2 que integra os 2 hospitais                   ==
-- Tempo aproximado: 4:30 Min.                                                                                ==
/*------------------------------------------------------------------------------------------------------------==
AS tabelas são obtidas do site do repositório USP-Fapesp Dataset Covid-19:
https://repositoriodatasharingfapesp.uspdigital.usp.br/handle/item/1
ATENÇÃO: Os dados devem ser obtidos individualmente, diretamente do site fa FAPESP,
         atendendo aos requisitos de direito de uso indicados no site.

Este script permite ler as 3 tabelas (paciente, exame e desfecho) de cada hospital, cada hospital no seu 
respectivo ESQUEMA: HSL HFL HEI HCSP BPSP.
Antes de executar este script, é necessário que as 3 tabelas já estejam declaradas: 
    Rodar antes COVID19_Define-21-02.sql (versão fevereiro 2021)
	A seguir, descompactar os arquivos HSP.zip e BPSP.zip obtidos da FAPESP numa pasta local 
	  (por exemplo: C:\Descompacta )
*/
--==============================================================================================================
DROP SCHEMA IF EXISTS D2    CASCADE; CREATE SCHEMA D2;    -- HSL + HCSP
CREATE TABLE D2.Pacientes AS TABLE Public.Pacientes WITH NO DATA;
CREATE TABLE D2.ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
CREATE TABLE D2.Desfechos AS TABLE Public.Desfechos WITH NO DATA;
ALTER TABLE D2.Pacientes ADD COLUMN DE_Hospital TEXT;
ALTER TABLE D2.ExamLabs ADD COLUMN DE_Hospital TEXT;
ALTER TABLE D2.Desfechos ADD COLUMN DE_Hospital TEXT;

-- Criar e carregar as tabelas de cada hospital ==========================================================
SET datestyle to DMY, ISO;
SET Client_encoding TO 'UTF8';

-- Carrega dados Hospital Sírio-Libanês: HSL --------------------------------------------------
-----------------------------------------------------------------------------------
DROP SCHEMA IF EXISTS HSL   CASCADE;                     -- Sírio-Libanês 
CREATE SCHEMA HSL;
SET search_path = HSL, public;
CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
CREATE TABLE Desfechos AS TABLE Public.Desfechos WITH NO DATA;
COPY Pacientes FROM 'C:\Descompacta\HSL_Pacientes_4.csv' (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
COPY ExamLabs  FROM 'C:\Descompacta\HSL_Exames_4.csv'    (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
COPY Desfechos FROM 'C:\Descompacta\HSL_Desfechos_4.csv' (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
ANALYSE Pacientes, ExamLabs, Desfechos;

DROP SCHEMA IF EXISTS BPSP CASCADE;                      -- Beneficência Portuguesa SP
CREATE SCHEMA BPSP;  
SET search_path = BPSP, public;
CREATE TABLE Pacientes AS TABLE Public.Pacientes WITH NO DATA;
CREATE TABLE ExamLabs  AS TABLE Public.ExamLabs  WITH NO DATA;
CREATE TABLE Desfechos AS TABLE Public.Desfechos WITH NO DATA;
COPY Pacientes FROM 'C:\Descompacta\BPSP_Pacientes_01.csv' (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
COPY ExamLabs  FROM 'C:\Descompacta\BPSP_Exames_01.csv'    (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
COPY Desfechos FROM 'C:\Descompacta\BPSP_Desfechos_01.csv' (DELIMITER '|', NULL '''', ENCODING 'UTF8', HEADER true, FORMAT CSV);
ANALYSE Pacientes, ExamLabs, Desfechos;

--=============================================================================================
-----------------------------------------------------------------------------------------------
INSERT INTO D2.Pacientes SELECT *, 'HSL' FROM HSL.Pacientes;
INSERT INTO D2.ExamLabs SELECT *, 'HSL' FROM HSL.ExamLabs;
INSERT INTO D2.Desfechos SELECT *, 'HSL' FROM HSL.Desfechos;

INSERT INTO D2.Pacientes SELECT *, 'BPSP' FROM BPSP.Pacientes;
INSERT INTO D2.ExamLabs SELECT *, 'BPSP' FROM BPSP.ExamLabs;
INSERT INTO D2.Desfechos SELECT *, 'BPSP' FROM BPSP.Desfechos;

ALTER TABLE D2.Pacientes ADD CONSTRAINT PK_Pacient PRIMARY KEY (ID_Paciente);
CREATE INDEX ExamLabs_IDPacient ON D2.ExamLabs(ID_Paciente); -- in 2 min 45 secs.
ALTER TABLE D2.Desfechos ADD CONSTRAINT PK_Desfechos PRIMARY KEY (ID_Paciente, ID_Atendimento);

ANALYSE; -- ALL

--====================================================================================================
-- Quantas tuplas tem em cada tabela? --------------------------------------- --  in 51 secs 872 msec.
SELECT   1,  'Pacientes D2', Count(*) FROM D2.Pacientes UNION
  SELECT 2,  'ExamLabs D2',  Count(*) FROM D2.ExamLabs  UNION
  SELECT 3,  'Desfechos D2', Count(*) FROM D2.Desfechos
  ORDER BY 1;

-------+----------------+---------+
---- 1 | 'Pacientes D2' | 53673   |
---- 2 | 'ExamLabs D2'  | 8292292 |
---- 3 | 'Desfechos D2' | 307928  |
-------+----------------+---------+
