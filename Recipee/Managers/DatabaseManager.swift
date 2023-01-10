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
    
    private func foldersForUserExists(with safeEmail: String, completion: @escaping (Bool) -> ()) {
        database.child(safeEmail).child("folders").observeSingleEvent(of: .value) { snapshot in
            guard let _ = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func isInFavourites(id: Int, email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").child("favourites").observeSingleEvent(of: .value, with: { snapshot in
            guard let favourites = snapshot.value as? [String: [String: String]] else {
                completion(false)
                return
            }
            completion(favourites.keys.contains("\(id)"))
        })
    }
    
    public func addNewFolder(with title: String, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        folderExists(with: title, for: email, completion: { [weak self] folderExists in
            if !folderExists {
                self?.userExists(with: safeEmail) { userExists in
                    self?.foldersForUserExists(with: safeEmail) { foldersExists in
                        if !userExists {
                            self?.database.child(safeEmail).setValue(["folders": [title: [
                                "id": [
                                    "title": "title_name",
                                    "imageURL": "url"
                                ]
                            ]]]) { error, _ in
                                if let error = error {
                                    print(error.localizedDescription)
                                    completion(false)
                                }
                                completion(true)
                            }
                        } else if !foldersExists {
                            self?.database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
                                guard var all = snapshot.value as? [String: Any] else {
                                    completion(false)
                                    return
                                }
                                all["folders"] = [
                                    title: [
                                        "id": [
                                            "title": "title_name",
                                            "imageURL": "url"
                                        ]
                                    ]
                                ]
                                self?.database.child(safeEmail).setValue(all) { error, _ in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        completion(false)
                                    }
                                    completion(true)
                                }
                            })
                        } else {
                            self?.database.child(safeEmail).child("folders").observeSingleEvent(of: .value, with: { snapshot in
                                guard var folders = snapshot.value as? [String: [String: [String: String]]] else {
                                    completion(false)
                                    return
                                }
                                folders[title] =
                                ["id":
                                    [
                                        "title": "title_name",
                                        "imageURL": "url"
                                    ]
                                ]
                                self?.database.child(safeEmail).child("folders").setValue(folders) { error, _ in
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
            } else {
                completion(true)
            }
        })
    }
    
    private func folderExists(with title: String, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").child(title).observeSingleEvent(of: .value) { snapshot in
            guard let _ = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func removeFolder(with title: String, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var folders = snapshot.value as? [String: [String: [String: String]]] else {
                completion(false)
                return
            }
            
            folders.removeValue(forKey: title)
            
            self?.database.child(safeEmail).child("folders").setValue(folders) { error, _ in
                if let error = error {
                    completion(false)
                    print(error.localizedDescription)
                }
                completion(true)
            }
        })
    }
    
    public func removeRecipe(with id: Int, from folderName: String, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").child(folderName).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var folder = snapshot.value as? [String: [String: String]] else {
                completion(false)
                return
            }
            folder.removeValue(forKey: "\(id)")
            self?.database.child(safeEmail).child("folders").child(folderName).setValue(folder) { error, _ in
                if let error = error {
                    completion(false)
                    print(error.localizedDescription)
                }
                completion(true)
            }
        })
    }
    
    public func getFolders(for email: String, completion: @escaping (Result<[FoldersViewModel], Error>) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 0 {
                completion(.success([]))
                return
            }
            guard let folders = snapshot.value as? [String: [String: [String: String]]] else {
                completion(.failure(DatabaseManagerError.failedToGetData("Database has different structure than expected.")))
                return
            }
            let folderNames = folders.compactMap { folder in
                return folder.key
            }.filter { folderName in
                folderName != "favourites"
            }
            
            var model = [FoldersViewModel]()
            for title in folderNames {
                guard let image = folders[title]?.first(where: { recipe in
                    recipe.key != "id"
                })?.value["imageURL"] else {
                    model.append(FoldersViewModel(image: "", title: title))
                    continue
                }
                model.append(FoldersViewModel(image: image, title: title))
            }
            
            completion(.success(model))
        })
    }
    
    public func getFolder(with title: String, for email: String, completion: @escaping (Result<[RecipeResponse], Error>) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("folders").child(title).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                completion(.success([]))
                return
            }
            guard let folder = snapshot.value as? [String: [String: String]] else {
                completion(.failure(DatabaseManagerError.failedToGetData("Database has different structure than expected.")))
                return
            }
            var recipes = [RecipeResponse]()
            for recipe in folder {
                if let id = Int(recipe.key) {
                    guard let title = recipe.value["title"] else {
                        completion(.failure(DatabaseManagerError.failedToGetData("There is no key with name \"title\".")))
                        return
                    }
                    
                    guard let imageURL = recipe.value["imageURL"] else {
                        completion(.failure(DatabaseManagerError.failedToGetData("There is no key with name \"imageURL\".")))
                        return
                    }
                    
                    recipes.append(RecipeResponse(id: id, title: title, image: imageURL))
                } else if recipe.key != "id" {
                    completion(.failure(DatabaseManagerError.failedToGetData("The key is not a number.")))
                }
            }
            completion(.success(recipes))
        })
    }
    
    public func addRecipe(_ recipe: RecipeResponse, to folderName: String, for email: String, completion: @escaping (Bool) -> ()) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        addNewFolder(with: folderName, for: email) { [weak self] success in
            if success {
                self?.database.child(safeEmail).child("folders").child(folderName).observeSingleEvent(of: .value, with: { snapshot in
                    guard var folder = snapshot.value as? [String: [String: String]] else {
                        completion(false)
                        return
                    }
                    
                    folder["\(recipe.id)"] = [
                        "title": recipe.title,
                        "imageURL": recipe.image ?? ""
                    ]
                    
                    self?.database.child(safeEmail).child("folders").child(folderName).setValue(folder) { error, _ in
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
}
