import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class FontSettingBottomSheet extends StatefulWidget {
  final MemeText memeText;

  const FontSettingBottomSheet({
    Key? key,
    required this.memeText,
  }) : super(key: key);

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingsBottomSheetState();
}

class _FontSettingsBottomSheetState extends State<FontSettingBottomSheet> {
  late Color color;
  late double fontSize;
  late FontWeight fontWeight;

  @override
  void initState() {
    super.initState();
    color = widget.memeText.color;
    fontSize = widget.memeText.fontSize;
    fontWeight = widget.memeText.fontWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            height: 4,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.darkGrey38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        MemeTextOnCanvas(
          padding: 8,
          selected: true,
          parentConstraints: BoxConstraints.expand(),
          text: widget.memeText.text,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        const SizedBox(height: 48),
        FontSizeSlider(
          initialFontSize: fontSize,
          changeFontSize: (value) {
            setState(() => fontSize = value);
          },
        ),
        const SizedBox(height: 16),
        ColorSelection(
          changeColor: (color) {
            setState(() => this.color = color);
          },
        ),
        const SizedBox(height: 16),
        FontWeightSlider(
          initialFontWeight: fontWeight,
          changeFontWeight: (value) {
            setState(() => fontWeight = value);
          },
        ),
        const SizedBox(height: 36),
        Align(
          alignment: Alignment.centerRight,
          child: Buttons(
            textId: widget.memeText.id,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  final String textId;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const Buttons({
    Key? key,
    required this.textId,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () => Navigator.of(context).pop(),
          text: "Отмена",
          color: AppColors.darkGrey,
        ),
        const SizedBox(width: 24),
        AppButton(
          onTap: () {
            bloc.changeFontSetting(textId, color, fontSize, fontWeight);
            Navigator.of(context).pop();
          },
          text: "Сохранить",
          color: AppColors.fuchsia,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class ColorSelection extends StatelessWidget {
  final ValueChanged<Color> changeColor;

  const ColorSelection({
    Key? key,
    required this.changeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 16),
        Text("Color:", style: TextStyle(fontSize: 20, color: AppColors.darkGrey)),
        const SizedBox(width: 16),
        ColorSelectionBox(changeColor: changeColor, color: Colors.white),
        const SizedBox(width: 16),
        ColorSelectionBox(changeColor: changeColor, color: Colors.black),
        const SizedBox(width: 16),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  final ValueChanged<Color> changeColor;
  final Color color;

  const ColorSelectionBox({
    Key? key,
    required this.changeColor,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  const FontSizeSlider({
    Key? key,
    required this.changeFontSize,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Text("Size:", style: TextStyle(fontSize: 20, color: AppColors.darkGrey)),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 16,
              max: 32,
              divisions: 10,
              value: fontSize,
              label: fontSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FontWeightSlider extends StatefulWidget {
  final ValueChanged<FontWeight> changeFontWeight;
  final FontWeight initialFontWeight;

  const FontWeightSlider({
    Key? key,
    required this.changeFontWeight,
    required this.initialFontWeight,
  }) : super(key: key);

  @override
  State<FontWeightSlider> createState() => _FontWeightSliderState();
}

class _FontWeightSliderState extends State<FontWeightSlider> {
  late FontWeight fontWeight;

  @override
  void initState() {
    super.initState();
    fontWeight = widget.initialFontWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Text("Font Weight:", style: TextStyle(fontSize: 20, color: AppColors.darkGrey)),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: FontWeight.w100.index.toDouble(),
              max: FontWeight.w900.index.toDouble(),
              divisions: FontWeight.w900.index - FontWeight.w100.index,
              value: fontWeight.index.toDouble(),
              onChanged: (double value) {
                setState(() {
                  fontWeight = FontWeight.values
                      .firstWhere((fontWeight) => fontWeight.index == value.toInt());
                  widget.changeFontWeight(fontWeight);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
