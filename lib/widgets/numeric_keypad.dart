import 'package:flutter/material.dart';

class NumericKeypad extends StatefulWidget {
  final Function(String) onHymnSelected;
  final VoidCallback onClose;

  const NumericKeypad({
    super.key,
    required this.onHymnSelected,
    required this.onClose,
  });

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  String _input = '';

  void _onDigit(String digit) {
    if (_input.length < 3) {
      setState(() {
        _input += digit;
      });
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _input = '';
    });
  }

  void _onSubmit() {
    if (_input.isNotEmpty) {
      widget.onHymnSelected(_input);
      _onClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Input Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_hide),
                  onPressed: widget.onClose,
                  tooltip: 'Hide Keypad',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      _input.isEmpty ? 'Enter hymn number...' : _input,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _input.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: _onBackspace,
                ),
              ],
            ),
          ),

          // Keypad Grid
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _buildRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _buildRow(['7', '8', '9']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildButton(
                      'C', 
                      onTap: _onClear, 
                      color: theme.colorScheme.errorContainer,
                      textColor: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    _buildButton('0', onTap: () => _onDigit('0')),
                    const SizedBox(width: 8),
                    _buildButton(
                      'GO', 
                      onTap: _onSubmit, 
                      color: theme.colorScheme.primary,
                      textColor: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom Padding for Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: [
        _buildButton(digits[0], onTap: () => _onDigit(digits[0])),
        const SizedBox(width: 8),
        _buildButton(digits[1], onTap: () => _onDigit(digits[1])),
        const SizedBox(width: 8),
        _buildButton(digits[2], onTap: () => _onDigit(digits[2])),
      ],
    );
  }

  Widget _buildButton(
    String label, {
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.surfaceContainerHigh;
    final fgColor = textColor ?? theme.colorScheme.onSurface;

    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
