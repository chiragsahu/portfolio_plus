import 'package:portfolio_plus/modules/tools/models/mutual_fund.dart';

class MutualFundService {
  static List<MutualFund> getSampleFunds() {
    return [
      MutualFund(
        id: '1',
        name: 'HDFC Top 100 Fund',
        code: '118932',
        fundHouse: 'HDFC Mutual Fund',
        category: 'Large Cap',
        type: 'Equity',
        expenseRatio: 1.25,
        aum: 28456.78, // in crores
        riskRating: 3.5,
        nav: 892.45,
        returns: const {
          '1Y': 12.5,
          '3Y': 14.2,
          '5Y': 16.8,
        },
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        navHistory: _generateSampleNavHistory(892.45),
        description: 'An open-ended equity scheme investing in large cap companies',
        fundManager: 'Rakesh Jhunjhunwala',
        inceptionDate: DateTime(2015, 6, 15),
      ),
      MutualFund(
        id: '2',
        name: 'ICICI Prudential Bluechip Fund',
        code: '127844',
        fundHouse: 'ICICI Prudential Mutual Fund',
        category: 'Large Cap',
        type: 'Equity',
        expenseRatio: 1.18,
        aum: 32145.67,
        riskRating: 3.2,
        nav: 567.89,
        returns: const {
          '1Y': 11.8,
          '3Y': 13.5,
          '5Y': 15.2,
        },
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        navHistory: _generateSampleNavHistory(567.89),
        description: 'An open-ended large-cap equity fund',
        fundManager: 'Chaitanya Pande',
        inceptionDate: DateTime(2013, 5, 20),
      ),
      MutualFund(
        id: '3',
        name: 'SBI Small Cap Fund',
        code: '120643',
        fundHouse: 'SBI Mutual Fund',
        category: 'Small Cap',
        type: 'Equity',
        expenseRatio: 1.65,
        aum: 12456.32,
        riskRating: 4.2,
        nav: 234.56,
        returns: const {
          '1Y': 18.5,
          '3Y': 22.1,
          '5Y': 24.3,
        },
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        navHistory: _generateSampleNavHistory(234.56),
        description: 'An open-ended small-cap equity fund',
        fundManager: 'R. Srinivasan',
        inceptionDate: DateTime(2010, 9, 10),
      ),
      MutualFund(
        id: '4',
        name: 'Axis Bluechip Fund',
        code: '120793',
        fundHouse: 'Axis Mutual Fund',
        category: 'Large Cap',
        type: 'Equity',
        expenseRatio: 1.32,
        aum: 27890.45,
        riskRating: 3.3,
        nav: 445.67,
        returns: const {
          '1Y': 13.2,
          '3Y': 15.8,
          '5Y': 17.5,
        },
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        navHistory: _generateSampleNavHistory(445.67),
        description: 'An open-ended large-cap equity fund',
        fundManager: 'Shreyash Devalkar',
        inceptionDate: DateTime(2013, 1, 3),
      ),
      MutualFund(
        id: '5',
        name: 'Kotak Emerging Equity Fund',
        code: '132345',
        fundHouse: 'Kotak Mahindra Mutual Fund',
        category: 'Mid Cap',
        type: 'Equity',
        expenseRatio: 1.45,
        aum: 15678.90,
        riskRating: 3.8,
        nav: 178.90,
        returns: const {
          '1Y': 16.5,
          '3Y': 19.2,
          '5Y': 21.8,
        },
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        navHistory: _generateSampleNavHistory(178.90),
        description: 'An open-ended mid-cap equity fund',
        fundManager: 'Pankaj Tibrewal',
        inceptionDate: DateTime(2014, 3, 25),
      ),
    ];
  }

  static List<NavData> _generateSampleNavHistory(double currentNav) {
    final List<NavData> navHistory = [];
    final now = DateTime.now();
    
    for (int i = 365; i >= 0; i -= 7) {
      final date = now.subtract(Duration(days: i));
      final randomFactor = 0.95 + (i % 20) * 0.005; // Simulate NAV fluctuation
      final nav = currentNav * randomFactor;
      navHistory.add(NavData(date: date, nav: nav));
    }
    
    return navHistory;
  }

  static Future<List<MutualFund>> searchFunds(String query) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allFunds = getSampleFunds();
    if (query.isEmpty) return allFunds;
    
    return allFunds.where((fund) {
      return fund.name.toLowerCase().contains(query.toLowerCase()) ||
             fund.fundHouse.toLowerCase().contains(query.toLowerCase()) ||
             fund.category.toLowerCase().contains(query.toLowerCase()) ||
             fund.code.contains(query);
    }).toList();
  }

  static Future<MutualFund?> getFundById(String id) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return getSampleFunds().firstWhere((fund) => fund.id == id);
    } catch (e) {
      return null;
    }
  }
}