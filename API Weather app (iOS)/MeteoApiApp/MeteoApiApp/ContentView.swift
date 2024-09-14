//
//  ContentView.swift
//  DevoirSemaine8
//
//  Created by user933722 on 3/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var weather: WeatherData?
    
    func forecastAtHour(_ hour: Int) -> Forecast? {
        let calendar = Calendar.current
        return weather?.list.first(where: { forecast in
            guard let date = Int(forecast.dt).toDate() else { return false }
            let forecastHour = calendar.component(.hour, from: date)
            return forecastHour == hour
        })
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors:[.blue, .blue, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack{
                
                HStack{
                    Text("\(weather?.city.name ?? " "), \(weather?.city.country ?? " ")")
                        .font(.system(size: 30))
                    
                }
                .padding(.top, 50)
                .foregroundColor(.white)
                Spacer()
                
                HStack(spacing: 30){
                    Image(systemName: systemImageNameForIcon(icon: weather?.list.first?.weather.first?.icon ?? ""))
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130)
                    
                    VStack(alignment: .leading){
                        Text("\(weather?.list.first?.main.tempCelsius ?? 0) °C")
                            .font(.system(size: 30))
                        Text("T. ressentie: \(weather?.list.first?.main.feelsLikeCelsius ?? 0) °C")
                        Text("\(weather?.list.first?.weather.first?.description ?? "")")
                            .bold()
                        
                        Text("Vent: \(weather?.list.first?.wind.cardinalDirection ?? "") \(Int(weather?.list.first?.wind.speedKmH ?? 0)) km/h")

                    }
                    .foregroundColor(.white)
                    
                    
                }
                Spacer()
                
                VStack{
                    HStack {
                            ForEach([13, 16, 19], id: \.self) { hour in
                                if let forecast = forecastAtHour(hour) {
                                    let iconName = systemImageNameForIcon(icon: forecast.weather.first?.icon ?? "")
                                    let temperature = Int(forecast.main.tempCelsius)
                                    MeteoParHeure(imageName: iconName, heure: "\(hour):00", temperature: temperature)
                                }
                            }
                        }
                    
                    VStack(spacing: 0){
                        
                        
                        HStack {
                            Image(systemName: "sun.haze.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            Text("Lever - Coucher")
                            
                            Spacer()
                            
                            Text("\(weather?.city.sunriseTime ?? "N/a") - \(weather?.city.sunsetTime ?? "N/a")")
                            
                        }
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        
                        Divider()
                            .background(Color.blue)
                        
                        HStack {
                            Image(systemName: "humidity.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            Text("Humidité")
                            
                            Spacer()
                            Text("\(weather?.list.first?.main.humidity ?? 0) %")
                            
                        }
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        
                        Divider()
                            .background(Color.blue)
                        
                        HStack {
                            Image(systemName: "barometer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            Text("Pression")
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", weather?.list.first?.main.pressureInKPa ?? 0)) kPa")
                              
                        }
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        
                        
                        .task{
                            do{
                                weather = try await getMEteo()
                            } catch WeatherError.invalideUrl{
                                print("Error: invalid URL")
                            }
                            catch WeatherError.invalidResponse{
                                print("Error: invalid Response")
                            }
                            catch WeatherError.invalidData{
                                print("Error: invalid Data")
                            } catch {
                                print("Error...")
                            }
                        }
                    }
                }
                
                
                Spacer()
             
                
                Image("logoLaCite")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 50)
                    
                
            }
            .padding()
            
            
           
        }
        
        
       
    }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct MeteoParHeure: View {
    var imageName: String
    var heure: String
    var temperature: Int
    
    var body: some View {
        HStack(spacing: 20){
            Image(systemName: imageName)
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            
            VStack(spacing: 5){
                Text(heure)
                Text("\(temperature) °C")
                
            }
            
        }
        .padding(5)
        .background(Color.gray.opacity(0.7))
        
    }
}


func getMEteo() async throws -> WeatherData {
    let endpoint = "https://api.openweathermap.org/data/2.5/forecast?q=Gatineau&lang=fr&appid=4a53d1264dd12864229958843cf83634"
    
 
    
    guard let url = URL(string: endpoint) else{
        throw WeatherError.invalideUrl
    }
    
    let (data, reponse) = try await URLSession.shared.data(from: url)
    
    guard let reponse = reponse as? HTTPURLResponse, reponse.statusCode == 200 else{
        throw WeatherError.invalidResponse
    }
    
    do{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WeatherData.self, from: data)
    } catch {
        throw WeatherError.invalidData
    }
    
}

enum WeatherError: Error{
    case invalideUrl
    case invalidResponse
    case invalidData
}



struct WeatherData: Codable {
    var city: City
    var list: [Forecast]
}

struct City: Codable {
    var name: String
    var country: String
    var sunrise: Int
    var sunset: Int
    
    // Converts UNIX timestamp to HH:MM format
    func timeFromUnix(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    var sunriseTime: String {
        return timeFromUnix(unixTime: sunrise)
    }
    
    var sunsetTime: String {
        return timeFromUnix(unixTime: sunset)
    }
}

struct Forecast: Codable {
    var main: Main
    var weather: [Weather]
    var wind: Wind
    var dtTxt: String
    var dt: Int
    var clouds: Clouds
    var pop: Double
    var visibility: Int
    var sys: Sys
    
    struct Weather: Codable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }
    
    struct Clouds: Codable {
        var all: Int
    }
    
    struct Sys: Codable {
        var pod: String
    }
}

struct Main: Codable {
    var temp: Double
    var feelsLike: Double
    var pressure: Double
    var humidity: Int
    
    // temperature from Kelvin to Celsius
    var tempCelsius: Int {
        return Int(temp - 273.15)
    }

    // "feels like" temperature from Kelvin to Celsius
    var feelsLikeCelsius: Int {
        return Int(feelsLike - 273.15)
    }
    
    // pressure from hPa to kPa
    var pressureInKPa: Double {
        return pressure / 10.0
    }
}

struct Wind: Codable {
    var speed: Double
    var deg: Int
    
    // Converts wind speed from m/s to km/h
    var speedKmH: Int {
        return Int(speed * 3.6)
    }
    
    // Converts degrees to cardinal directions
    var cardinalDirection: String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]
        let index = Int((Double(deg) + 11.25)/22.5)
        return directions[index % 16]
    }
}

func systemImageNameForIcon(icon: String) -> String {
    switch icon {
    case "01d", "01n":
        return "sun.max.fill" // clear sky
    case "02d", "02n":
        return "cloud.sun.fill" // few clouds
    case "03d", "03n":
        return "cloud.fill" // scattered clouds
    case "04d", "04n":
        return "smoke.fill" // broken clouds
    case "09d", "09n":
        return "cloud.drizzle.fill" // shower rain
    case "10d", "10n":
        return "cloud.rain.fill" // rain
    case "11d", "11n":
        return "cloud.bolt.rain.fill" // thunderstorm
    case "13d", "13n":
        return "snowflake" // snow
    case "50d", "50n":
        return "cloud.fog.fill" // mist
    default:
        return "questionmark.diamond.fill" // default or unknown case
    }
}

extension Int {
    func toDate() -> Date? {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}
