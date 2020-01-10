//
//  Resource.swift
//  BudgetTrackeriOS
//
//  Created by Jonathan Wong on 4/15/19.
//  Copyright © 2019 fatty waffles. All rights reserved.
//

import Foundation

enum ApiError: Error {
  case notFound // 404
  case serverError // 5xx
  case requestError // 4xx
  case jsonError
  case couldNotConnectToHost
}

protocol NetworkTask {
  func resume()
}

extension URLSessionDataTask: NetworkTask {}

protocol NetworkSession {
  func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask
  
  func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask
}

extension URLSession: NetworkSession {
  func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
    return dataTask(with: request, completionHandler: completion)
  }
  
  func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
    return dataTask(with:url, completionHandler: completion)
  }
}

class ApiClient {

  let session: NetworkSession
  let baseURL = "http://localhost:8080/v1/"
  var resourceURL: URL
  
  var path: String? {
    didSet {
      if let path = path, let url = URL(string: baseURL)?.appendingPathComponent(path) {
        resourceURL = url
      }
    }
  }

  convenience init(session: NetworkSession) {
    self.init(session: session, resourcePath: nil)
  }
  
  init(session: NetworkSession, resourcePath: String?) {
    self.session = session

    guard let resourceURL = URL(string: baseURL) else {
      fatalError()
    }
    if let resourcePath = resourcePath {
      self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
    } else {
      self.resourceURL = resourceURL
    }
  }

  func fetchResource<T>(completion: @escaping (Result<T, ApiError>) -> Void) where T: Codable {
    let dataTask = session.dataTask(with: resourceURL) { data, reponse, error in
      if let _ = error as? URLError {
        return completion(.failure(.couldNotConnectToHost))
      }
      guard let jsonData = data else {
        completion(.failure(.jsonError))
        return
      }
      do {
        let jsonDecoder = JSONDecoder()
        let resource = try jsonDecoder.decode(T.self, from: jsonData)
        completion(.success(resource))
      } catch {
        let bodyString = String(data: data!, encoding: .utf8)
        print("error \(String(describing: bodyString))")
        completion(.failure(.serverError))
      }
    }
    dataTask.resume()
  }
  
  func fetchResources<T>(completion: @escaping (Result<[T], ApiError>) -> Void) where T: Codable {
    let dataTask = session.dataTask(with: resourceURL) { data, response, error in
      if let _ = error as? URLError {
        return completion(.failure(.couldNotConnectToHost))
      }
      guard let jsonData = data else {
        completion(.failure(.jsonError))
        return
      }
      do {
        let jsonDecoder = JSONDecoder()
        let resources = try jsonDecoder.decode([T].self, from: jsonData)
        completion(.success(resources))
      } catch {
        let bodyString = String(data: data!, encoding: .utf8)
        print("error \(String(describing: bodyString))")
        completion(.failure(.serverError))
      }
    }
    dataTask.resume()
  }

  func save(fromPath: String,
            fromResourceId: Int,
            toPath: String,
            toResourceId: Int,
            completion: @escaping (Int) -> Void) {
    path = "\(fromPath)/\(fromResourceId)/\(toPath)/\(toResourceId)"
    var urlRequest = URLRequest(url: resourceURL)
    urlRequest.httpMethod = "POST"
    let dataTask = session.dataTask(with: urlRequest) { data, response, _ in
      guard let httpResponse = response as? HTTPURLResponse else { return }
      completion(httpResponse.statusCode)
    }
    dataTask.resume()
  }
  
  func delete(fromPath: String,
            fromResourceId: Int,
            toPath: String,
            toResourceId: Int,
            completion: @escaping (Int) -> Void) {
    path = "\(fromPath)/\(fromResourceId)/\(toPath)/\(toResourceId)"
    var urlRequest = URLRequest(url: resourceURL)
    urlRequest.httpMethod = "DELETE"
    let dataTask = session.dataTask(with: urlRequest) { data, response, _ in
      guard let httpResponse = response as? HTTPURLResponse else { return }
      completion(httpResponse.statusCode)
    }
    dataTask.resume()
  }
}
