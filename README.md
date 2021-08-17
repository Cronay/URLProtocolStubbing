# URLProtocol Stubbing for Testing Networking

Classic approaches to testing the network layer(End-to-End-Tests, Subclass-based Mocking, Protocol-based Mocking) all have downsides to their approaches. They either hit the real network, couple the tests to the implementation or framework or add cruft to the production code. With the URLProtocol Stubbing technic we can eliminate all these downsides. The tests are framework-agnostic, don't hit the real network and are not coupled with the implementation.
Here I show a simple way to test a simple `RequestHandler`.

This code was accompanied by a presentation in my workplace. If you want to know more about this approach I can recommend looking into the docs or watching Apple's WWDC Session.

WWDC Talk: https://developer.apple.com/videos/play/wwdc2018/417

Apple Docs: https://developer.apple.com/documentation/foundation/urlprotocol
