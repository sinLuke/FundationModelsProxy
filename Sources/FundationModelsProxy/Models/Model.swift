//
//  Model.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor

struct Model: Content {
    let id: String
    let object: String
    let created: Int
    let owned_by: String
}
