import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/modules/settings/provider/settings_provider.dart';
import 'package:portfolio_plus/utils/custom_widgets/custom_dropdown.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';
import 'package:portfolio_plus/utils/enums/currency.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _usdInrController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usdInrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: settingsAsync.when(
        data: (state) => _buildBody(context, state, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildError(e, notifier),
      ),
    );
  }

  Widget _buildError(Object e, SettingsNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text('Failed to load settings', style: Ts.regular16(Colors.red)),
          const SizedBox(height: 6),
          Text(e.toString(), style: Ts.regular12(AppColors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => notifier.setBaseCurrency(Currency.inr),
            child: const Text('Reset Base Currency (INR)'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SettingsState state, SettingsNotifier notifier) {
    const currencyItems = Currency.values;

    // Keep controller synced with state without using ref.listen in initState
    final String fxTxt = (state.usdInrRate != null) ? state.usdInrRate!.toString() : '';
    if (_usdInrController.text != fxTxt) {
      _usdInrController.text = fxTxt;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General', style: Ts.semiBold18(AppColors.black)),
          const SizedBox(height: 12),

          // Base currency selection
          CustomDropdown<Currency>(
            label: 'Base Currency',
            hintText: 'Select base currency',
            items: currencyItems,
            selectedItem: state.baseCurrency,
            itemToString: (c) => c.displayName,
            onChanged: (c) {
              if (c != null) {
                notifier.setBaseCurrency(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Base currency set to ${c.displayName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            isMandatory: true,
          ),

          const SizedBox(height: 20),

          _InfoTile(
            icon: Icons.info_outline,
            title: 'Display Currency',
            subtitle: 'Numbers will be shown in ${state.baseCurrency.displayName}',
          ),

          const SizedBox(height: 28),

          Text('Currency Conversion', style: Ts.semiBold18(AppColors.black)),
          const SizedBox(height: 12),

          const _InfoTile(
            icon: Icons.currency_exchange,
            title: 'USD ↔ INR',
            subtitle: 'Provide USD to INR rate for conversions between these currencies.',
          ),

          const SizedBox(height: 12),

          // USD - INR rate input
          CustomInputField(
            label: 'USD → INR Rate',
            controller: _usdInrController,
            hint: 'e.g. 83.25',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            borderRadius: 12,
            fillColor: Colors.grey[100],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: () {
                  final txt = _usdInrController.text.trim();
                  if (txt.isEmpty) {
                    notifier.setUsdInrRate(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cleared USD→INR rate')),
                    );
                    return;
                  }
                  final parsed = double.tryParse(txt);
                  if (parsed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid number for USD→INR rate'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  notifier.setUsdInrRate(parsed);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('USD→INR rate saved: $parsed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _usdInrController.clear();
                },
                label: const Text('Clear'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Summary
          _SummaryCard(
            currency: state.baseCurrency,
            usdInr: _usdInrController.text.trim().isEmpty ? null : double.tryParse(_usdInrController.text.trim()),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLightBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Ts.semiBold14(AppColors.black)),
                const SizedBox(height: 4),
                Text(subtitle, style: Ts.regular12(AppColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Currency currency;
  final double? usdInr;

  const _SummaryCard({
    required this.currency,
    required this.usdInr,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _kv('Base Currency', currency.displayName),
      _kv('Symbol', currency.symbol),
      _kv('Code', currency.code),
    ];
    rows.add(_kv('USD→INR', usdInr != null ? usdInr!.toString() : 'Not set'));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Current Settings', style: Ts.semiBold16(AppColors.black)),
          const SizedBox(height: 12),
          ...rows,
        ]),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k, style: Ts.regular14(AppColors.grey))),
          const SizedBox(width: 12),
          Text(v, style: Ts.semiBold14(AppColors.black)),
        ],
      ),
    );
  }
}