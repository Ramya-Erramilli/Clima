//
//  WeatherManager.swift
//  Clima
//
//  Created by Ramya Seshagiri on 17/05/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, weather : WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=93f2c9dc6a0bdff7a8f553f3d046cb56&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        
        let urlString = "\(weatherURL)&q=\(cityName)"
//        print(cityName)
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString:String){
        
        //1.Create a URL
       
        if let url = URL(string: urlString){
            //2. Create URL Session
            
            let session = URLSession(configuration: .default)
            
            //3. Give Session to Task
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error !=  nil{
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
//                print(response)
                if let safeData = data{
                    
                    if let weather = self.parseJson(safeData){
                        
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    //                    let dataString = String(data: safeData, encoding: .utf8)
                    //                    print(dataString!)
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    
    func parseJson(_ weatherData: Data)->WeatherModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try  decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temp: temp)
//            print("here")
            return weather
            
        } catch{
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
            
        }
        
    }

}
