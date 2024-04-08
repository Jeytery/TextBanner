//
//  GithubStorageService.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 08.04.2024.
//

import Foundation

class GitHubStorageService<CodableType: Codable> {
    private let remoteStorageUrl: String
    
    init(remoteStorageUrl: String) {
        self.remoteStorageUrl = remoteStorageUrl
    }
    
    enum GetCodableTypeError: Error {
        case getLinksError
        case invalidUrl
        case noResponse
        case errorCode(Int)
        case noData
        case decodingError(Error)
        
        case urlNetworkToolError(Error)
        case convertToDictionaryFailed
        case contentIsNil
        case base64DataParseFailure
        case utf8DataParseFailure
    }
    
    func getCodableType(completion: @escaping (Result<CodableType, GetCodableTypeError>) -> Void) {
        let urlString = self.remoteStorageUrl
        guard let url = URL(string: urlString) else {
            return completion(.failure(.invalidUrl))
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) {
            [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                return completion(.failure(.urlNetworkToolError(error)))
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.noResponse))
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(.errorCode(httpResponse.statusCode)))
            }
            guard let responseData = data else {
                return completion(.failure(.noData))
            }
            let stringData = String(decoding: responseData, as: UTF8.self)
            guard let dataDictionary = self.convertToDictionary(text: stringData) else {
                return completion(.failure(.convertToDictionaryFailed))
            }
            guard let contentString = dataDictionary["content"] as? String else {
                return completion(.failure(.contentIsNil))
            }
            guard
                let base64ContentData = Data(
                    base64Encoded: contentString,
                    options: .ignoreUnknownCharacters
                )
            else {
                return completion(.failure(.base64DataParseFailure))
            }
            guard
                let utf8ContentString = String(
                    data: base64ContentData,
                    encoding: .utf8
                ),
                let utf8ContentData = utf8ContentString.data(using: .utf8)
            else {
                return completion(.failure(.utf8DataParseFailure))
            }
            do {
                let value = try JSONDecoder().decode(
                    CodableType.self,
                    from: utf8ContentData
                )
                completion(.success(value))
            }
            catch(let decodingError) {
                completion(.failure(.decodingError(decodingError)))
            }
        }
        task.resume()
    }
}

private extension GitHubStorageService {
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func decodeJSONString<StructType: Codable>(jsonString: String) -> StructType? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(StructType.self, from: jsonData)
            return decodedData
        } catch {
            return nil
        }
    }
}
