# demo-streamlit-2024
This repo holds all the codes and sample data for Streamlit in Snowflake demo (2024). A copy of the presentation slides will be added once approved for external distribution.

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
6. Execute the rest of the script from line 11 onwards in [02_prepare-demo-data.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/02_prepare-demo-data.sql#L11)
7. Switch role to `ROL_DEMO_STREAMLIT_CREATOR`
8. Create a new streamlit app, using the code in [03_streamlit-app.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/03_streamlit-app.py)
9. Feel free to change the filter, and add/update/delete the target revenue data
10. Share the app to `ROL_DEMO_STREAMLIT_VIEWER` and copy the app URL
11. Open the app URL in a separate incognito/in-private browser window and login as `DEMO_STREAMLIT_VIEWER` user
12. Feel free to change the filter, and add/update/delete the target revenue data as the viewer

## Optional Exercises

### Streamlit in Snowflake (SiS) unable to access the Internet
To show that Streamlit in Snowflake cannot access internet, do the following exercise:
1. Go back to `DEMO_STREAMLIT_CREATOR` user and create a new streamlit app
2. Add the content of [04_streamlit-internet-access.py](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/04_streamlit-internet-access.py) to the bottom of the demo app
3. Run it and see the error `URLError: <urlopen error [Errno 16] Device or resource busy>`
4. You can run the same script in your own Python environment and it should run successfully (unless you have specifically blocked network connectivity from github.com)

### Streamlit in Snowflake (SiS) execute as owner context/role
To show that Streamlit in Snowflake execute the app with the owner context/role, do the following exercise:
1. Using a role that has access to Query History, open the query history for `DEMO_STREAMLIT_VIEWER` and show the history for the last day
2. All queries should show successful, unless you have executed a failed query when logged in as the above user
3. Find any query that accesses any data from `DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA` schema (either the table or the view), this should show a successful execution
4. Go back to the browser window where `DEMO_STREAMLIT_VIEWER` is logged in (or if you have closed this, open a new browser window and log in as this user)
5. Execute the script [05_execute-as-owner-example-in-sis.sql](https://github.com/ignatiusw/demo-streamlit-2024/blob/main/script/05_execute-as-owner-example-in-sis.sql)
6. The script would not be successful, as you don't have USAGE privilage to the warehouse
7. Grant the USAGE privilege to the warehouse as per [line 8](https://github.com/ignatiusw/demo-streamlit-2024/blob/809a6f03fd4678d61353a4ea93885f1c732b977d/script/05_execute-as-owner-example-in-sis.sql#L8) using a user with SECURITYADMIN privileges then re-run the `USE WAREHOUSE` statement
8. Execute the `SELECT` statement, but the user will not have SELECT privileges on the table
9. The reason why the execution by the user is successful in Streamlit app is because the Streamlit app executes the queries as the owner of the app, that is `ROL_DEMO_STREAMLIT_CREATOR` role.

## Acknowledgement
1. Demo data is sourced from [kaggle](https://www.kaggle.com/datasets/ankitab18/coles-supermarket-sales?resource=download)
2. Some of the app components ideas are taken from other users involved in the evaluation of Streamlit in Snowflake (SiS)

## References
* https://www.snowflake.com/en/data-cloud/overview/streamlit-in-snowflake/
* https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit/
* https://docs.streamlit.io/
