# Known Limitations

List of unsupported or missing features in the framework.

## Overview

| **Legend** |  |  |
| --- | --- | --- |
| ✅ Supported | ✴️ Not implemented | ❌ Unsupported due to Swift limitations |

_(Empty entries indicate that the feature is not applicable for the given mock type.)_

|  | Swift Protocols | Swift Classes | @objc Swift Classes | Obj-C Objects |
| --- | --- | --- | --- | --- |
| **Extensions** | | | |
| Swift Extension Method | ❌ | ❌ | ❌ | ❌ |
| Swift Extension Property | ❌ | ❌ | ❌ | ❌ |
| Obj-C Extension Method | ❌ | ❌ | ❌ | ✅ |
| Obj-C Extension Property | ❌ | ❌ | ❌ | ✅ |
| | | | |
| **Static Members** | | | |
| Static Methods | ✅ | ✅ | ✴️ | ✴️ |
| Static Properties | ✅ | ✅ | ✴️ | ✴️ |
| Static Subscripts | ✴️ | ✴️ | ✴️ |  |
| | | | |
| **Mocking** | | | |
| Parameterless Initialization | ✅ | ❌ | ✅ | ✅ |
| Superclass Forwarding |   | ✅ | ✅ |   |
| Generic Partial Mocks | ✴️ | ✴️ | ✴️ |   |
| | | | |
| **Objective-C** | | | |
| Obj-C Dynamic Properties |   |   |   | ✴️ |
| | | | |
| **Modifiers** | | | |
| Swift Final Keyword |   | ❌ | ✅ |   |
| Swift Unavailable Method | ✴️ | ✴️ | ✴️ |   |
| Swift Unavailable Property | ✴️ | ✴️ | ✴️ |   |
| | | | |
| **Swift 5.5** | | | |
| Swift Async Method | ✴️ | ✴️ |   |   |
| Swift Actors | ✴️ | ✴️ |   |   |
| | | | |
| (This row is intentionally left blank for table formatting.) |   |   |   |   |
