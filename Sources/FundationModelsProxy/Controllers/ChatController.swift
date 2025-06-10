//
//  ChatController.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor
import FoundationModels

struct ChatController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("chat")
        auth.post("completions", use: self.completions)
    }
    
    @Sendable
    func completions(req: Request) async throws -> Response {
        guard let bytes = req.body.data, let object = try? bytes.getJSONDecodable(ChatCompletionRequest.self, at: 0, length: bytes.readableBytes) else {
            throw Abort(.badRequest)
        }

        var messages = object.messages
        let lastMessage = messages.removeLast()
        guard let lastContent = lastMessage.content else {
            throw Abort(.badRequest)
        }
        let entities: [Transcript.Entry] = messages
            .map { (message: ChatCompletionRequest.Message) -> Transcript.Entry? in
                switch message.role {
                case "user":
                    if let content = message.content {
                        return .prompt(.init(segments: [.text(.init(content: content))]))
                    } else {
                        return nil
                    }
                case .none:
                    return nil
                case .some(_):
                    return nil
                }
            }
            .compactMap { $0 }
        let session = LanguageModelSession(transcript: .init(entries: entities))
        if object.stream == true {
            return try await LanguageModelService.shared.stremCompletion(req: req, session: session, lastContent: lastContent, includeUsage: object.streamOptions?.includeUsage == true)
        } else {
            let responseObject = try await LanguageModelService.shared.nonStremCompletion(session: session, lastContent: lastContent)
            return try await responseObject.encodeResponse(for: req)
        }
    }
}
