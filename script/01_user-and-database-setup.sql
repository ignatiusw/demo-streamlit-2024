-- Create users and roles required for this demo
USE ROLE USERADMIN;
-- streamlit creator
CREATE OR REPLACE USER DEMO_STREAMLIT_CREATOR WITH PASSWORD = '$up3r$ecr3tP@ssw0rd!';
CREATE OR REPLACE ROLE ROL_DEMO_STREAMLIT_CREATOR;
GRANT ROLE ROL_DEMO_STREAMLIT_CREATOR TO USER DEMO_STREAMLIT_CREATOR;

-- streamlit viewer
CREATE OR REPLACE USER DEMO_STREAMLIT_VIEWER WITH PASSWORD = '@n0th3rP@$$w0rd?';
CREATE OR REPLACE ROLE ROL_DEMO_STREAMLIT_VIEWER;
GRANT ROLE ROL_DEMO_STREAMLIT_VIEWER TO USER DEMO_STREAMLIT_VIEWER;
GRANT ROLE ROL_DEMO_STREAMLIT_VIEWER TO ROLE ROL_DEMO_STREAMLIT_CREATOR;

-- role for data
CREATE OR REPLACE ROLE ROL_DEMO_DATA_CRUD;
GRANT ROLE ROL_DEMO_DATA_CRUD TO ROLE ROL_DEMO_STREAMLIT_CREATOR;

-- change default roles
ALTER USER DEMO_STREAMLIT_CREATOR SET DEFAULT_ROLE = ROL_DEMO_STREAMLIT_CREATOR;
ALTER USER DEMO_STREAMLIT_VIEWER SET DEFAULT_ROLE = ROL_DEMO_STREAMLIT_VIEWER;

-- Create database, schema and warehouse
USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_DB;
CREATE SCHEMA IF NOT EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP;
CREATE SCHEMA IF NOT EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA;
CREATE WAREHOUSE IF NOT EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_WH WITH INITIALLY_SUSPENDED = TRUE;

-- Grant required privileges
USE ROLE SECURITYADMIN;
-- Grants for streamlit viewer
GRANT USAGE ON DATABASE DEMO_PROGRAMMABLE_2024_STREAMLIT_DB TO ROLE ROL_DEMO_STREAMLIT_VIEWER;
GRANT USAGE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP TO ROLE ROL_DEMO_STREAMLIT_VIEWER;
-- Additional grants for streamlit creator
GRANT CREATE STREAMLIT ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP TO ROLE ROL_DEMO_STREAMLIT_CREATOR;
GRANT CREATE STAGE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP TO ROLE ROL_DEMO_STREAMLIT_CREATOR;
GRANT CREATE TABLE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP TO ROLE ROL_DEMO_STREAMLIT_CREATOR;
GRANT USAGE ON WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH TO ROLE ROL_DEMO_STREAMLIT_CREATOR;
-- Grants for data
GRANT USAGE ON DATABASE DEMO_PROGRAMMABLE_2024_STREAMLIT_DB TO ROLE ROL_DEMO_DATA_CRUD;
GRANT USAGE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
GRANT CREATE TABLE, MODIFY TABLE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
GRANT CREATE VIEW ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
GRANT ALL ON FUTURE TABLES IN SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
GRANT ALL ON FUTURE VIEWS IN SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
GRANT USAGE ON WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH TO ROLE ROL_DEMO_DATA_CRUD;
-- Grant streamlit creator access to data
GRANT SELECT ON FUTURE TABLES IN SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_STREAMLIT_CREATOR;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_STREAMLIT_CREATOR;

-- Grant privileges to create forecast object
GRANT CREATE SNOWFLAKE.ML.FORECAST ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA TO ROLE ROL_DEMO_DATA_CRUD;
