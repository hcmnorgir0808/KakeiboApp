import Foundation
import SwiftUI

// 取引タイプ（収入または支出）
enum TransactionType: String, Codable, CaseIterable {
    case income = "収入"
    case expense = "支出"
    
    var color: Color {
        switch self {
        case .income:
            return .green
        case .expense:
            return .red
        }
    }
}

// カテゴリ
enum Category: String, Codable, CaseIterable {
    // 支出カテゴリ
    case food = "食費"
    case transportation = "交通費"
    case utilities = "光熱費"
    case entertainment = "娯楽"
    case shopping = "買い物"
    case health = "医療"
    case education = "教育"
    case housing = "住居"
    case other = "その他"
    
    // 収入カテゴリ
    case salary = "給与"
    case bonus = "ボーナス"
    case investment = "投資"
    case gift = "贈与"
    
    var icon: String {
        switch self {
        case .food: return "🍽️"
        case .transportation: return "🚗"
        case .utilities: return "💡"
        case .entertainment: return "🎮"
        case .shopping: return "🛍️"
        case .health: return "🏥"
        case .education: return "📚"
        case .housing: return "🏠"
        case .other: return "📦"
        case .salary: return "💰"
        case .bonus: return "🎁"
        case .investment: return "📈"
        case .gift: return "🎉"
        }
    }
    
    static var expenseCategories: [Category] {
        [.food, .transportation, .utilities, .entertainment, .shopping, .health, .education, .housing, .other]
    }
    
    static var incomeCategories: [Category] {
        [.salary, .bonus, .investment, .gift]
    }
}

// 取引データモデル
struct Transaction: Identifiable, Codable {
    var id = UUID()
    var type: TransactionType
    var category: Category
    var amount: Double
    var date: Date
    var note: String
    
    init(type: TransactionType, category: Category, amount: Double, date: Date = Date(), note: String = "") {
        self.type = type
        self.category = category
        self.amount = amount
        self.date = date
        self.note = note
    }
}
