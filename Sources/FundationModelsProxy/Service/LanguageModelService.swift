//
//  LanguageModelService.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor
import FoundationModels

actor LanguageModelService {
    static let shared = LanguageModelService()
    var busy = false
    
    func nonStremCompletion(session: LanguageModelSession, lastContent: String) async throws -> ChatCompletionResponse {
        if busy {
            throw Abort(.tooManyRequests)
        }
        busy = true
        defer {
            busy = false
        }
        let response = try await session.respond(to: .init(lastContent))
        return ChatCompletionResponse(
            id: UUID().uuidString,
            object: "chat.completion",
            created: Int(Date().timeIntervalSince1970),
            model: "default",
            choices: [
                .init(
                    index: 0,
                    message: .init(
                        role: "assistant",
                        content: response.content,
                        refusal: nil,
                        annotations: []
                    ),
                    logprobs: nil,
                    finishReason: "stop",
                    delta: nil
                )
            ],
            usage: .init(
                promptTokens: 0,
                completionTokens: 0,
                totalTokens: 0,
                promptTokensDetails:
                        .init(
                            cachedTokens: 0,
                            audioTokens: 0),
                completionTokensDetails:
                        .init(
                            reasoningTokens: 0,
                            audioTokens: 0,
                            acceptedPredictionTokens: 0,
                            rejectedPredictionTokens: 0
                        )
            ),
            serviceTier: "default"
        )
    }
     
    func stremCompletion(req: Request, session: LanguageModelSession, lastContent: String, includeUsage: Bool) throws -> Response {
        if busy {
            throw Abort(.tooManyRequests)
        }
        busy = true
        defer {
            busy = false
        }
        let body = Response.Body(stream: { writer in
            let modelResponse = session.streamResponse(to: .init(lastContent))
            Task(priority: .background) {
                var lastResponse = ""
                for try await partialResponse in modelResponse {
                    let delta = String(partialResponse[lastResponse.endIndex..<partialResponse.endIndex])
                    try await writer.write(.buffer(try await self.getDeltaBuffer(delta: delta, end: false, includeUsage: false))).get()
                    lastResponse = partialResponse
                }
                
                try await writer.write(.buffer(try await self.getDeltaBuffer(delta: nil, end: false, includeUsage: false))).get()
                if includeUsage {
                    try await writer.write(.buffer(try await self.getDeltaBuffer(delta: nil, end: true, includeUsage: includeUsage))).get()
                }
                
                try await writer.write(.buffer(ByteBuffer(string: "[DONE]"))).get()
                try await writer.write(.end).get()
            }
        })
        
        let response = Response(status: .ok, body: body)
        
        response.headers.replaceOrAdd(name: "Content-Type", value: "text/event-stream")
        response.headers.replaceOrAdd(name: "Connection", value: "keep-alive")
        
        return response
    }
    
    private func getDeltaBuffer(delta: String?, end: Bool, includeUsage: Bool) async throws -> ByteBuffer {
        let resonse = ChatCompletionResponse(
            id: UUID().uuidString,
            object: "chat.completion",
            created: Int(Date().timeIntervalSince1970),
            model: "default",
            choices: end ? [] : [
                .init(
                    index: 0,
                    message: nil,
                    logprobs: nil,
                    finishReason: delta == nil ? "stop" : nil,
                    delta: .init(content: delta)
                )
            ],
            usage: includeUsage ? .init(
                promptTokens: 0,
                completionTokens: 0,
                totalTokens: 0,
                promptTokensDetails:
                        .init(
                            cachedTokens: 0,
                            audioTokens: 0),
                completionTokensDetails:
                        .init(
                            reasoningTokens: 0,
                            audioTokens: 0,
                            acceptedPredictionTokens: 0,
                            rejectedPredictionTokens: 0
                        )
            ) : nil,
            serviceTier: "default"
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(resonse)
        let message = "data: \(String(data: data, encoding: .utf8) ?? "NULL")\n\n"
        
        let contentBuffer = ByteBuffer(string: message)
        
        return contentBuffer
    }
}

