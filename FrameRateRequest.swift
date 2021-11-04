//
//  FrameRateRequest.swift
//
//  Created by Duraid Abdul on 2021-11-04.
//  Copyright © 2021 Duraid Abdul. All rights reserved.
//

import UIKit

/**
An object that allows you to manually request an increased display refresh rate on ProMotion devices.

*The display refresh rate does not exceed 60 Hz when low power mode is enabled.*

**Do not set an excessive duration. Doing so will negatively impact battery life.**
 
```
// Example
let request = FrameRateRequest(preferredFrameRate: 120,
                               duration: 0.4)
request.perform()
```
 */
class FrameRateRequest {
    
    private let frameRateRange: CAFrameRateRange
    private let duration: Double
    
    /// Prepares your frame rate request parameters.
    init(preferredFrameRate: Float, duration: Double) {
        frameRateRange = CAFrameRateRange(minimum: 30, maximum: Float(UIScreen.main.maximumFramesPerSecond), preferred: preferredFrameRate)
        self.duration = duration
    }
    
    /// Perform frame rate request.
    func perform() {
        let displayLink = CADisplayLink(target: self, selector: #selector(dummyFunction))
        displayLink.preferredFrameRateRange = frameRateRange
        displayLink.add(to: .current, forMode: .common)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            displayLink.remove(from: .current, forMode: .common)
        }
    }
    
    @objc private func dummyFunction() {}
}
