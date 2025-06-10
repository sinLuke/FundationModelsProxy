// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
 
let app = try await Application.make(.detect())
app.http.server.configuration.hostname = Vapor.Environment.get("HOST_NAME") ?? "0.0.0.0"
app.http.server.configuration.port = Vapor.Environment.get("PORT").flatMap(Int.init(_:)) ?? 8080
try app.register(collection: ModelController())
try app.register(collection: ChatController())

try await app.execute()
