# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import time

# Set app title and description
st.title(":balloon: Streamlit in Snowflake :snowflake:")
st.header("Demo for Programmable 2024")
st.write(
    """This is a demo Streamlit in Snowflake (SiS) app
    created as part of Programmable 2024 presentation."""
)
st.write(
    """The app shows the actual and forecasted revenue
    for a region selected in the filter panel, and allows
    user to update the target revenue up to the next
    12 months."""
)

# Get the current credentials
session = get_active_session()

# Create sidebar for filters
with st.sidebar:
    st.title("Filter Panel")
    # First filter is the Region
    distinct_region = session.sql(
        """
        SELECT DISTINCT REGION
        FROM DATA.DEMO_DATA
        ORDER BY REGION
        """
    )
    filter_region = st.selectbox(
        "Choose Region:",
        distinct_region,
    )
    # Second filter is the # of months to forecast
    filter_months = st.slider(
        "Month(s) to Forecast:",
        min_value = 1,
        max_value = 12,
        value = 4
    )
    st.write(f"Current user: {st.experimental_user['login_name']}")
    st.write(f"Streamlit version: {st.__version__}")

# Get actual revenue data
df_actual = session.sql(
    f"""
    SELECT a.MONTH
        , a.REVENUE AS ACTUAL
        , t.TARGET_REVENUE AS TARGET
    FROM DATA.REVENUE a
    LEFT JOIN DATA.DEMO_DATA t
        ON a.MONTH = t.MONTH
            AND a.REGION = t.REGION
    WHERE a.REGION = '{filter_region}'
    ORDER BY a.MONTH
    """
)
# Get forecast revenue data
df_forecast = session.sql(
    f"""
    CALL DATA.FORECAST_MODEL!FORECAST(
        FORECASTING_PERIODS => {filter_months}
    )
    """
).collect()

# Prepare target data
session.sql(
    f"""
    CREATE TABLE IF NOT EXISTS STREAMLIT_APP."TARGET_REVENUE_{filter_region}"
    AS
    SELECT CAST(MONTH AS VARCHAR(10)) AS MONTH, TARGET_REVENUE
    FROM DATA.TARGET_REVENUE
    WHERE REGION = '{filter_region}'
        AND TARGET_REVENUE IS NOT NULL
    """
).collect()

# Get target revenue data
df_target = session.sql(
    f"""
    SELECT CAST(COALESCE(CAST(fr.MONTH AS DATE), tr.MONTH) AS TIMESTAMP_NTZ) AS MONTH
        , COALESCE(fr.TARGET_REVENUE, tr.TARGET_REVENUE) AS TARGET
    FROM DATA.TARGET_REVENUE tr
    FULL OUTER JOIN STREAMLIT_APP."TARGET_REVENUE_{filter_region}" fr
        ON tr.MONTH = CAST(fr.MONTH AS DATE)
    WHERE COALESCE(tr.REGION, '{filter_region}') = '{filter_region}'
    ORDER BY MONTH
    LIMIT {filter_months}
    """
)

# Convert forecast to pandas dataframe and remove other series
pdf_forecast = pd.DataFrame(df_forecast).rename(columns={"TS": "MONTH"})
pdf_forecast.drop(
    pdf_forecast[pdf_forecast["SERIES"] != f'"{filter_region}"'].index,
    inplace=True
)

# Combine the data
pdf_forecast_target = pd.merge(
    pdf_forecast.drop("SERIES", axis=1),
    df_target.to_pandas(),
    on="MONTH",
    how="outer"
)

pdf_revenue = pd.concat(
    [
        df_actual.to_pandas(),
        pdf_forecast_target
    ],
    ignore_index=True
)

# Show the data as chart and table
st.header(f"Actual, Target and Forecasted Revenue per Month for {filter_region} Region")
st.line_chart(
    pdf_revenue, 
    x="MONTH", 
    y=["ACTUAL", "TARGET", "FORECAST", "LOWER_BOUND", "UPPER_BOUND"]
)
st.subheader("Underlying Data")
st.write("This is the underlying data driving the chart above.")
st.dataframe(pdf_revenue)

# Allow user to adjust the target
st.header(f"Adjust Target for {filter_region} Region")
st.write(
    """
    Adjust the target revenue to a more realistic target
    based on the forecast above. Please don't be too hard
    on our sales team :sweat_smile:
    """
)
df_editable_target = session.table(
    f'DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.STREAMLIT_APP."TARGET_REVENUE_{filter_region}"'
)
with st.form("Update Target Revenue"):
    df_edited_target = st.experimental_data_editor(
        df_editable_target,
        num_rows="dynamic"
    )
    save_button = st.form_submit_button("Save")

# Write back to table when save button is pressed
if save_button:
    try:
        session.write_pandas(
            df_edited_target,
            f'"TARGET_REVENUE_{filter_region}"',
            database="DEMO_PROGRAMMABLE_2024_STREAMLIT_DB",
            schema="STREAMLIT_APP",
            overwrite=True,
            quote_identifiers=False
        )
        st.success('Target revenue updated!', icon="✅")
        # pause for 2 seconds to give the success message time to show
        time.sleep(2)
        st.experimental_rerun()
    except Exception as e:
        st.warning(f"Error updating target revenue!\n{e}")

# alternative approach to updating the data
with st.expander("Alternative approach to session.write_pandas()"):
    st.markdown(
        """
        > :warning: At the time of writing, using `session.write_pandas()` can only
        > be applied as overwrite (drop and recreate the table) or insert only mode.
        > This is why we have to create a new table to record the target revenue if
        > we want to use the `session.write_pandas()`.
        """
    )
    # show the code below on the app whilst executing it at the same time
    with st.echo():
        # As an alternative, take all the above rows and create as list
        # to insert multiple values to the table
        insert_values = df_edited_target.to_csv(
            header=None,
            index=False
        ).strip('\n').split('\n')
        merge_statement = \
            f"""
            MERGE INTO 
                DEMO_PROGRAMMABLE_2024_STREAMLIT_DB.DATA.TARGET_REVENUE AS tgt
            USING (
                SELECT CAST(MONTH AS DATE) AS MONTH, TARGET_REVENUE
                FROM VALUES {"('" + "), ('".join([sub.replace(",", "',") for sub in insert_values]) + ")"}
                AS tr(MONTH, TARGET_REVENUE)
            ) AS src
            ON tgt.MONTH = src.MONTH
                AND tgt.REGION = '{filter_region}'
            WHEN MATCHED AND NVL(tgt.TARGET_REVENUE,0) <> NVL(src.TARGET_REVENUE,0) THEN
                UPDATE
                SET TARGET_REVENUE = src.TARGET_REVENUE
                    , UPDATED_TS = SYSDATE()
                    , UPDATED_BY = CURRENT_USER()
            WHEN NOT MATCHED THEN
                INSERT (REGION, MONTH, TARGET_REVENUE, UPDATED_TS, UPDATED_BY)
                VALUES ('{filter_region}', src.MONTH, src.TARGET_REVENUE, SYSDATE(), CURRENT_USER())
            """
        st.markdown(f"`{merge_statement}`")
        session.sql(merge_statement).collect()
