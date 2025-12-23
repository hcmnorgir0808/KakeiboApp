import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            TransactionListView(viewModel: viewModel)
                .tabItem {
                    Label("履歴", systemImage: "list.bullet")
                }
                .tag(2)
        }
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 残高カード
                    VStack(spacing: 10) {
                        Text("現在の残高")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("¥\(Int(viewModel.balance))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // 今月の収支
                    HStack(spacing: 15) {
                        // 収入
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.green)
                                Text("収入")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("¥\(Int(viewModel.currentMonthIncome))")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        
                        // 支出
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.red)
                                Text("支出")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("¥\(Int(viewModel.currentMonthExpense))")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // 最近の取引
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最近の取引")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.transactions.isEmpty {
                            Text("取引がありません")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(Array(viewModel.transactions.prefix(5))) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("家計簿")
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
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
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
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 金額と日付
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")¥\(Int(transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.type.color)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
