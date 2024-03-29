//
//  RequestSender.swift
//  Messenger
//
//  Created by Иван Базаров on 25.11.2018.
//  Copyright © 2018 Иван Базаров. All rights reserved.
//

import Foundation

protocol IRequestSender {
    func send<Parser>(config: RequestConfig<Parser>, completion: @escaping (RequestResult<Parser.Model>) -> Void)
}

class RequestSender: IRequestSender {
    var session = URLSession.shared
    func send<Parser>(config: RequestConfig<Parser>, completion: @escaping (RequestResult<Parser.Model>) -> Void) {
        guard let request = config.request.urlRequest else {
            completion(RequestResult<Parser.Model>.error("Request is nil"))
            return
        }
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            let result: RequestResult<Parser.Model>
            if let error = error {
                result = .error(error.localizedDescription)
                completion(result)
                return
            }
            guard let data = data else {
                result = .error("Data is nil")
                completion(result)
                return
            }
            guard let model = config.parser.parse(data: data) else {
                result = .error("Can't parse data")
                completion(result)
                return
            }
            result = .succes(model)
            completion(result)
        }
        dataTask.resume()
    }
}
