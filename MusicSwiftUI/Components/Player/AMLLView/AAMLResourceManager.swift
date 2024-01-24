//
//  AAMLResourceManager.swift
//
//
//  Created by YICHAO LI on 2024/1/1.
//

import Foundation

// MARK: shared
public class AMLLResourceManager {
    public static let shared = AMLLResourceManager()
}

extension AMLLResourceManager {
    // Combine
    public func handlerLrc(urlType: LyricURLType, URL: URL, coderType: String.Encoding = .utf8, withExtraInfo: Bool = true) async throws -> [LrcLyric] {
        do {
            var fileData : Data? = nil
            if urlType == .remote {
                let downloadURL = try await downloadFile(remoteURL: URL)
                fileData        = try await readFileFromCache(url: downloadURL)
            } else {
                fileData        = try await readFileFromURL(url: URL)
            }
            guard let fileData = fileData else { throw NSError(domain: "File data is Empty", code: 0, userInfo: nil) }
            let songLrcLyrics   = try await decodeLrcFileData(lrcData: fileData, coderType: coderType, withExtraInfo: withExtraInfo)
            return songLrcLyrics
        } catch {
            throw error
        }
    }
    
    // Handle Lrc File -- remoteURL
    // Default .UTF8 + WithExtraInfo
    public func handlerLrcDecode(remoteURL: URL, coderType: String.Encoding = .utf8, withExtraInfo: Bool = true) async throws -> [LrcLyric] {
        do {
            let downloadURL     = try await downloadFile(remoteURL: remoteURL)
            let fileData        = try await readFileFromCache(url: downloadURL)
            let songLrcLyrics   = try await decodeLrcFileData(lrcData: fileData, coderType: coderType, withExtraInfo: withExtraInfo)
            return songLrcLyrics
        } catch {
            throw error
        }
    }
    
    // handle Lrc File -- localURL
    // Default .UTF8 + WithExtraInfo
    public func handlerLrcDecode(localURL: URL, coderType: String.Encoding = .utf8, withExtraInfo: Bool = true) async throws -> [LrcLyric] {
        do {
            let fileData        = try await readFileFromURL(url: localURL)
            let songLrcLyrics   = try await decodeLrcFileData(lrcData: fileData, coderType: coderType, withExtraInfo: withExtraInfo)
            return songLrcLyrics
        } catch {
            throw error
        }
    }
}


extension AMLLResourceManager {
    public func handleTtml(urlType: LyricURLType, URL: URL, coderType: String.Encoding = .utf8)  async throws -> [TtmlLyric] {
        do {
            var fileData : Data? = nil
            if urlType == .remote {
                let downloadURL = try await downloadFile(remoteURL: URL)
                fileData        = try await readFileFromCache(url: downloadURL)
            } else {
                fileData        = try await readFileFromURL(url: URL)
            }
            guard let fileData = fileData else { throw NSError(domain: "File data is Empty", code: 0, userInfo: nil) }
            let decodeData = try await TTMLParser().decodeTtml(data: fileData, coderType: .utf8)
            return decodeData
        } catch {
            throw error
        }
    }
}

// MARK: Network
extension AMLLResourceManager {
    private enum AMLLNetworkError : Error {
        case invalidUrl
    }
    
    private func downloadFile(remoteURL: URL) async throws -> URL {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationURL = cacheDirectory.appendingPathComponent(remoteURL.lastPathComponent)
        // Check if file exists in cache
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw error
            }
        }
        // Download
        let session = URLSession.shared
        let (fileURL, _) = try await session.download(from: remoteURL)
        do {
            try FileManager.default.moveItem(at: fileURL, to: destinationURL)
            return destinationURL
        } catch {
            throw error
        }
    }
    
    public func clearCache() {
        do {
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileManager = FileManager.default
            let cacheFiles = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            for file in cacheFiles {
                try fileManager.removeItem(at: file)
            }
            debugPrint("Cache cleared")
        } catch {
            debugPrint("Error clearing cache: \(error.localizedDescription)")
        }
    }
}

// MARK: Read File
extension AMLLResourceManager {
    // From FileSystem
    func readFileFromURL(url: URL?) async throws -> Data {
        guard let url = url else {
            throw AMLLNetworkError.invalidUrl
        }
        let fileData = try Data(contentsOf: url)
        return fileData
    }
    
    // From Cache
    private func readFileFromCache(url: URL?) async throws -> Data {
        guard let url = url else {
            throw AMLLNetworkError.invalidUrl
        }
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        // Check if file exists in cache
        if !fileManager.fileExists(atPath: fileURL.path) {
            throw NSError(domain: "File not found in cache", code: 0, userInfo: nil)
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw error
        }
    }
}

extension AMLLResourceManager {
    private func decodeLrcFileData(lrcData: Data, coderType: String.Encoding, withExtraInfo: Bool) async throws -> [LrcLyric] {
        try await withCheckedThrowingContinuation { continuation in
            let stream = InputStream(data: lrcData)
            var data = Data()
            stream.open()
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            while stream.hasBytesAvailable {
                let read = stream.read(buffer, maxLength: bufferSize)
                if read > 0 {
                    data.append(buffer, count: read)
                } else {
                    break
                }
            }
            stream.close()
            buffer.deallocate()
            
            if let lyrics = String(data: data, encoding: coderType) {
                let parsedLyrics = decodeSongLyricsToParserText(songLyrics: lyrics, withExtraInfo: withExtraInfo)
                continuation.resume(returning: parsedLyrics)
            } else {
                continuation.resume(throwing: NSError(domain: "String decoding error", code: 0, userInfo: nil))
            }
        }
    }
    
    private func decodeSongLyricsToParserText(songLyrics : String, withExtraInfo: Bool) -> [LrcLyric]{
        var resArray: [LrcLyric] = []
        var indexNum = 0

        let parser = LrcLyricsParser(lyrics: songLyrics)
        
        // MARK: Title/Author/Album/By/Editor
        if (withExtraInfo) {
            // Title
            if parser.header.title != "" && parser.header.title != nil {
                resArray.append(LrcLyric(indexNum: indexNum,lyric: parser.header.title!,  time: 0.0))
                indexNum = indexNum + 1
            }
            // Author
            if parser.header.author != "" && parser.header.author != nil {
                resArray.append(LrcLyric(indexNum: indexNum, lyric: String(parser.header.author!), time: 0.0))
                indexNum = indexNum + 1
            }
            // Album
            if parser.header.album != "" && parser.header.album != nil {
                resArray.append(LrcLyric(indexNum: indexNum, lyric: parser.header.album!, time: 0.0))
                indexNum = indexNum + 1
            }
            // By
            if parser.header.by != "" && parser.header.by != nil {
                resArray.append(LrcLyric(indexNum: indexNum, lyric: parser.header.by!, time: 0.0))
                indexNum = indexNum + 1
            }
            // Editor
            if parser.header.editor != "" && parser.header.editor != nil {
                resArray.append(LrcLyric(indexNum: indexNum, lyric: parser.header.editor!, time: 0.0))
                indexNum = indexNum + 1
            }
        }
        // MARK: Lyrics
        for lyric in parser.lyrics {
            if lyric.time > 0 {
                resArray.append(LrcLyric(indexNum: indexNum,lyric: lyric.text, time: lyric.time))
                indexNum = indexNum + 1
            }
            
        }
        
        return resArray
    }
}
