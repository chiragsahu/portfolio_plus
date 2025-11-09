import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';

class CustomDatePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final bool hasLabelStar;
  final bool hasLabelOptional;
  final double borderRadius;
  final String? error;
  final Function(DateTime)? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled; // Added enabled parameter
  final bool preventFocusRestore; // New parameter to prevent focus restore

  const CustomDatePicker({
    super.key,
    this.label,
    this.hint,
    required this.controller,
    this.hasLabelStar = false,
    this.hasLabelOptional = false,
    this.borderRadius = 12,
    this.error,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.enabled = true, // Default is true
    this.preventFocusRestore = true, // Default to true to prevent focus restore
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return; // If disabled, prevent date selection

    DateTime initialDate = DateTime.now();
    try {
      if (widget.controller.text.isNotEmpty) {
        initialDate = DateTime.parse(widget.controller.text);
      }
    } catch (e) {
      // If parsing fails, keep initialDate as now
    }

    // Create a new context that won't affect the focus of the original form
    final BuildContext dialogContext = context;
    
    // Use a builder to create a new context for the date picker
    final DateTime? picked = await showDialog<DateTime>(
      context: dialogContext,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 300,
            height: 400,
            child: CalendarDatePicker(
              initialDate: initialDate,
              firstDate: widget.firstDate ?? DateTime(2000),
              lastDate: widget.lastDate ?? DateTime(2100),
              onDateChanged: (date) {
                Navigator.of(context).pop(date);
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      widget.controller.text = picked.toIso8601String().split('T').first;
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
      
      // Force a rebuild to show the updated date
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            RichText(
              text: TextSpan(
                text: widget.label!,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: widget.enabled
                      ? AppColors.grey
                      : AppColors.grey.withValues(alpha: 0.5),
                ),
                children: [
                  if (widget.hasLabelStar)
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.openSans(
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _selectDate(context),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppColors.white
                    : AppColors.greyLightBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.enabled
                      ? AppColors.greyMidText
                      : AppColors.greyMidText.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.controller.text.isNotEmpty
                          ? widget.controller.text
                          : widget.hint ?? "",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: widget.controller.text.isNotEmpty
                            ? (widget.enabled ? AppColors.appBlack : AppColors.greyMidText)
                            : AppColors.greyMidText,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today, color: AppColors.greyMidText),
                ],
              ),
            ),
          ),
          if (widget.error != null && widget.error!.trim().isNotEmpty) ...[
            4.height,
            Text(
              widget.error!,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ).paddingOnly(top: 10, bottom: 10),
    );
  }
}
