//
//  ORDispatch.swift
//  Pods
//
//  Created by Maxim Soloviev on 12/04/16.
//
//

import Foundation

public func or_dispatch_in_main_queue_after(delayInSeconds: Double, block: dispatch_block_t) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}
