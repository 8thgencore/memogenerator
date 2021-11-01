import 'package:flutter/material.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/blocs/main_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

class CreateMemePage extends StatefulWidget {
  @override
  _CreateMemePageState createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          backwardsCompatibility: false,
          title: Text("Создаем мем"),
          bottom: EditTextBar(),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  _EditTextBarState createState() => _EditTextBarState();

  @override
  Size get preferredSize => Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
        stream: bloc.observeSelectedMemeText(),
        builder: (context, snapshot) {
          final MemeText? selectedMemeText = snapshot.hasData ? snapshot.data : null;
          if (selectedMemeText?.text != controller.text) {
            controller.text = selectedMemeText?.text ?? "";
          }
          return TextField(
            enabled: selectedMemeText != null,
            controller: controller,
            onChanged: (text) {
              if (selectedMemeText != null) {
                bloc.changeMemeText(selectedMemeText.id, text);
              }
            },
            onEditingComplete: () => bloc.deselectMemeText(),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkGrey6,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
     controller.dispose();
     super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  @override
  _CreateMemePageContentState createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  final FocusNode searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Container(height: 1, width: double.infinity, color: AppColors.darkGrey),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: ListView(
              children: [
                const SizedBox(height: 12),
                const AddNewMemeTextButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.white,
          child: StreamBuilder<List<MemeText>>(
            initialData: const <MemeText>[],
            stream: bloc.observeMemeTexts(),
            builder: (context, snapshot) {
              final memeTexts = snapshot.hasData ? snapshot.data! : const <MemeText>[];
              return Column(
                children: memeTexts.map((memeText) => Text(memeText.text)).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppColors.fuchsia),
              const SizedBox(width: 8),
              Text(
                "Добавить текст".toUpperCase(),
                style: TextStyle(
                  color: AppColors.fuchsia,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
