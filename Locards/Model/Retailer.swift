import Foundation
import SwiftUI

enum RetailerCategory: String, CaseIterable, Identifiable {
    case groceries = "Groceries"
    case liquor = "Liquor"
    case pharmacy = "Pharmacy & Beauty"
    case department = "Department & Discount Stores"
    case homeHardware = "Home & Hardware"
    case electronicsOffice = "Electronics & Office"
    case fuel = "Fuel"
    case dining = "Dining"
    case entertainment = "Entertainment"
    case rewards = "Rewards & Travel"

    var id: String { rawValue }
}

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

    var category: RetailerCategory {
        switch self {
        case .woolworths, .coles, .iga: return .groceries
        case .bws, .danMurphys, .liquorland: return .liquor
        case .priceline, .chemistWarehouse: return .pharmacy
        case .myer, .davidJones, .bigW, .kmart, .target: return .department
        case .bunnings: return .homeHardware
        case .jbHiFi, .officeworks: return .electronicsOffice
        case .ampol, .shell, .bp: return .fuel
        case .hungryJacks, .mcDonalds, .dominos, .gloriaJeans: return .dining
        case .eventCinemas, .hoyts: return .entertainment
        case .flybuys, .qantas, .velocity: return .rewards
        }
    }

    var emoji: String {
        switch self {
        case .woolworths, .coles: return "🛒"
        case .iga: return "🏪"
        case .bws: return "🍺"
        case .danMurphys: return "🍷"
        case .liquorland: return "🥂"
        case .priceline: return "💄"
        case .chemistWarehouse: return "💊"
        case .myer: return "👗"
        case .davidJones: return "👜"
        case .bigW: return "🧸"
        case .kmart: return "🏷️"
        case .target: return "🎯"
        case .bunnings: return "🔨"
        case .jbHiFi: return "🎧"
        case .officeworks: return "🖨️"
        case .ampol, .shell, .bp: return "⛽"
        case .hungryJacks: return "🍔"
        case .mcDonalds: return "🍟"
        case .dominos: return "🍕"
        case .gloriaJeans: return "☕"
        case .eventCinemas: return "🎬"
        case .hoyts: return "🍿"
        case .flybuys: return "🎁"
        case .qantas, .velocity: return "✈️"
        }
    }

    var brandColor: Color {
        let (red, green, blue) = rgb
        return Color(red: red, green: green, blue: blue)
    }

    var prefersDarkText: Bool {
        let (red, green, blue) = rgb
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue > 0.6
    }

    private var rgb: (Double, Double, Double) {
        let hex: UInt32
        switch self {
        case .woolworths: hex = 0x00843D
        case .coles: hex = 0xE01A22
        case .flybuys: hex = 0x1E3A8A
        case .iga: hex = 0xD71920
        case .bws: hex = 0x006B3F
        case .danMurphys: hex = 0x7A1F2B
        case .liquorland: hex = 0xD71920
        case .priceline: hex = 0xE4002B
        case .chemistWarehouse: hex = 0xD2222D
        case .myer: hex = 0x1C1C1C
        case .davidJones: hex = 0x2B2B2B
        case .bigW: hex = 0xFFCC00
        case .kmart: hex = 0xD7001C
        case .target: hex = 0xCC0000
        case .bunnings: hex = 0x00843D
        case .jbHiFi: hex = 0xFFD500
        case .officeworks: hex = 0xE31E24
        case .ampol: hex = 0xE3002B
        case .shell: hex = 0xFBCE07
        case .bp: hex = 0x007B3F
        case .qantas: hex = 0xE0001B
        case .velocity: hex = 0x6B2D91
        case .eventCinemas: hex = 0xE0052D
        case .hoyts: hex = 0xC8102E
        case .hungryJacks: hex = 0xE4002B
        case .mcDonalds: hex = 0xDA291C
        case .dominos: hex = 0x006491
        case .gloriaJeans: hex = 0x4B2C20
        }
        return (
            Double((hex >> 16) & 0xFF) / 255,
            Double((hex >> 8) & 0xFF) / 255,
            Double(hex & 0xFF) / 255
        )
    }
}
