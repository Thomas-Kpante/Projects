Weather Forecast App

Overview

This Weather Forecast App is a SwiftUI-based iOS application developed as part of a school project.
It provides users with current weather conditions and forecasts for the next several days.
Leveraging the OpenWeatherMap API, the app displays temperature, weather conditions, wind speed, humidity, and pressure, along with sunrise and sunset times for a specified location.

Features

Current Weather: Displays temperature, perceived temperature, weather conditions, wind speed, and direction.

Hourly Forecast: Shows weather predictions at specific times (13:00, 16:00, and 19:00) including temperature and conditions.

Sunrise and Sunset Times: Provides the sunrise and sunset times adjusted to the Eastern Time zone.

Additional Details: Humidity and atmospheric pressure are also shown to give a comprehensive view of the weather.

Location-Based Forecasts: Initially set for Ottawa, but can be adjusted to any location supported by the OpenWeatherMap API.


Technologies Used

SwiftUI: For building the user interface in a declarative manner.
OpenWeatherMap API: To fetch weather data based on the user's location.
Swift's URLSession: For making network requests to the OpenWeatherMap API.
JSONDecoder: For parsing the JSON response from the API.
Swift Extensions: For additional functionality, such as converting UNIX timestamps to human-readable formats.

SETUP:

Open the project in Xcode:
Navigate to the cloned directory and open the .xcodeproj file.

Get an API Key:
Sign up at OpenWeatherMap and obtain your API key.

Configure the API Key:
Insert your API key into the appropriate place in the getMeteo() function within the ContentView.swift file.

Run the App:
Select an iOS simulator or connected device and run the app using Xcode.

How to Use
Upon launching the app, the current weather and forecasts for the specified location will be displayed. The app shows weather conditions for the current time and predictions for 13:00, 16:00, and 19:00. Users can view detailed weather information including temperature, weather conditions, wind speed, sunrise and sunset times, humidity, and pressure.

Contributions
This project is the result of a school assignment, and contributions are welcome. Please fork the repository and submit a pull request if you have features or improvements to add.

