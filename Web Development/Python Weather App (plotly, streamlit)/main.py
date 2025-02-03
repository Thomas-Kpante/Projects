import streamlit as st
import plotly.express as px
from backend import get_data

# Add title, text input, slider, selectbox, and subheader
st.title("Weather Forecast for the Next Days")
place = st.text_input("Place: ")
days = st.slider("forecast days", min_value=1, max_value=5)
option = st.selectbox("Select data to view", ["Temperature", "Sky"])

st.header(f"{option} for the next {days} days in {place}")


if place:
    # Get the temperature/sky data
    try:
        filtered_data = get_data(place, days)



        if option == "Temperature":
            temperatures = [dict["main"]["temp"]/10 for dict in filtered_data]
            dates = [dict["dt_txt"] for dict in filtered_data]
            # Create a temperature plot
            figure = px.line(x=dates, y=temperatures, labels={"x": "Date", "y": "Temerature (C)"})
            st.plotly_chart(figure)

        if option == "Sky":
            images = {"Clear": "images/clear.png",
                      "Clouds": "images/cloud.png",
                      "Rain": "images/rain.png",
                      "Snow": "images/snow.png"}
            sky_condition = [dict["weather"][0]["main"] for dict in filtered_data]
            image_paths = [images[condition] for condition in sky_condition]
            st.image(image_paths, width=80)
    except KeyError:
        st.info("ENTER VALID PLACE")