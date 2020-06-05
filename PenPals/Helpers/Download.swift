//
//  Download.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/31/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

// get firebase storage and initialize it
let storage = Storage.storage()

//image
func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    //create date string with picture file to make a unique file name
    let dateString = dateFormatter().string(from: Date())
    
    //file path for each image sent
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    //70% of the real image
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    var task: StorageUploadTask!
    
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
        
        //stops listening for changes in storage directory
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("error uploading image \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL { (url, error) in
            
            //have we recieved any downloaded urls
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
            
        }
        
    })
    
    //presents HUD of file % uploaded
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        //Example: 100 mb file has only 10 mb uploaded it'll so 100/10 so 10%
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        
    }
    
}

func downloadImage(imageUrl: String, completion: @escaping(_ image: UIImage?) -> Void) {
    
    //convert image from url to string
    let imageURL = NSURL(string: imageUrl)
    
    print(imageUrl)
    // seperates just the file name away from the rest of the URL
    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    print("file name \(imageFileName)")
    
    //save file locally on device
    // no need to download it every single time
    
    if fileExistsAtPath(path: imageFileName) {
        //exists
        //if we have a file... return it
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
            
            completion(contentsOfFile)
        } else {
            print("couldn't generate image")
            completion(nil)
        }
        
    } else {
        //doesn't exist
        
        //if we don't have a file we download it, save it locally, then return it
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            //get data from url
            let data = NSData(contentsOf: imageURL! as URL)
            
            if data != nil {
                
                var docURL = getDocumentsURL()
                
                //save locally
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                // if you alrady have a file with the same name
                // a temporary file will be created
                //once succesful it will delete the current file
                //if file is corrupt then original file will remain untouched
                data!.write(to: docURL, atomically: true)
                
                let imageToReturn = UIImage(data: data! as Data)
                
                DispatchQueue.main.async {
                    completion(imageToReturn)
                }
                
            } else {
                DispatchQueue.main.async {
                    print("no image in database")
                    completion(nil)
                }
            }
        }
    }
    
}

//video
func uploadVideo(video: NSData, chatRoomId: String, view: UIView, completion: @escaping(_ videoLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    
    var task: StorageUploadTask!
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("error couldn't upload video \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL { (url, error) in
            
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
        }
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        
    }
}

func downloadVideo(videoUrl: String, completion: @escaping(_ isReadyToPlay: Bool, _ videFilename: String) -> Void) {
    
    //convert image from url to string
    let videoURL = NSURL(string: videoUrl)
    
    // seperates just the file name away from the rest of the URL
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    //save file locally on device
    // no need to download it every single time
    
    if fileExistsAtPath(path: videoFileName) {
        //exists
        //if we have a file... return it
        completion(true, videoFileName)
        
    } else {
        //doesn't exist
        
        //if we don't have a file we download it, save it locally, then return it
        let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
        
        downloadQueue.async {
            //get data from url
            let data = NSData(contentsOf: videoURL! as URL)
            
            if data != nil {
                
                var docURL = getDocumentsURL()
                
                //save locally
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                // if you alrady have a file with the same name
                // a temporary file will be created
                //once succesful it will delete the current file
                //if file is corrupt then original file will remain untouched
                data!.write(to: docURL, atomically: true)
                                
                DispatchQueue.main.async {
                    completion(true, videoFileName)
                }
                
            } else {
                DispatchQueue.main.async {
                    print("no video in database")
                }
            }
        }
    }
    
}


//Helpers

func videoThumbnail(video: NSURL) -> UIImage {
    
    //pass through video
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    //generate image fro video
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    //set the time in the video you want to capture to use for thumbnail
    let time = CMTime(seconds: 0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        //try to copy image
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    
    // if it passes generate a UIImage of the cgimage of the thumbnail
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}




func fileInDocumentsDirectory(fileName: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(fileName)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentURL!
    
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
    
}
