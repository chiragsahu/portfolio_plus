import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/services/ticker_loader_service.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class SearchableTickerDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<IndianEquityTicker> onSelected;
  final String label;
  final String hint;

  const SearchableTickerDropdown({
    super.key,
    this.initialValue,
    required this.onSelected,
    this.label = 'Search Ticker Symbol',
    this.hint = 'Search by Symbol or Company Name',
  });

  @override
  State<SearchableTickerDropdown> createState() => _SearchableTickerDropdownState();
}

class _SearchableTickerDropdownState extends State<SearchableTickerDropdown> {
  final TickerLoaderService _tickerLoader = TickerLoaderService();
  String? _selectedSymbol;
  String? _selectedName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSymbol = widget.initialValue;
    _initTickerData();
  }

  Future<void> _initTickerData() async {
    setState(() {
      _isLoading = true;
    });
    final tickers = await _tickerLoader.loadTickers();
    if (_selectedSymbol != null) {
      final matched = tickers.firstWhere(
        (t) => t.symbol.toUpperCase() == _selectedSymbol!.toUpperCase(),
        orElse: () => IndianEquityTicker(
          symbol: _selectedSymbol!,
          name: _selectedSymbol!,
          series: '',
          dateOfListing: '',
          paidUpValue: 0,
          marketLot: 1,
          isin: '',
          faceValue: 10,
        ),
      );
      _selectedName = matched.name;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TickerSearchSheet(
          tickerLoader: _tickerLoader,
          hint: widget.hint,
          onSelected: (ticker) {
            setState(() {
              _selectedSymbol = ticker.symbol;
              _selectedName = ticker.name;
            });
            widget.onSelected(ticker);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Ts.semiBold16(AppColors.black),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoading ? null : _showSearchBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? const Text(
                          'Loading tickers...',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      : Text(
                          _selectedSymbol != null
                              ? '$_selectedSymbol - $_selectedName'
                              : 'Select Ticker Symbol',
                          style: TextStyle(
                            color: _selectedSymbol != null ? AppColors.black : Colors.grey,
                            fontWeight: _selectedSymbol != null ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TickerSearchSheet extends StatefulWidget {
  final TickerLoaderService tickerLoader;
  final String hint;
  final ValueChanged<IndianEquityTicker> onSelected;

  const _TickerSearchSheet({
    required this.tickerLoader,
    required this.hint,
    required this.onSelected,
  });

  @override
  State<_TickerSearchSheet> createState() => _TickerSearchSheetState();
}

class _TickerSearchSheetState extends State<_TickerSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<IndianEquityTicker> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _results = widget.tickerLoader.cachedTickers;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _results = widget.tickerLoader.searchTickers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      height: mediaQuery.size.height * 0.75,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle indicator
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Results header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSearching ? 'Search Results' : 'All Equities',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  '${_results.length} found',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          // List view
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final ticker = _results[index];
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticker.symbol,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (ticker.series.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticker.series,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        ticker.name,
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ISIN: ${ticker.isin}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            'Face Value: ₹${ticker.faceValue}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => widget.onSelected(ticker),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
