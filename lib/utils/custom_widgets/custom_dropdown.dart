import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T?)? onChanged;
  final String hintText;
  final String? label;
  final TextStyle? textStyle;
  final Color dropdownColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double height;
  final String Function(T)? itemToString;
  final bool isEnabled;
  final bool isMandatory;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.hintText = "Select an item",
    this.label,
    this.textStyle,
    this.dropdownColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.height = 45.0,
    this.itemToString,
    this.isEnabled = true,
    this.isMandatory = false,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isOpen = false;
  List<T> _filteredItems = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay(rebuild: false);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredItems = widget.items
          .where((item) => (widget.itemToString != null
                  ? widget.itemToString!(item)
                  : item.toString())
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _removeOverlay({bool rebuild = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;

    if (mounted && rebuild) {
      setState(() {});
    }
  }

  void _showOverlay() {
    if (_isOpen) return;

    _removeOverlay();
    _searchController.clear();
    _filteredItems = widget.items;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop to close on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dropdown content
          Positioned(
            top: position.dy + widget.height + 4,
            left: position.dx,
            width: renderBox.size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: widget.dropdownColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: AppColors.greyLightBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0),
                      child: CustomInputField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hint: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        borderRadius: 8,
                        height: 40,
                        onChanged: (value) => _onSearchChanged(),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        // shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = widget.selectedItem == item;
                          final itemText = widget.itemToString != null
                              ? widget.itemToString!(item)
                              : item.toString();

                          return InkWell(
                            onTap: () {
                              widget.onChanged?.call(item);
                              _removeOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                        .withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryColor,
                                      size: 16,
                                    )
                                  else
                                    const SizedBox(width: 16),
                                  8.width,
                                  Expanded(
                                    child: Text(
                                      itemText,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.appBlack,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // No results message
                    if (_filteredItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });

    // Focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _searchFocusNode.requestFocus(); // Prevent keyboard from opening by default
    });
  }

  String _getDisplayText() {
    if (widget.selectedItem != null) {
      return widget.itemToString != null
          ? widget.itemToString!(widget.selectedItem as T)
          : widget.selectedItem.toString();
    }
    return widget.hintText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null || widget.hintText.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label ?? widget.hintText,
              style: Ts.regular14(
                widget.isEnabled ? AppColors.appBlack : AppColors.greyMidText,
              ),
              children: [
                if (widget.isMandatory)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          8.height,
        ],
        // Dropdown field
        GestureDetector(
          onTap: widget.isEnabled ? _showOverlay : null,
          child: Container(
            height: widget.height,
            width: MediaQuery.of(context).size.width,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? Colors.white
                  : AppColors.greyLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isOpen
                    ? AppColors.primaryColor
                    : AppColors.greyLightBorder,
                width: _isOpen ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: widget.textStyle?.copyWith(
                          color: widget.selectedItem != null
                              ? AppColors.appBlack
                              : Colors.grey.shade500,
                        ) ??
                        TextStyle(
                          color: widget.selectedItem != null
                              ? AppColors.appBlack
                              : Colors.grey.shade500,
                          fontSize: 15,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color:
                      widget.isEnabled ? AppColors.primaryColor : Colors.grey,
                  size: 24,
                ),
                if (widget.selectedItem != null && widget.isEnabled)
                  GestureDetector(
                    onTap: () {
                      widget.onChanged?.call(null);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ).paddingOnly(top: 8, bottom: 8);
  }
}
