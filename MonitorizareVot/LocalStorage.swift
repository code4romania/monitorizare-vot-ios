//
//  LocalStorage.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 21/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum LocalFilename {
    case provinces
    case forms
    case form(id: Int)
    
    var fullName: String {
        var name: String
        switch self {
        case .provinces:        name = "provinces"
        case .forms:            name = "forms"
        case .form(let id):     name = "form-details-\(id)"
        }
        return name + ".json"
    }
}

protocol LocalStorageType: NSObject {
    
    var provinces: [ProvinceResponse]? { set get }
    var forms: [FormResponse]? { set get }

    func getProvince(withCode code: String) -> ProvinceResponse?
    func getFormSummary(withCode code: String) -> FormResponse?
    func loadForm(withId formId: Int) -> [FormSectionResponse]?
    func saveForm(_ form: [FormSectionResponse], withId formId: Int)
    
    func deleteAllData()
}

/// This class is used as an entry point for storing data that is overwritten from server.
/// The data returned by methods of this class is a replica of responses that come from the API
/// and works mainly as a cache of real data.
/// It stores the data in the cache directory as JSON files (which is exactly what comes from the server)
class LocalStorage: NSObject, LocalStorageType {
    
    static let shared: LocalStorageType = LocalStorage()
    
    // MARK: - Public
    
    var provinces: [ProvinceResponse]? {
        set {
            if let newValue = newValue {
                save(codable: newValue, withFilename: .provinces)
            } else {
                delete(fileWithName: .provinces)
            }
        } get {
            return load(type: [ProvinceResponse].self, withFilename: .provinces)
        }
    }
    
    var forms: [FormResponse]? {
        set {
            if let newValue = newValue {
                save(codable: newValue, withFilename: .forms)
            } else {
                delete(fileWithName: .forms)
            }
        } get {
            return load(type: [FormResponse].self, withFilename: .forms)
        }
    }
    
    func loadForm(withId formId: Int) -> [FormSectionResponse]? {
        return load(type: [FormSectionResponse].self, withFilename: .form(id: formId))
    }
    
    func saveForm(_ form: [FormSectionResponse], withId formId: Int) {
        save(codable: form, withFilename: .form(id: formId))
    }
    
    func getFormSummary(withCode code: String) -> FormResponse? {
        guard let forms = forms else { return nil }
        return forms.filter { $0.code == code }.first
    }
    
    func getProvince(withCode code: String) -> ProvinceResponse? {
        guard let provinces else { return nil }
        return provinces.filter { $0.code == code }.first
    }

    /// Call this to delete all local data. This can be useful on db clear for example
    func deleteAllData() {
        let url = URL(fileURLWithPath: containerDirectory)
        do {
            try FileManager.default.removeItem(at: url)
            DebugLog("Deleted all local app data.")
        } catch {
            DebugLog("Error: could not delete app data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Internal
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate var containerDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = paths.first!.appending("/app_data")
        return path
    }
    
    private func ensureContainerDirectoryExists() -> Bool {
        let fm = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        var shouldCreateDirectory = false
        if fm.fileExists(atPath: containerDirectory, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return true
            } else {
                deleteAllData()
                shouldCreateDirectory = true
            }
        } else {
            shouldCreateDirectory = true
        }
        
        if shouldCreateDirectory {
            do {
                try fm.createDirectory(
                    atPath: containerDirectory,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
                DebugLog("Created local app data directory at \(containerDirectory)")
            } catch {
                DebugLog("Error: Could not create app data directory: \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }

    fileprivate func load<T>(type: T.Type, withFilename filename: LocalFilename) -> T? where T: Decodable {
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            let data = try Data(contentsOf: fileUrl)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            DebugLog("Error loading file at \(fileUrl): \(error.localizedDescription)")
            return nil
        }
    }
    
    fileprivate func save<T>(codable: T, withFilename filename: LocalFilename) where T: Encodable {
        guard ensureContainerDirectoryExists() else { return }
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            let data = try JSONEncoder().encode(codable)
            try data.write(to: fileUrl)
        } catch {
            DebugLog("Error saving file to \(fileUrl): \(error.localizedDescription)")
        }
    }
    
    fileprivate func delete(fileWithName filename: LocalFilename) {
        guard ensureContainerDirectoryExists() else { return }
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            DebugLog("Error deleting file at \(fileUrl): \(error.localizedDescription)")
        }
    }
    
}


