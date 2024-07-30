import 'package:flutter/material.dart';

Widget decContainer({
  double? radius,
  double? height,
  double? width,
  double? leftPadding,
  double? topPadding,
  double? rightPadding,
  double? bottomPadding,
  double? borderWidth,
  Color? color,
  Color? foregroundColor,
  Color? borderColor,
  double? allPadding,
  double? leftBorderWidth,
  double? topBorderWidth,
  double? rightBorderWidth,
  double? bottomBorderWidth,
  Color? leftBorderColor,
  Color? topBorderColor,
  Color? rightBorderColor,
  Color? bottomBorderColor,
  Widget? child,
  Function()? onTap,
  double? topLeftRadius,
  double? topRightRadius,
  double? bottomLeftRadius,
  double? bottomRightRadius,
  BoxShadow? boxShadow,
  EdgeInsetsGeometry? margin,
  Alignment? alignment,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: onTap,
    child: Container(
      alignment: alignment,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(color: foregroundColor),
      padding: EdgeInsets.only(
        left: leftPadding ?? allPadding ?? 0,
        top: topPadding ?? allPadding ?? 0,
        right: rightPadding ?? allPadding ?? 0,
        bottom: bottomPadding ?? allPadding ?? 0,
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        boxShadow: boxShadow != null ? [boxShadow] : null,
        color: color,
        border: borderWidth != null && borderColor != null
            ? Border.all(
                width: borderWidth,
                color: borderColor,
              )
            : Border(
                left: BorderSide(
                  width: leftBorderWidth ?? borderWidth ?? 0,
                  color: leftBorderColor ?? borderColor ?? Colors.transparent,
                ),
                top: BorderSide(
                  width: topBorderWidth ?? borderWidth ?? 0,
                  color: topBorderColor ?? borderColor ?? Colors.transparent,
                ),
                right: BorderSide(
                  width: rightBorderWidth ?? borderWidth ?? 0,
                  color: rightBorderColor ?? borderColor ?? Colors.transparent,
                ),
                bottom: BorderSide(
                  width: bottomBorderWidth ?? borderWidth ?? 0,
                  color: bottomBorderColor ?? borderColor ?? Colors.transparent,
                ),
              ),
        borderRadius: radius != null
            ? BorderRadius.circular(radius)
            : BorderRadius.only(
                topLeft: Radius.circular(topLeftRadius ?? 0),
                topRight: Radius.circular(topRightRadius ?? 0),
                bottomLeft: Radius.circular(bottomLeftRadius ?? 0),
                bottomRight: Radius.circular(bottomRightRadius ?? 0),
              ),
      ),
      child: child,
    ),
  );
}

Widget styledText({
  required String text,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  Color? decorationColor,
  TextDecoration? decoration,
  double? height,
  TextAlign? textAlign,
  bool? showShimmer,
  double? shimmerRadius,
  double? shimmerWidth,
  TextOverflow? overflow,
  bool shimmerWithoutOpacity = false,
  Function()? onTap,
  int? maxLines,
}) {
  final textStyle = TextStyle(
    overflow: overflow,
    fontSize: fontSize,
    color: color,
    decoration: decoration,
    decorationColor: decorationColor,
    height: height,
    fontWeight: fontWeight,
  );

  return GestureDetector(
    onTap: showShimmer != null && showShimmer ? null : onTap,
    child: Text(
      maxLines: maxLines,
      text,
      style: textStyle,
      textAlign: textAlign,
    ),
  );
}

Widget widthSeparator(double value) {
  return SizedBox(
    width: value,
  );
}

Widget heightSeparator(double value) {
  return SizedBox(
    height: value,
  );
}
