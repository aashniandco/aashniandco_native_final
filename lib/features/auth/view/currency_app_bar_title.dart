import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/currency_bloc.dart';
import '../bloc/currency_event.dart';
import '../bloc/currency_state.dart';
// Import your CurrencyBloc and states
// import 'path/to/your/currency_bloc.dart';

/// A reusable widget for the AppBar title that includes the logo
/// and the currency selection dropdown.
class CurrencyAppBarTitle extends StatelessWidget {
  /// A callback function that is triggered when the user selects a new currency.
  /// It passes the selected currency code (e.g., "USD", "INR").
  final ValueChanged<String> onCurrencyChanged;

  const CurrencyAppBarTitle({
    super.key,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    // This is the exact code from your _buildResponsiveAppBarTitle method.
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        // --- Handle Loading and Error States First ---
        if (state is CurrencyLoading || state is CurrencyInitial) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
            ),
          );
        }
        if (state is CurrencyError) {
          return Tooltip(
            message: state.message,
            child: const Icon(Icons.error_outline, color: Colors.red),
          );
        }

        // --- Handle the Success State ---
        if (state is CurrencyLoaded) {
          return Row(
            children: [
              Image.asset('assets/logo.jpeg', height: 30),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedCurrencyCode,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        // 1. Notify the BLoC to update the UI state
                        context.read<CurrencyBloc>().add(ChangeCurrency(newCode));
                        // 2. Use the callback to trigger the API call in the parent screen
                        onCurrencyChanged(newCode);
                      }
                    },
                    selectedItemBuilder: (context) {
                      return state.currencyData.availableCurrencyCodes
                          .map((_) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${state.selectedCurrencyCode} | ${state.selectedSymbol}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList();
                    },
                    items: state.currencyData.availableCurrencyCodes.map((code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }

        // Fallback for any other unhandled state
        return const SizedBox.shrink();
      },
    );
  }
}