import Foundation

enum Retailer: String, CaseIterable, Identifiable {
    case woolworths = "Woolworths"
    case coles = "Coles"
    case flybuys = "flybuys"
    case iga = "IGA"
    case bws = "BWS"
    case danMurphys = "Dan Murphy's"
    case liquorland = "Liquorland"
    case priceline = "Priceline"
    case chemistWarehouse = "Chemist Warehouse"
    case myer = "Myer"
    case davidJones = "David Jones"
    case bigW = "Big W"
    case kmart = "Kmart"
    case target = "Target"
    case bunnings = "Bunnings"
    case jbHiFi = "JB Hi-Fi"
    case officeworks = "Officeworks"
    case ampol = "Ampol"
    case shell = "Shell"
    case bp = "BP"
    case qantas = "Qantas Frequent Flyer"
    case velocity = "Velocity Frequent Flyer"
    case eventCinemas = "Event Cinemas"
    case hoyts = "Hoyts"
    case hungryJacks = "Hungry Jack's"
    case mcDonalds = "McDonald's"
    case dominos = "Domino's"
    case gloriaJeans = "Gloria Jean's"

    var id: String { rawValue }

    var logoName: String { "logo_\(self)" }
}
