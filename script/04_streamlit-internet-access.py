# Import python packages
import streamlit as st

url = "https://raw.githubusercontent.com/ignatiusw/demo-streamlit-2024/main/data/demo_data.csv"

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
