//
//  APICaller.swift
//  Recipee
//
//  Created by Alex on 28/12/2022.
//

import Foundation

class APICaller {
    
    struct Constants {
        static let apiKey = ""
        static let baseApiURL = "https://api.spoonacular.com/"
    }
    
    enum APICallerError: Error {
        case failedToGetData(String)
        case failedToDecodeData(String)
    }
    
    static let shared = APICaller()
    
    private init(){}
    
    public func getRandomRecipes(number: Int, completion: @escaping (Result<[RecipeResponse], APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/random?apiKey=\(Constants.apiKey)&number=\(number)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(RecipesResponse.self, from: data)
                completion(.success(result.recipes))
            } catch {
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
    
    public func getMealType(type: String, completion: @escaping (Result<[RecipeResponse], APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/complexSearch?apiKey=\(Constants.apiKey)&number=8&type=\(type)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
    
    public func getCusine(cuisine: String, completion: @escaping (Result<[RecipeResponse], APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/complexSearch?apiKey=\(Constants.apiKey)&number=8&cuisine=\(cuisine)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
    
    public func getMaxReadyTime(maxReadyTime: Int, completion: @escaping (Result<[RecipeResponse], APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/complexSearch?apiKey=\(Constants.apiKey)&number=8&maxReadyTime=\(maxReadyTime)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
    
    public func getRecipesWithOptions(options: String, completion: @escaping (Result<[RecipeResponse], APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/complexSearch?apiKey=\(Constants.apiKey)&number=20\(options)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
    
    public func getRecipeInfo(id: Int, completion: @escaping (Result<RecipeInfoResponse, APICallerError>) -> ()) {
        let urlString = "\(Constants.baseApiURL)recipes/\(id)/information?apiKey=\(Constants.apiKey)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToGetData(error!.localizedDescription)))
                return
            }
            do {
                let result = try JSONDecoder().decode(RecipeInfoResponse.self, from: data)
                completion(.success(result))
            } catch {
                print(error)
                completion(.failure(.failedToDecodeData(error.localizedDescription)))
            }
        }.resume()
    }
}
