import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';

class IndianEquityTicker {
  final String symbol;
  final String name;
  final String series;
  final String dateOfListing;
  final double paidUpValue;
  final int marketLot;
  final String isin;
  final double faceValue;

  const IndianEquityTicker({
    required this.symbol,
    required this.name,
    required this.series,
    required this.dateOfListing,
    required this.paidUpValue,
    required this.marketLot,
    required this.isin,
    required this.faceValue,
  });

  @override
  String toString() {
    return 'IndianEquityTicker(symbol: $symbol, name: $name, series: $series, isin: $isin, faceValue: $faceValue)';
  }
}

class TickerLoaderService {
  static final TickerLoaderService _instance = TickerLoaderService._internal();
  TickerLoaderService._internal();
  factory TickerLoaderService() => _instance;

  List<IndianEquityTicker> _cachedTickers = [];
  bool _isLoading = false;

  List<IndianEquityTicker> get cachedTickers => _cachedTickers;
  bool get isLoading => _isLoading;

  Future<List<IndianEquityTicker>> loadTickers() async {
    if (_cachedTickers.isNotEmpty) {
      return _cachedTickers;
    }
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedTickers;
    }

    _isLoading = true;
    try {
      final bytes = await rootBundle.load('assets/securities/indian_equity_ticker.xlsx');
      final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
      
      final List<IndianEquityTicker> tickers = [];
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;
        
        // Find column indices based on headers
        int symbolIdx = -1;
        int nameIdx = -1;
        int seriesIdx = -1;
        int dateIdx = -1;
        int paidUpIdx = -1;
        int marketLotIdx = -1;
        int isinIdx = -1;
        int faceValIdx = -1;

        if (sheet.rows.isEmpty) continue;

        final headerRow = sheet.rows.first;
        for (int i = 0; i < headerRow.length; i++) {
          final val = headerRow[i]?.value?.toString().toUpperCase().trim() ?? '';
          if (val == 'SYMBOL') symbolIdx = i;
          else if (val == 'NAME OF COMPANY') nameIdx = i;
          else if (val == 'SERIES') seriesIdx = i;
          else if (val == 'DATE OF LISTING') dateIdx = i;
          else if (val == 'PAID UP VALUE') paidUpIdx = i;
          else if (val == 'MARKET LOT') marketLotIdx = i;
          else if (val == 'ISIN NUMBER') isinIdx = i;
          else if (val == 'FACE VALUE') faceValIdx = i;
        }

        // If we didn't find symbol or name, try using default column indices if columns match structure
        if (symbolIdx == -1) symbolIdx = 0;
        if (nameIdx == -1) nameIdx = 1;
        if (seriesIdx == -1) seriesIdx = 2;
        if (dateIdx == -1) dateIdx = 3;
        if (paidUpIdx == -1) paidUpIdx = 4;
        if (marketLotIdx == -1) marketLotIdx = 5;
        if (isinIdx == -1) isinIdx = 6;
        if (faceValIdx == -1) faceValIdx = 7;

        for (int r = 1; r < sheet.rows.length; r++) {
          final row = sheet.rows[r];
          if (row.length <= symbolIdx || row[symbolIdx] == null) continue;

          final symbol = row[symbolIdx]?.value?.toString().trim() ?? '';
          if (symbol.isEmpty || symbol == 'SYMBOL') continue;

          final name = row.length > nameIdx && row[nameIdx] != null
              ? row[nameIdx]!.value.toString().trim()
              : '';
          final series = row.length > seriesIdx && row[seriesIdx] != null
              ? row[seriesIdx]!.value.toString().trim()
              : '';
          final dateOfListing = row.length > dateIdx && row[dateIdx] != null
              ? row[dateIdx]!.value.toString().trim()
              : '';
          
          final paidUpValStr = row.length > paidUpIdx && row[paidUpIdx] != null
              ? row[paidUpIdx]!.value.toString().trim()
              : '0';
          final paidUpValue = double.tryParse(paidUpValStr) ?? 0.0;

          final marketLotStr = row.length > marketLotIdx && row[marketLotIdx] != null
              ? row[marketLotIdx]!.value.toString().trim()
              : '1';
          final marketLot = int.tryParse(marketLotStr) ?? 1;

          final isin = row.length > isinIdx && row[isinIdx] != null
              ? row[isinIdx]!.value.toString().trim()
              : '';
          
          final faceValStr = row.length > faceValIdx && row[faceValIdx] != null
              ? row[faceValIdx]!.value.toString().trim()
              : '10';
          final faceValue = double.tryParse(faceValStr) ?? 10.0;

          tickers.add(IndianEquityTicker(
            symbol: symbol,
            name: name,
            series: series,
            dateOfListing: dateOfListing,
            paidUpValue: paidUpValue,
            marketLot: marketLot,
            isin: isin,
            faceValue: faceValue,
          ));
        }
      }

      _cachedTickers = tickers;
    } catch (e) {
      print('Error parsing ticker excel: $e');
    } finally {
      _isLoading = false;
    }
    return _cachedTickers;
  }

  List<IndianEquityTicker> searchTickers(String query) {
    if (query.isEmpty) return _cachedTickers;
    final normalized = query.toUpperCase();
    return _cachedTickers.where((ticker) {
      return ticker.symbol.toUpperCase().contains(normalized) ||
          ticker.name.toUpperCase().contains(normalized);
    }).toList();
  }
}
