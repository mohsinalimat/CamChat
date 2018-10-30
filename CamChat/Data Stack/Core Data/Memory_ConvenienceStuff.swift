//
//  Memory_Convenience.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Photos
import HelpKit
import CoreData


class MemoryActivityItemProvider: UIActivityItemProvider{
    
    private let photoVideoData: PhotoVideoData
    
    init(photoVideoData: PhotoVideoData){
        self.photoVideoData = photoVideoData
        super.init(placeholderItem: FileManager.default.documentsDirectoryUrl)
    }
    
    convenience init(memory: Memory){
        self.init(photoVideoData: memory.info)
    }
    
    override var item: Any{
        return photoVideoData.urls.main
    }
    
    override var activityType: UIActivity.ActivityType?{
        return UIActivity.ActivityType.saveToCameraRoll
    }
    
    
}




extension Memory{
    
    static func getActivityVCFor(memories: [Memory]) -> UIActivityViewController{
        let activitiyItems = memories.map{MemoryActivityItemProvider(memory: $0)}
        return UIActivityViewController(activityItems: activitiyItems, applicationActivities: nil)
    }
    
    static func delete(memories: [Memory]){
        if memories.isEmpty{ return }
        let context = memories.first!.context!
        context.perform {
            for memory in memories {
                memory.info.deleteAllCorrespondingData()
                context.delete(memory)
            }
            context.saveChanges()
        }
        
    }
    
    
    static func saveToCameraRoll(memories: [Memory], completion: @escaping (_ success: Bool) -> Void){
        let photoVideoData = memories.map{$0.info}
        self.saveToCameraRoll(photoVideoData: photoVideoData, completion: completion)
    }
    
    
    
    static func saveToCameraRoll(photoVideoData: [PhotoVideoData], completion: @escaping (_ success: Bool) -> Void){
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized: performCameraRollSaveChanges(for: photoVideoData, completion: completion)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized{self.performCameraRollSaveChanges(for: photoVideoData, completion: completion)}
                else {completion(false)}
            }
        default: completion(false)
        }
    }
    

    private static func performCameraRollSaveChanges(for photoVideoData: [PhotoVideoData], completion: @escaping (_ success: Bool) -> Void){
        PHPhotoLibrary.shared().performChanges({
            
            for data in photoVideoData{
                switch data {
                case .photo(let url, _):
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                case .video(let url, _):
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }
            }
        }, completionHandler: {(wasSuccessful, error) in
            DispatchQueue.main.async {
                completion(wasSuccessful)
            }
        })
    }
    
    static func getFirstFrameImageForVideoAt(url: URL) -> UIImage{
        return getImagesForVideoAt(url: url, atTimes: [0]).first!
    }
    
    
    /// The times should be expressed as percentages of the total video duration.
    static func getImagesForVideoAt(url: URL, atTimes times: [Double]) -> [UIImage]{
        let clip = AVURLAsset(url: url)
        
        let generator = AVAssetImageGenerator(asset: clip)
        
        return times.map({ (time) -> UIImage in
            let duration = generator.asset.duration.seconds
            let cmTime = CMTime(seconds: time * duration , preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
            
            if let cgImage = try? generator.copyCGImage(at: cmTime, actualTime: nil){
                return UIImage(cgImage: cgImage)
            } else { return UIImage() }
        })

    }
    
}





