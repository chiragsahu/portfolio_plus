import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class CustomInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final Color labelColor;
  final TextInputType? keyboardType;
  final bool hasLabelStar;
  final bool readOnly;
  final bool hasLabelOptional;
  final Widget? rightIcon;
  final Widget? prefixIcon;
  final double borderRadius;
  final int? maxLines;
  final double? height; // New height parameter
  final bool? enabled;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? error;
  final Function()? onTap;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final InputBorder? borderData;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    super.key,
    this.label,
    required this.controller,
    this.keyboardType,
    this.hasLabelStar = false,
    this.rightIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.hasLabelOptional = false,
    this.borderRadius = 12,
    this.maxLines = 1,
    this.height, // Added to constructor
    this.hint,
    this.onChanged,
    this.enabled,
    this.maxLength,
    this.error,
    this.onTap,
    this.suffixIcon,
    this.focusNode,
    this.inputFormatters,
    this.obscureText = false,
    this.validator,
    this.fillColor,
    this.labelColor = AppColors.appBlack,
    this.borderData,
    this.hintStyle,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    if (widget.obscureText) {
      _obscureText = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: Ts.regular12(widget.labelColor),
          ),
        SizedBox(
          height: widget.height, // Use height if provided
          child: TextFormField(
            onTap: widget.onTap,
            inputFormatters: widget.inputFormatters,
            keyboardType: _obscureText
                ? TextInputType.visiblePassword
                : widget.keyboardType,
            focusNode: widget.focusNode,
            controller: widget.controller,
            cursorColor: AppColors.primaryColor,
            enabled: widget.enabled ?? true,
            obscureText: _obscureText,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              errorText:
                  widget.error?.trim().isNotEmpty == true ? widget.error : null,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: widget.fillColor ?? AppColors.bgGreyColor,
              border: widget.borderData,
              enabledBorder: widget.borderData ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: const BorderSide(
                      color: AppColors.white,
                      width: 0,
                    ),
                  ),
              focusedBorder: widget.borderData ??
                  OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius - 2),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.0,
                    ),
                  ),
              hintText: widget.hint ?? "",
              hintStyle: widget.hintStyle ??
                  GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: (widget.focusNode?.hasFocus ?? false)
                        ? AppColors.secendaryDarkColor
                        : AppColors.greyMidText,
                  ),
              floatingLabelStyle: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.greyMidText,
              ),
              labelStyle: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.grey,
              ),
            ),
            validator: widget.validator,
          ),
        ).paddingOnly(top: 8, bottom: 8),
      ],
    );
  }
}
