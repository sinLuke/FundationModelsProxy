//
//  ChatCompletionRequest.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor

struct ChatCompletionRequest: Content {
    struct Message: Content {
        let role: String?
        let content: String?
    }
    struct StreamOptions: Content {
        let includeUsage: Bool?
        enum CodingKeys: String, CodingKey {
            case includeUsage = "include_usage"
        }
    }
    let model: String
    let messages: [Message]
    let stream: Bool?
    let maxTokens: Int?
    let temperature: Double?
    let topP: Double?
    let frequencyPenalty: Double?
    let presencePenalty: Double?
    let streamOptions: StreamOptions?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, stream, temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
        case streamOptions = "stream_options"
    }
}
