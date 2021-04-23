//
//  LoadDylib.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/24/20.
//

import Foundation
import PathKit
import MockingbirdGenerator

private let subprocessEnvironmentKey = "MKB_SUBPROCESS"
  
enum LoadingError: Error, CustomStringConvertible {
  case invalidSubprocessState(path: Path)
  case streamCreationFailed(path: Path)
  case subprocessLaunchFailed(error: Error)
  
  var description: String {
    switch self {
    case .invalidSubprocessState(let path):
      return "Expected dylib to exist at \(path)"
    case .streamCreationFailed(let path):
      return "Failed to create dylib at \(path)"
    case .subprocessLaunchFailed(let error):
      return "Failed to launch subprocess after loading dylibs: \(error.localizedDescription)"
    }
  }
}
  
/// Load embedded _dependent_ dylibs (see `generate-resource-file.sh`).
///
/// The dylibs are linked dependent libraries added to the CLI's `globalLibraryDirectory` rpath. If
/// a dylib does not currently exist in the rpath and was created after launch, the process will
/// relaunch itself as a subprocess in order to properly trigger `__dyld_start`. The `onLoad` block
/// will not be called in this case. Use `DYLD_PRINT_RPATHS=1` to debug.
///
/// - Parameters:
///   - resources: Dylibs to load.
///   - shouldOverwrite: Whether to overwrite an existing dylib.
///   - block: The block to call
func loadDylibs(_ dylibs: [Resource],
                shouldOverwrite: Bool = false,
                processInfo: ProcessInfo = ProcessInfo.processInfo,
                onLoad block: () -> Void) {
  let environment = processInfo.environment
  
  // Global world-writable place to output dylibs, must be kept in sync with `Makefile`.
  #if RELATIVE_RPATH // Use relative paths for sandboxed CI builds.
  let mockingbirdPath = Path(processInfo.arguments.first ?? "./mockingbird").absolute()
  var globalLibraryDirectory = mockingbirdPath.parent()
  if mockingbirdPath.isSymlink {
    do {
      globalLibraryDirectory = try mockingbirdPath.symlinkDestination().absolute().parent()
    } catch {
      logWarning("Mockingbird was run from a symbolic link, but the symbolic link destination " +
                 "could not be resolved. Dylibs may be extracted to the wrong location.")
    }
  }
  #else
  let globalLibraryDirectory = Path("/var/tmp/mockingbird/\(mockingbirdVersion)/libs/")
  #endif
  
  var shouldRelaunch = false
  for dylib in dylibs {
    let dylibPath = (globalLibraryDirectory + dylib.fileName).absolute()
    guard !dylibPath.isFile || shouldOverwrite else { continue }
    shouldRelaunch = true // Need to relaunch if even a single expected dylib is missing.
    
    guard environment[subprocessEnvironmentKey] != "1" else {
      // Avoid creating dylibs and relaunching subprocesses infinitely if something has gone wrong.
      log(LoadingError.invalidSubprocessState(path: dylibPath))
      exit(1)
    }
    
    try? dylibPath.parent().mkpath()
    
    guard let outputStream = OutputStream(toFileAtPath: "\(dylibPath)", append: false) else {
      log(LoadingError.streamCreationFailed(path: dylibPath))
      exit(1)
    }
    
    outputStream.open()
    outputStream.write(data: dylib.data)
    outputStream.close()
  }
  
  guard shouldRelaunch else { return block() }
  
  let subprocess = Process()
  subprocess.executableURL = URL(fileURLWithPath: processInfo.arguments.first!, isDirectory: false)
  subprocess.arguments = Array(processInfo.arguments.dropFirst())
  subprocess.qualityOfService = .userInitiated
  
  // Subprocesses should not try to load dylibs themselves.
  var attributedEnvironment = environment
  attributedEnvironment[subprocessEnvironmentKey] = "1"
  subprocess.environment = attributedEnvironment
  
  do {
    try subprocess.run()
  } catch {
    log(LoadingError.subprocessLaunchFailed(error: error))
    exit(1)
  }
  
  subprocess.waitUntilExit()
  exit(subprocess.terminationStatus)
}
