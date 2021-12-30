import Foundation
import MockingbirdCommon

public enum Simulator {
  public enum Platform: String {
    case iOS = "iOS"
    case tvOS = "tvOS"
    case watchOS = "watchOS"
  }
  
  public struct Runtime: Codable {
    public let bundlePath: String
    public let buildversion: String
    public let runtimeRoot: String
    public let identifier: String
    public let version: String
    public let isAvailable: Bool
    public let supportedDeviceTypes: [DeviceType]
    
    public struct DeviceType: Codable {
      public let bundlePath: String
      public let name: String
      public let identifier: String
      public let productFamily: ProductFamily
      
      public enum ProductFamily: String, Codable {
        case iPhone = "iPhone"
        case iPad = "iPad"
      }
    }
  }
  
  public static func listRuntimes(platform: Platform) throws -> [Runtime] {
    struct Response: Codable {
      let runtimes: [Runtime]
    }
    let simctl = try Subprocess("xcrun", [
      "simctl", "list", "runtimes", "-j", platform.rawValue,
    ]).run()
    let response = try JSONDecoder()
      .decode(Response.self, from: simctl.stdout.fileHandleForReading.readDataToEndOfFile())
    return response.runtimes
  }
  
  public static func createSimulator(name: String,
                                     runtime: Runtime,
                                     deviceType: Runtime.DeviceType) throws -> UUID? {
    let (stdout, _) = try Subprocess("xcrun", [
      "simctl", "create", name, deviceType.identifier, runtime.identifier,
    ]).runWithOutput()
    return UUID(uuidString: stdout.trimmingCharacters(in: .whitespacesAndNewlines))
  }
  
  public static func deleteSimulator(uuid: UUID) throws {
    try Subprocess("xcrun", [
      "simctl", "delete", uuid.uuidString,
    ]).runWithOutput()
  }
  
  public static func performInSimulator(platform: Platform = .iOS,
                                        productFamily: Runtime.DeviceType.ProductFamily = .iPhone,
                                        block: (_ deviceUUID: UUID?) throws -> Void) throws {
    let availableRuntimes = try listRuntimes(platform: platform).filter({ $0.isAvailable })
    guard let runtime = availableRuntimes.first,
          let deviceType = runtime.supportedDeviceTypes
            .first(where: { $0.productFamily == productFamily }),
          let uuid = try createSimulator(name: "Mockingbird \(productFamily.rawValue) Simulator",
                                         runtime: runtime,
                                         deviceType: deviceType)
    else {
      return try block(nil)
    }
    defer {
      try? deleteSimulator(uuid: uuid)
    }
    try block(uuid)
  }
}
