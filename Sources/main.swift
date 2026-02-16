import Foundation

guard let appName = Bundle.main.object(forInfoDictionaryKey: "OITAppName") as? String,
      let appTypeRaw = Bundle.main.object(forInfoDictionaryKey: "OITAppType") as? String
else {
    logw("Error: Missing OITAppName or OITAppType in Info.plist")
    exit(1)
}

do {
    let type: AppType = appTypeRaw == "terminal" ? .terminal : .editor
    let app = App(name: appName, type: type)
    try app.openOutsideSandbox()
} catch {
    logw(error.localizedDescription)
}
