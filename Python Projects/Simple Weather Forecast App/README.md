
# Weather Forecast Application

This application provides weather forecasts for the next few days using the Streamlit library for the user interface and Plotly for data visualization. The backend fetches weather data from the OpenWeatherMap API.

## Features

- **Input Location**: Users can input a location to receive weather forecasts.
- **Forecast Days**: Users can select the number of forecast days (1 to 5).
- **Data Options**: Users can choose to view either temperature or sky conditions.
- **Data Visualization**: Displays temperature trends using a line graph or sky conditions using icons.

## Requirements

- Python 3.x
- Streamlit
- Plotly
- Requests

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/weather-forecast-app.git
   cd weather-forecast-app
   ```

2. Install the required packages:

   ```bash
   pip install streamlit plotly requests
   ```

3. Add your OpenWeatherMap API key:

   - Replace the placeholder `API_KEY` in `backend.py` with your actual OpenWeatherMap API key.

## Usage

To run the application, use the following command:

```bash
streamlit run main.py
```

