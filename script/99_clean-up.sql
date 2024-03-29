-- clean up database and all contents
USE ROLE SYSADMIN;
DROP DATABASE IF EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_DB;
DROP WAREHOUSE IF EXISTS DEMO_PROGRAMMABLE_2024_STREAMLIT_WH;

-- clean up users and roles
USE ROLE USERADMIN;
DROP USER IF EXISTS DEMO_STREAMLIT_CREATOR;
DROP USER IF EXISTS DEMO_STREAMLIT_VIEWER;
DROP ROLE IF EXISTS ROL_DEMO_STREAMLIT_CREATOR;
DROP ROLE IF EXISTS ROL_DEMO_STREAMLIT_VIEWER;
DROP ROLE IF EXISTS ROL_DEMO_DATA_CRUD;
DROP ROLE IF EXISTS ROL_DEMO_RO_SENSITIVE;
