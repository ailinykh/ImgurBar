//
//  Copyright © 2022 ailinykh.com. All rights reserved.
//

import Foundation

public protocol AlbumLoader {
    func load(for account: Account, completion: @escaping (Result<[Album], Error>) -> Void)
}
