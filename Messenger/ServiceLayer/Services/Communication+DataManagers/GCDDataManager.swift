//
//  GCDDataManager.swift
//  Messenger
//
//  Created by Иван Базаров on 21.10.2018.
//  Copyright © 2018 Иван Базаров. All rights reserved.
//

import Foundation

struct GCDDataManager {
    let syncQueue = DispatchQueue(label: "com.IvanBazarov", qos: .userInitiated)
    let documentsDirectory: URL
    let archiveURL: URL
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory.appendingPathComponent("user_profile").appendingPathExtension("plist")
    }
    func saveNameWith(_ name: String) {
        UserDefaults.standard.set(name, forKey: "user_name")
    }
    func saveDescriptionWith(_ description: String) {
        UserDefaults.standard.set(description, forKey: "user_description")
    }
    func saveImageWith(_ imageData: Data) throws {
        do {
            try imageData.write(to: archiveURL, options: .noFileProtection)
        } catch let error {
            throw error
        }
    }
    func getProfile(completion: @escaping CompletionProfileLoader) {
        syncQueue.async {
            let name = UserDefaults.standard.string(forKey: "user_name") ?? ""
            let description = UserDefaults.standard.string(forKey: "user_description") ?? "Нет данных в профиле"
            let imageData: Data = (try? Data(contentsOf: self.archiveURL))
                ?? UIImage(named: "placeholder-user")!.jpegData(compressionQuality: 1.0)!
            let profile = UserProfile(name: name, description: description, userImageData: imageData)
            DispatchQueue.main.async {
                completion(profile)
            }
        }
    }
    func saveProfile(old: IProfile, new profile: IProfile, completion: @escaping CompletionSaveHandler) {
        syncQueue.async {
            if profile.name != old.name {
                self.saveNameWith(profile.name)
            }
            if profile.description != old.description {
                self.saveDescriptionWith(profile.description)
            }
            if profile.userImageData != old.userImageData {
                do {
                    try self.saveImageWith(profile.userImageData)
                } catch let error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

}
