//
//  CommonResponse.swift
//  FundationModelsProxy
//
//  Created by Luke on 2025-06-09.
//

import Vapor

struct CommonResponse<DataType: Content>: Content {
    let object: String
    let data: DataType
}
