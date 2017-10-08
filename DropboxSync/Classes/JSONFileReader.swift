import SwiftyJSON
class JSONFileReader {
    func read(_ fileUrl: URL) -> SwiftyJSON.JSON? {
        guard let data = dataForFile(fileUrl) else {
            return nil
        }
        
        return JSON(data: data)
    }
    
    private func dataForFile(_ url: URL) -> Data? {
        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            return nil
        }
    }
}
