//
//  Copyright © 2021 ailinykh.com. All rights reserved.
//

import Foundation
import ImgurCore

final class ImageUploaderMainThreadDecorator: ImageUploader {
    let decoratee: ImageUploader
    
    init(decoratee: ImageUploader) {
        self.decoratee = decoratee
    }
    
    func upload(_ localImage: LocalImage, completion: @escaping (ImageUploader.Result) -> Void) {
        decoratee.upload(localImage) { result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async {
                    completion(result)
                }
                return
            }
            completion(result)
        }
    }
}
