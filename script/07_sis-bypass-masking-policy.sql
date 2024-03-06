-- Demo masking policy being bypassed by Streamlit in Snowflake due to running as owner
-- Note: Masking policy is available on Enterprise Edition and above only
-- Depends on step 04_create-masking-policy.sql

USE ROLE SECURITYADMIN;

-- Grant additional privilege to ROL_DEMO_STREAMLIT_VIEWER for this purpose
GRANT USAGE ON SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA
TO ROLE ROL_DEMO_STREAMLIT_VIEWER;

-- Grant SELECT on revenue view to ROL_DEMO_STREAMLIT_VIEWER
GRANT SELECT ON VIEW DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.REVENUE
TO ROLE ROL_DEMO_STREAMLIT_VIEWER;

-- Now login as DEMO_STREAMLIT_VIEWER
USE ROLE ROL_DEMO_STREAMLIT_VIEWER;
USE SCHEMA DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA;
USE WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH;

-- Revenue should be masked (NULL)
SELECT * FROM DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.REVENUE;

-- Now go back to the streamlit app and you should still be able to view the revenue numbers
-- Alternatively, share the 2nd streamlit app (from step 05_some-streamlit-limitations.py), the revenue number is also visible
