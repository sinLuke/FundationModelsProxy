//
//  ModelController.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor

struct ModelController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.get("models", use: models)
    }
    
    @Sendable
    func models(req: Request) async throws -> CommonResponse<[Model]> {
        return CommonResponse(object: "list", data: [
            Model(id: "default", object: "model", created: 0, owned_by: "Apple")
        ])
    }
}
