import Foundation
import SwiftUI

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private let saveKey = "SavedTransactions"
    
    init() {
        loadTransactions()
        // デモデータを追加（初回起動時のみ）
        if transactions.isEmpty {
            addSampleData()
        }
    }
    
    // 取引を追加
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        transactions.sort { $0.date > $1.date }
        saveTransactions()
    }
    
    // 取引を削除
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }
    
    // 取引を削除（ID指定）
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    // 総収入を計算
    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 総支出を計算
    var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 残高を計算
    var balance: Double {
        totalIncome - totalExpense
    }
    
    // 今月の取引を取得
    var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }
    }
    
    // 今月の収入
    var currentMonthIncome: Double {
        currentMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 今月の支出
    var currentMonthExpense: Double {
        currentMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    // カテゴリ別の支出を計算
    func expensesByCategory() -> [(category: Category, amount: Double)] {
        let expenses = currentMonthTransactions.filter { $0.type == .expense }
        var categoryTotals: [Category: Double] = [:]
        
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    // 過去N ヶ月の月別データを取得
    func getMonthlyData(months: Int = 6) -> [MonthlyData] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyDataList: [MonthlyData] = []
        
        for i in (0..<months).reversed() {
            guard let targetDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let components = calendar.dateComponents([.year, .month], from: targetDate)
            guard let year = components.year, let month = components.month else { continue }
            
            let monthTransactions = transactions.filter { transaction in
                let transactionComponents = calendar.dateComponents([.year, .month], from: transaction.date)
                return transactionComponents.year == year && transactionComponents.month == month
            }
            
            let income = monthTransactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            
            let expense = monthTransactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            
            monthlyDataList.append(MonthlyData(year: year, month: month, income: income, expense: expense))
        }
        
        return monthlyDataList
    }
    
    // 過去N年の年別データを取得
    func getYearlyData(years: Int = 3) -> [YearlyData] {
        let calendar = Calendar.current
        let now = Date()
        var yearlyDataList: [YearlyData] = []
        
        for i in (0..<years).reversed() {
            guard let targetDate = calendar.date(byAdding: .year, value: -i, to: now) else { continue }
            let components = calendar.dateComponents([.year], from: targetDate)
            guard let year = components.year else { continue }
            
            let yearTransactions = transactions.filter { transaction in
                let transactionComponents = calendar.dateComponents([.year], from: transaction.date)
                return transactionComponents.year == year
            }
            
            let income = yearTransactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            
            let expense = yearTransactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            
            yearlyDataList.append(YearlyData(year: year, income: income, expense: expense))
        }
        
        return yearlyDataList
    }
    
    // データを保存
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // データを読み込み
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
    
    // サンプルデータを追加
    private func addSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        // 今月のサンプルデータ
        let sampleTransactions = [
            Transaction(type: .income, category: .salary, amount: 300000, date: calendar.date(byAdding: .day, value: -25, to: now)!, note: "月給"),
            Transaction(type: .expense, category: .food, amount: 3500, date: calendar.date(byAdding: .day, value: -5, to: now)!, note: "スーパーで買い物"),
            Transaction(type: .expense, category: .transportation, amount: 1200, date: calendar.date(byAdding: .day, value: -4, to: now)!, note: "電車代"),
            Transaction(type: .expense, category: .utilities, amount: 8000, date: calendar.date(byAdding: .day, value: -3, to: now)!, note: "電気代"),
            Transaction(type: .expense, category: .entertainment, amount: 5000, date: calendar.date(byAdding: .day, value: -2, to: now)!, note: "映画とディナー"),
            Transaction(type: .expense, category: .shopping, amount: 12000, date: calendar.date(byAdding: .day, value: -1, to: now)!, note: "服を購入"),
            Transaction(type: .expense, category: .food, amount: 2800, date: now, note: "ランチ"),
        ]
        
        transactions = sampleTransactions
        saveTransactions()
    }
}
