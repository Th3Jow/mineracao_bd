\set  ScriptPath 'path-do-repo/Covid19/'
DROP DATABASE IF EXISTS FapCov2103;
CREATE DATABASE FapCov2103 WITH OWNER = postgres;
\c "host=localhost port=5432 user=postgres dbname=FapCov2103 password=pgadmin sslmode=disable"
SELECT current_database(), Current_User;

\i :ScriptPath'COVID19_Define-21-02.sql'    -- Define a estrutura das tabelas no Esquema 'public'
\i :ScriptPath'COVID19_LoadData-21-02.sql'  -- Define os esquemas dos hospitais + D2 + Todos, e efetua a carga das tabelas correspondentes
\i :ScriptPath'COVID19_Corrige-21-02.sql'   -- Faz uma limpesa inicial dos dados
\i :ScriptPath'COVID19_Comments-21-02.sql'  --(opcional) Define os atributos e tabelas, segundo a documentação do repositório FAPESP_Covid19
