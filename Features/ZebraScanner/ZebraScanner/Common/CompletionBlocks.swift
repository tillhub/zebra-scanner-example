//
//  CompletionBlocks.swift
//  EposDevices
//
//  Created by lpylypenko on 12.09.19.
//  Copyright © 2019 Andreas Hilbert. All rights reserved.
//

import Foundation

public typealias VoidCompletion = () -> ()
public typealias ErrorCompletion = (_ error: Error?) -> ()
public typealias Result<T> = Swift.Result<T, Error>
public typealias ResultCompletion<T> = (_ result: Result<T>) -> ()
