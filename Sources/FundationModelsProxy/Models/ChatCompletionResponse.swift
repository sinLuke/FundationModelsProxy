//
//  ChatCompletionResponse.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor

struct ChatCompletionResponse: Content {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
    let serviceTier: String

    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case serviceTier = "service_tier"
    }
    
    struct Delta: Content {
        let content: String?
    }

    struct Choice: Content {
        let index: Int
        let message: Message?
        let logprobs: String?
        let finishReason: String?
        let delta: Delta?

        enum CodingKeys: String, CodingKey {
            case index, message, logprobs, delta
            case finishReason = "finish_reason"
        }
    }

    struct Message: Content {
        let role: String
        let content: String
        let refusal: String?
        let annotations: [String]
    }

    struct Usage: Content {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        let promptTokensDetails: PromptTokensDetails
        let completionTokensDetails: CompletionTokensDetails

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
            case promptTokensDetails = "prompt_tokens_details"
            case completionTokensDetails = "completion_tokens_details"
        }
    }

    struct PromptTokensDetails: Content {
        let cachedTokens: Int
        let audioTokens: Int

        enum CodingKeys: String, CodingKey {
            case cachedTokens = "cached_tokens"
            case audioTokens = "audio_tokens"
        }
    }

    struct CompletionTokensDetails: Content {
        let reasoningTokens: Int
        let audioTokens: Int
        let acceptedPredictionTokens: Int
        let rejectedPredictionTokens: Int

        enum CodingKeys: String, CodingKey {
            case reasoningTokens = "reasoning_tokens"
            case audioTokens = "audio_tokens"
            case acceptedPredictionTokens = "accepted_prediction_tokens"
            case rejectedPredictionTokens = "rejected_prediction_tokens"
        }
    }
}
