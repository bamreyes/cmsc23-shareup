import 'package:flutter/material.dart';

/*
HOW TO USE:
labelText for an added label on top of the textfield
hintText for the placeholder
suffixIcon for icons on the right side
hasAsterisk for an added asterisk on the label (for required fields)
hiddenText for password fields (cannot be used with TextInputType.multiline!!)
maxLines for multiline fields (use with TextInputType.multiline)
readOnly for non-editable fields like date pickers
onTap for handling taps on readOnly fields
AutovalidateMode for auto validation for UX
*/

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? suffixIcon;
  final bool hiddenText;
  final bool hasAsterisk;
  final bool readOnly;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.suffixIcon,
    this.hiddenText = false,
    this.hasAsterisk = false,
    this.readOnly = false,
    this.maxLines,
    this.keyboardType,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.onChanged,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.hiddenText;
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    // Password fields get a visibility toggle
    if (widget.hiddenText) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          size: 20,
        ),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      );
    }

    // All other fields use the provided suffixIcon (or null)
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (widget.hasAsterisk)
                Text(" *", style: TextStyle(color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.hiddenText ? 1 : (widget.maxLines ?? 1),
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onSaved: widget.onSaved,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          onChanged: widget.onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: _buildSuffixIcon(colorScheme),
          ),
        ),
      ],
    );
  }
}
