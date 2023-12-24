import streamlit as st

st.set_page_config(
    page_title = "Test Streamlit with Sidebar",
    layout = "wide"
)

st.markdown("""
    <style>
        .st-emotion-cache-czk5ss.e16jpq800{
            visibility: hidden;
        }
        .st-emotion-cache-10pw50.ea3mdgi1{
            visibility: hidden;
        }
    </style>
""",unsafe_allow_html=True
)

st.title("Streamlit Title")
st.header("Streamlit Header")
