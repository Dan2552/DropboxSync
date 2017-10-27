import SwiftyJSON

class JSONFileReader {
    func read(_ fileUrl: URL) -> SwiftyJSON.JSON? {
        guard let data = dataForFile(fileUrl) else {
            return nil
        }

        let json = JSON(data: data)
        
        if json.rawString() == "null" {
            return nil
        }
        
        return json
    }

    private func dataForFile(_ url: URL) -> Data? {
        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            return nil
        }
    }
}
