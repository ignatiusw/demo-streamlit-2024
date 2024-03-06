# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

st.title("Some Streamlit in Snowflake Limitations")

url = "https://raw.githubusercontent.com/ignatiusw/demo-streamlit-2024/main/data/demo_data.csv"

st.header("No access to the Internet")
# test load data from internet
import pandas as pd
try:
    df = pd.read_csv(url)
    st.dataframe(df)
except Exception as e:
    st.error(e)

# test internet request
from urllib import request
try:
    result = request.urlopen(url, timeout=1)
    st.write(result)
except Exception as e:
    st.error(e)

st.header("Limited Python libraries")
# test import other libraries
try:
    # pydeck: Large-scale interactive data visualization in Python
    # https://pypi.org/project/pydeck/
    import pydeck
except Exception as e:
    st.error(e)

st.header("No secondary roles")
# Secondary roles doesn't work
# eventhough the default = ALL
session = get_active_session()

df = session.sql("SELECT * FROM DATA.REVENUE").to_pandas()

st.dataframe(df)
