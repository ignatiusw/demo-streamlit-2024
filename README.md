# demo-streamlit-2024
This repo holds all the codes and sample data for Streamlit in Snowflake demo (2024). A copy of the presentation slides will be added once approved for external distribution.
> ⚠️ **This code is developed when Streamlit in Snowflake (SiS) version is 1.22.0. If and once Snowflake upgrade the Streamlit version, the code may not work 100%**.

## Pre-requisites
1. You need a Snowflake account. If you don't have one yet, you can sign up for a 30-day free trial [here](https://signup.snowflake.com/)
2. You have SYSADMIN privileges in your Snowflake account
3. If you don't have ACCOUNTADMIN privileges, you have at least one of the privileges mentioned [here](https://docs.snowflake.com/en/user-guide/ui-snowsight-activity#privileges-required-to-view-query-history) in order to view query history

## Demo Steps
1. Login to Snowflake with user that has SYSADMIN privileges
2. Run [01_user-and-database-setup.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/01_user-and-database-setup.sql) to set up all the users, roles, database objects, warehouse, and privileges required to run this demo
3. Log in as `DEMO_STREAMLIT_CREATOR` user
4. Execute line 2 to line 6 from [02_prepare-demo-data.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/02_prepare-demo-data.sql#L2-L6), this will switch the role to `ROL_DEMO_DATA_CRUD` and use the `DEMO_PROGRAMMABLE_2024_STREAMLIT_WH` warehouse
5. Load the [demo_data.csv](https://raw.githubusercontent.com/ignatiusw/demo-streamlit-2024/main/data/demo_data.csv) into a new table called `DEMO_DATA` under `DATA` schema in `DEMO_PROGRAMMABLE_2024_STREAMLIT_DB` database
6. Execute line 11 to preview the data in [02_prepare-demo-data.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/02_prepare-demo-data.sql#L11)
7. Load the [store_pct.csv](https://raw.githubusercontent.com/ignatiusw/demo-streamlit-2024/main/data/store_pct.csv) into a new table called `STORE_PCT` under `DATA` schema in `DEMO_PROGRAMMABLE_2024_STREAMLIT_DB` database
8. Execute the rest of the script from line 20 onwards in [02_prepare-demo-data.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/02_prepare-demo-data.sql#L20)
9. Switch role to `ROL_DEMO_STREAMLIT_CREATOR`
10. Create a new streamlit app, using the code in [03_streamlit-app.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/03_streamlit-app.py)
11. Feel free to change the filter, and add/update/delete the target revenue data
12. Share the app to `ROL_DEMO_STREAMLIT_VIEWER` and copy the app URL
13. Open the app URL in a separate incognito/in-private browser window and login as `DEMO_STREAMLIT_VIEWER` user
14. Feel free to change the filter, and add/update/delete the target revenue data as the viewer

## Optional Exercises

### Create Masking Policy to show limitations of Streamlit in Snowflake (SIS) with Secondary Roles
> ℹ️ **Masking Policy requires Enterprise Edition of Snowflake**.

To demonstrate that secondary roles are not available through SiS, do the following exercise:
1. Login as user with `USERADMIN`, `SYSADMIN` and `SECURITYADMIN` roles
2. Execute line 6 to 23 from [04_create-masking-policy.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/04_create-masking-policy.sql#L6-L23)
3. Go back as user `DEMO_STREAMLIT_CREATOR`
4. Execute line 26 to 34 from [04_create-masking-policy.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/04_create-masking-policy.sql#L26-L34)
5. The `REVENUE` column should be visible (unmasked)
6. Pause here and do the next optional exercise

### Some limitations of Streamlit in Snowflake (SiS)
To demonstrate some of the limitations of Streamlit in Snowflake, such as that it cannot access internet, do the following exercise:
1. Go back to `DEMO_STREAMLIT_CREATOR` user and create a new streamlit app
2. Add the content of [05_some-streamlit-limitations.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/05_some-streamlit-limitations.py) to the bottom of the demo app
3. Run it and see the error `URLError: <urlopen error [Errno 16] Device or resource busy>`
4. You can run the same script in your own Python environment and it should run successfully (unless you have specifically blocked network connectivity from github.com)
5. As of the time of writing, the SiS version is 1.22.0 and does not have the [sankeyflow](https://pypi.org/project/sankeyflow/) Python library yet, so this will also fail with the error `ModuleNotFoundError: No module named 'sankeyflow'`
6. If you did the previous exercise (Masking Policy), you should see all the `REVENUE` values are masked (NULL)
7. Go back to user with `SECURITYADMIN` role and execute line 40 to 41 in [04_create-masking-policy.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/04_create-masking-policy.sql#L40-L41) to grant the sensitive role to the streamlit creator role
8. Re-run the streamlit app again and you should now see the `REVENUE` values unmasked, this is because whilst SiS doesn't observe secondary roles, it understands inherited privileges from roles granted to other roles

### Streamlit in Snowflake (SiS) execute as owner context/role
To demonstrate that Streamlit in Snowflake execute the app with the owner context/role, do the following exercise:
1. Using a role that has access to Query History, open the query history for `DEMO_STREAMLIT_VIEWER` and show the history for the last day
2. All queries should show successful, unless you have executed a failed query when logged in as the above user
3. Find any query that accesses any data from `DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA` schema (either the table or the view), this should show a successful execution
4. Go back to the browser window where `DEMO_STREAMLIT_VIEWER` is logged in (or if you have closed this, open a new browser window and log in as this user)
5. Execute the script [06_execute-as-owner-example-in-sis.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/06_execute-as-owner-example-in-sis.sql)
6. The script would not be successful, as you don't have USAGE privilage to the warehouse
7. Grant the USAGE privilege to the warehouse as per line 8 in [06_execute-as-owner-example-in-sis.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/06_execute-as-owner-example-in-sis.sql#L8) using a user with SECURITYADMIN privileges then re-run the `USE WAREHOUSE` statement
8. Execute the `SELECT` statement, but the user will not have SELECT privileges on the table
9. The reason why the execution by the user is successful in Streamlit app is because the Streamlit app executes the queries as the owner of the app, that is `ROL_DEMO_STREAMLIT_CREATOR` role.

### Streamlit in Snowflake (SiS) bypass masking policy
> ℹ️ **This exercise requires step 04_create-masking-policy.sql as the pre-requisite**.

To demonstrate that masking policy is also bypassed (for the same reason as above, since SiS runs with the owner context/role), do the following exercise:
1. Using a role with `SECURITYADMIN` privileges, execute line 5 to 13 in [07_sis-bypass-masking-policy.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/07_sis-bypass-masking-policy.sql#L5-L13)
2. Now login as `DEMO_STREAMLIT_VIEWER` and execute line 16 to 21 in [07_sis-bypass-masking-policy.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/07_sis-bypass-masking-policy.sql#L16-L21), the `REVENUE` column is masked (NULL)
3. Go back to the first Streamlit app created by [03_streamlit-app.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/03_streamlit-app.py), the `REVENUE` values should still be visible
4. Alternatively if you have created the Streamlit app from [05_some-streamlit-limitations.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/05_some-streamlit-limitations.py), share this app to `ROL_DEMO_STREAMLIT_VIEWER`, the `REVENUE` values should still be visible

## Acknowledgement
1. Demo data is originally sourced from [kaggle](https://www.kaggle.com/datasets/ankitab18/coles-supermarket-sales?resource=download) and modified to remove NULLs and to make it smaller
2. Some of the app components ideas are taken from other users involved in the evaluation of Streamlit in Snowflake (SiS) at Xero

## References
* https://www.snowflake.com/en/data-cloud/overview/streamlit-in-snowflake/
* https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit/
* https://docs.snowflake.com/en/developer-guide/streamlit/owners-rights
* https://docs.streamlit.io/
