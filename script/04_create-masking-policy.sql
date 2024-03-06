-- Demo masking policy being bypassed by Streamlit in Snowflake due to running as owner
-- Note: Masking policy is available on Enterprise Edition and above only

-- Use an account with USERADMIN, SYSADMIN and SECURITYADMIN roles
-- Create a role to view sensitive data
USE ROLE USERADMIN;
CREATE ROLE ROL_DEMO_RO_SENSITIVE;

-- Create masking policy 
USE ROLE SYSADMIN;
CREATE OR REPLACE MASKING POLICY DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.DEMO_PROGRAMMABLE_2024_MASKING_POLICY
AS (val NUMERIC) RETURNS NUMERIC ->
    CASE WHEN IS_ROLE_IN_SESSION('ROL_DEMO_RO_SENSITIVE')
        THEN val
    ELSE NULL
END;

-- Grant ROL_DEMO_DATA_CRUD to apply masking policy on objects they owned
USE ROLE SECURITYADMIN;
GRANT APPLY ON MASKING POLICY DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.DEMO_PROGRAMMABLE_2024_MASKING_POLICY
    TO ROL_DEMO_DATA_CRUD;
-- Grant ROL_DEMO_RO_SENSITIVE to user DEMO_STREAMLIT_CREATOR
GRANT ROLE ROL_DEMO_RO_SENSITIVE TO USER DEMO_STREAMLIT_CREATOR;

-- Now login as DEMO_STREAMLIT_CREATOR
USE ROLE ROL_DEMO_DATA_CRUD;
USE WAREHOUSE DEMO_PROGRAMMABLE_2024_STREAMLIT_WH;

-- Apply masking policy to revenue view 
ALTER VIEW DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.REVENUE
MODIFY COLUMN REVENUE SET MASKING POLICY DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.DEMO_PROGRAMMABLE_2024_MASKING_POLICY;

-- Access the data as DEMO_STREAMLIT_CREATOR, value should be visible
SELECT * FROM DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.REVENUE;

-- Pause here, create the Streamlit app in step 05 first, then get back to this step.
-- Now view it from Streamlit, it is not visible due to secondary role are not available there

-- Go back to SECURITYADMIN and grant role sensitive to streamlit creator since Secondary Roles are not available in SiS
USE ROLE SECURITYADMIN;
GRANT ROLE ROL_DEMO_RO_SENSITIVE TO ROLE ROL_DEMO_STREAMLIT_CREATOR;

-- Now view it again from Streamlit, it is now visible as the sensitive role is now granted to streamlit creator role
