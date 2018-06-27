//
//  FileUnit.swift
//  Full Application Tasker
//
//  Created by Muhammad Fatani on 26/06/2018.
//  Copyright © 2018 Muhammad Fatani. All rights reserved.
//

import Foundation
class FileUnit {
    
    static func getTempPath(fileName:String) -> URL{
        return URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
    }
    
    static func removeContentInTmpDir (){
        DispatchQueue.global(qos: .utility).async {
            FileManager.default.clearTmpDirectory()
        }
    }
    
    static func getRealPath(fileName:String) -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    static func isFileExists(name:String, fileExtension:String)-> URL? {
        let TAG = "FileUnit_isFileExists"
        
        let fm = FileManager.default;
        let documentsUrls = fm.urls(for: .documentDirectory, in: .userDomainMask);
        Logger.normal(tag: TAG, message: "documentsUrls: \(documentsUrls)")
        if let documentUrl = documentsUrls.first {
            do {
                let directoryContents = try fm.contentsOfDirectory(at: documentUrl, includingPropertiesForKeys: nil, options: [])
                Logger.normal(tag: TAG, message: "directoryContents: \(directoryContents)")
                
                let targetFiles = directoryContents.filter{ $0.pathExtension == fileExtension }
                let targetFilesNames = targetFiles.map{ $0.deletingPathExtension().lastPathComponent }
                Logger.normal(tag: TAG, message: "target files: \(targetFilesNames)")
                
                let size = targetFiles.count
                for i in 0..<size {
                    if targetFilesNames[i] == name {
                        return targetFiles[i]
                    }
                }
                
            } catch let error as NSError {
                Logger.error(tag: TAG, message: error)
                return nil
            }
        }
        
        return nil
    }
    
    static func removeAllFileBy(fileExtension:String){
        let TAG = "FileUnit_removeAllAudioFile"
        
        let fm = FileManager.default
        let documentsUrls = fm.urls(for: .documentDirectory, in: .userDomainMask);
        if let documentUrl = documentsUrls.first {
            do {
                let directoryContents = try fm.contentsOfDirectory(at: documentUrl, includingPropertiesForKeys: nil, options: [])
                Logger.normal(tag: TAG, message: "directoryContents: \(directoryContents)")
                
                let targetFiles = directoryContents.filter{ $0.pathExtension == fileExtension }
                Logger.normal(tag: TAG, message: "target files: \(targetFiles)")
                
                DispatchQueue.global(qos: .utility).async {
                    for targetFile in targetFiles {
                        try? fm.removeItem(at: targetFile)
                    }
                }
            } catch let error as NSError {
                Logger.error(tag: TAG, message: error)
            }
        }
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
