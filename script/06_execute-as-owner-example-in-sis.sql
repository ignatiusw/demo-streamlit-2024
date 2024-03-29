-- Log in as DEMO_STREAMLIT_VIEWER user
USE ROLE ROL_DEMO_STREAMLIT_VIEWER;
USE DATABASE DEMO_PROGRAMMABLE_2024_STREAMLIT_DB;

USE WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH;
-- first run will fail as ROL_DEMO_STREAMLIT_VIEWER doesn't have USAGE privilege on the warehouse above
-- use SECURITYADMIN to grant usage privilege to the warehouse above
-- GRANT USAGE ON WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH TO ROLE ROL_DEMO_STREAMLIT_VIEWER;
-- the re-run USE WAREHOUSE command before continuing

SELECT a.MONTH
    , a.REVENUE AS ACTUAL
    , t.TARGET_REVENUE AS TARGET
FROM DATA.REVENUE a
LEFT JOIN DATA.DEMO_DATA t
    ON a.MONTH = t.MONTH
        AND a.REGION = t.REGION
WHERE a.REGION = 'AU/NZ'
ORDER BY a.MONTH;
