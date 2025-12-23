import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "すべて"
        case income = "収入"
        case expense = "支出"
    }
    
    var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all:
            return viewModel.transactions
        case .income:
            return viewModel.transactions.filter { $0.type == .income }
        case .expense:
            return viewModel.transactions.filter { $0.type == .expense }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // フィルター
                Picker("フィルター", selection: $selectedFilter) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if filteredTransactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("取引がありません")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Button(action: {
                            showingAddTransaction = true
                        }) {
                            Label("取引を追加", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                            Section(header: Text(formatSectionDate(date))) {
                                ForEach(groupedTransactions[date] ?? []) { transaction in
                                    TransactionListRow(transaction: transaction)
                                }
                                .onDelete { indexSet in
                                    deleteTransactions(at: indexSet, for: date)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("取引履歴")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
        }
    }
    
    // 日付でグループ化
    var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            formatDate(transaction.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatSectionDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今日"
        } else if calendar.isDateInYesterday(date) {
            return "昨日"
        } else {
            formatter.dateFormat = "M月d日(E)"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet, for dateString: String) {
        guard let transactions = groupedTransactions[dateString] else { return }
        for index in offsets {
            let transaction = transactions[index]
            viewModel.deleteTransaction(transaction)
        }
    }
}

struct TransactionListRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // カテゴリアイコン
            Text(transaction.category.icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(transaction.type.color.opacity(0.1))
                .cornerRadius(8)
            
            // 詳細
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.headline)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 金額
            Text("\(transaction.type == .income ? "+" : "-")¥\(Int(transaction.amount))")
                .font(.headline)
                .foregroundColor(transaction.type.color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionListView(viewModel: TransactionViewModel())
}
