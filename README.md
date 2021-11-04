# Run animations at high frame rates on iPhone 13 Pro

### Background

When using a UIViewPropertyAnimator to animate objects on iPhone 13 Pro, CoreAnimation infers the frame rate that you need, without providing you with control over this frame rate.

Say you’re animating a rectangle quickly across the screen. It may decide to give you a smooth 120 FPS when the rectangle is moving fast (currently capped at 60 FPS due to a CoreAnimation bug). If you’re animating a button’s alpha, however, it may decide to give you a frame rate around 30 FPS (tested in instruments for a 0.4s alpha transition). This looks very choppy. For more information on this behaviour, see [Optimizing ProMotion Refresh Rates for iPhone 13 Pro and iPad Pro](https://developer.apple.com/documentation/quartzcore/optimizing_promotion_refresh_rates_for_iphone_13_pro_and_ipad_pro).

It has already been observed that third party developers are unable to build animations exceeding 60 FPS using CoreAnimation on iPhone 13 Pro, but is should also be noted that developers cannot override lower refresh rate inferences either (i.e. a fading button running at 30 Hz), so more subtle fade animations will look choppy on this device.

I hope Apple addresses these CoreAnimation issues so that developers don’t have to manually work around them in the future, but for now, here is how you can run animations at your desired frame rate.

### Solution

To run animations at high frame rates, you can use a “dummy” CADisplayLink that requests high frame rates using the preferredFrameRateRange property, but does not perform any tasks.

**Add this entry to your Xcode project's info.plist**
```
CADisableMinimumFrameDurationOnPhone
Type: Bool, Value: true
```

**Paste this code into your Xcode Project.**

```swift
///
/// An object that allows you to manually request an increased display refresh rate on ProMotion devices.
///
/// *The display refresh rate does not exceed 60 Hz when low power mode is enabled.*
///
/// **Do not set an excessive duration. Doing so will negatively impact battery life.**
///
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
```

**You can now submit a frame rate request like this:**
```swift
// Attempts to increase the display refresh rate to 120 Hz for 0.4s (the expected duration of the animation).
let request = FrameRateRequest(preferredFrameRate: 120,
                               duration: 0.4)
request.perform()



// After performing the FrameRateRequest, run your animation(s) here using animators of your choice (UIViewPropertyAnimator, UIView.animate, etc).


```
