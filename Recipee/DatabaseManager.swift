//
//  DatabaseManager.swift
//  Recipee
//
//  Created by Alex on 05/01/2023.
//

import Foundation
import FirebaseDatabase

class DatabaseManager {
    
    enum DatabaseManagerError: Error {
        case failedToGetData(String)
    }
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private init(){}
    
    private static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    private func userExists(with safeEmail: String, completion: @escaping (Bool) -> ()) {
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard let _ = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func addNewFavourite(with recipe: RecipeResponse, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        userExists(with: safeEmail) { [weak self] exists in
            if !exists {
                self?.database.child(safeEmail).setValue(["\(recipe.id)": [
                    "title": recipe.title,
                    "imageURL": recipe.image ?? ""
                ]]) { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    }
                    completion(true)
                }
            } else {
                self?.database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
                    guard var favourites = snapshot.value as? [String: [String: String]] else {
                        completion(false)
                        return
                    }
                    favourites["\(recipe.id)"] = [
                        "title": recipe.title,
                        "imageURL": recipe.image ?? ""
                    ]
                    self?.database.child(safeEmail).setValue(favourites) { error, _ in
                        if let error = error {
                            completion(false)
                            print(error.localizedDescription)
                        }
                        completion(true)
                    }
                })
            }
        }
    }
    
    public func removeFavourite(with id: Int, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var favourites = snapshot.value as? [String: [String: String]] else {
                completion(false)
                return
            }
            
            favourites.removeValue(forKey: "\(id)")
            
            self?.database.child(safeEmail).setValue(favourites) { error, _ in
                if let error = error {
                    completion(false)
                    print(error.localizedDescription)
                }
                completion(true)
            }
        })
    }
    
    public func isInFavourites(id: Int, email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard let favourites = snapshot.value as? [String: [String: String]] else {
                completion(false)
                return
            }
            completion(favourites.keys.contains("\(id)"))
        })
    }
    
    public func getFavourites(for email: String, completion: @escaping (Result<[RecipeResponse], Error>) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 0 {
                completion(.success([]))
                return
            }
            guard let favourites = snapshot.value as? [String: [String: String]] else {
                completion(.failure(DatabaseManagerError.failedToGetData("Database has different structure than expected.")))
                return
            }
            var recipes = [RecipeResponse]()
            for favourite in favourites {
                guard let id = Int(favourite.key) else {
                    completion(.failure(DatabaseManagerError.failedToGetData("Key is not a number.")))
                    return
                }
                
                guard let title = favourite.value["title"] else {
                    completion(.failure(DatabaseManagerError.failedToGetData("There is no key with name \"title\".")))
                    return
                }
                
                guard let imageURL = favourite.value["imageURL"] else {
                    completion(.failure(DatabaseManagerError.failedToGetData("There is no key with name \"imageURL\".")))
                    return
                }
                
                recipes.append(RecipeResponse(id: id, title: title, image: imageURL))
            }
            completion(.success(recipes))
        })
    }
}
