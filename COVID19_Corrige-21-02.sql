--==============================================================================================================
--  Caetano Traina Júnior -- maio de 2021 ------------ =========================================================
--  Corrigir alguns atributos                                                                                 ==
-- tempo aproximado: 17 Min.                                                                                  ==
--------------------------------------------------------------------------------------------------------------==

ALTER TABLE Pacientes RENAME AA_Nasc TO AA_Nascimento;
ALTER TABLE Pacientes ALTER COLUMN AA_Nascimento TYPE INT 
    USING Substring(AA_Nascimento, '\d+')::INT;
UPDATE Pacientes SET cd_pais=null WHERE cd_pais='XX';
UPDATE Pacientes SET cd_distrito=null WHERE cd_distrito='CCCC';
UPDATE Pacientes SET cd_municipio=null WHERE cd_municipio='MMMM';

UPDATE ExamLabs  -- in 15 secs 86 msec.    
    SET DE_Exame=REGEXP_REPLACE(De_exame, '(fra[cç][aã]o)', 'fração', 'i')
	WHERE De_Exame~*'Fra[cç][aã]o';
UPDATE ExamLabs -- somente HCSP tem problemas
    SET de_analito='Observação Série Branca' 
	WHERE de_analito~*'Observa.+ S.ri. Branca';

UPDATE ExamLabs    --  in 5 min 28 secs
    SET DE_Exame=
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
	   regexp_replace(
	   regexp_replace(DE_Exame, '.*', lower(DE_Exame))
	       , '(atico|ático|actico|áctico)', 'ático', 'g')
		   , '(erica)', 'érica', 'g')
		   , '(urica)', 'úrica', 'g')
		   , '(erico)', 'érico', 'g')
		   , '(urico)', 'úrico', 'g')
		   , '(anico)', 'ânico', 'g')
		   , '(alico)', 'álico', 'g')
		   , '(elico)', 'élico', 'g')
		   , '(ilico)', 'ílico', 'g')
		   , '(olico)', 'ólico', 'g')
		   , '(onica)\M', 'ônica', 'g')
		   , '(onico)', 'ônico', 'g')
		   , '(proico)', 'próico', 'g')
		   , '(virus)', 'vírus', 'g')
		   , '(proteina)', 'proteína', 'g')
		   , '(minio)', 'mínio', 'g')
		   , '(monia)\M', 'mônia', 'g')
		   , '(acteria)', 'actéria', 'g')
		   , '(acido)', 'ácido', 'g')
		   , '(rapid)', 'rápid', 'g'),
    DE_Analito=       
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
       regexp_replace(
	   regexp_replace(DE_Analito, '.*', lower(DE_Analito))
	       , '(atico|ático|actico|áctico)', 'ático', 'g')
		   , '(erica)', 'érica', 'g')
		   , '(urica)', 'úrica', 'g')
		   , '(erico)', 'érico', 'g')
		   , '(urico)', 'úrico', 'g')
		   , '(anico)', 'ânico', 'g')
		   , '(alico)', 'álico', 'g')
		   , '(elico)', 'élico', 'g')
		   , '(ilico)', 'ílico', 'g')
		   , '(olico)', 'ólico', 'g')
		   , '(onica)\M', 'ônica', 'g')
		   , '(onico)', 'ônico', 'g')
		   , '(proico)', 'próico', 'g')
		   , '(virus)', 'vírus', 'g')
		   , '(proteina)', 'proteína', 'g')
		   , '(minio)', 'mínio', 'g')
		   , '(monia)\M', 'mônia', 'g')
		   , '(acteria)', 'actéria', 'g')
		   , '(acido)', 'ácido', 'g')
		   , '(rapid)', 'rápid', 'g');


ALTER TABLE D2.ExamLabs ADD COLUMN DE_resultNum FLOAT;
UPDATE D2.ExamLabs SET DE_resultNum=Replace(Substring(de_resultado, '-?\d+,?\d*'), ',', '.')::FLOAT; -- in 15 min 33 secs.
-- SELECT AVG(de_resultnum) FROM ExamLabs; --  1 min 4 secs.

------ ====================================================================================================
------ Rodar isolado, fora do script:
-- VACUUM FULL VERBOSE ANALYZE ExamLabs;  -- in 1 min 11 secs.

------ ====================================================================================================
------ ====================================================================================================
