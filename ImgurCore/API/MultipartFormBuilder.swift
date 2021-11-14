//
//  MultipartFormBuilder.swift
//  ImgurCore
//
//  Created by Anton Ilinykh on 14.11.2021.
//  Copyright © 2021 Anton Ilinykh. All rights reserved.
//

import Foundation

public final class MultipartFormBuilder: RequestBuilder {
    private let EOL = "\r\n"
    
    public init() {}
    
    public func makeRequest(for fileUrl: URL) throws -> URLRequest {
        let boundary = makeBoundary()
        let data = try data(for: fileUrl, using: boundary)
        var request = URLRequest(url: fileUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
        return request
    }
    
    private func makeBoundary() -> String {
        let rand = { UInt32.random(in: (.min)...(.max)) }
        return String(format: "--------%08X%08X", rand(), rand())
    }
    
    private func data(for fileUrl: URL, using boundary: String) throws -> Data {
        let filename = fileUrl.lastPathComponent
        let mime = mimeType(for: fileUrl)
        let data = try Data(contentsOf: fileUrl)
        var body = Data()
        body.append(makeData("--" + boundary + EOL))
        body.append(makeData("Content-Disposition: form-data; name=\"image\"; filename=\"" + filename + "\"" + EOL))
        body.append(makeData("Content-Type: " + mime + EOL + EOL))
        body.append(data)
        body.append(makeData(EOL + "--" + boundary + "--" + EOL))
        return body
    }
    
    private func makeData(_ from: String) -> Data {
        from.data(using: .utf8)!
    }
    
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
