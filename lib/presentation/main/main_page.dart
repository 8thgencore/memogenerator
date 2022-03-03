import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memogenerator/presentation/main/models/template_full.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitDialog(context);
          return goBack ?? false;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: GestureDetector(
                onLongPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EasterEggPage(),
                  ));
                },
                child: Text(
                  "Мемогенератор",
                  style: GoogleFonts.seymourOne(fontSize: 24),
                ),
              ),
              bottom: TabBar(
                labelColor: AppColors.darkGrey,
                indicatorColor: AppColors.fuchsia,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Созданные".toUpperCase()),
                  Tab(text: "Шаблоны".toUpperCase()),
                ],
              ),
            ),
            floatingActionButton: CreateMemFab(),
            backgroundColor: Colors.white,
            body: TabBarView(
              children: [
                SafeArea(child: CreatedMemesGrid()),
                SafeArea(child: TemplatesGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> showConfirmationExitDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Точно хотите выйти?"),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16),
          content: Text("Мемы сами себя не сделают"),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: "Остаться",
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: "Выйти",
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class CreateMemFab extends StatelessWidget {
  const CreateMemFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
      onPressed: () async {
        final selectedMemePath = await bloc.selectMeme();
        if (selectedMemePath == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateMemePage(
              selectedMemePath: selectedMemePath,
            ),
          ),
        );
      },
      backgroundColor: AppColors.fuchsia,
      icon: Icon(Icons.add, color: Colors.white),
      label: Text("Мем"),
    );
  }
}

class CreatedMemesGrid extends StatelessWidget {
  const CreatedMemesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MemesWithDocsPath>(
      stream: bloc.observeMemesWithDocsPath(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final items = snapshot.requireData.memes;
        final docsPath = snapshot.requireData.docsPath;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: items.map((item) {
            return MemeGridItem(meme: item, docsPath: docsPath);
          }).toList(),
        );
      },
    );
  }
}

class DeleteElevatedButton extends StatelessWidget {
  const DeleteElevatedButton({
    required this.id,
    required this.object,
    Key? key,
  }) : super(key: key);

  final String id;
  final String object;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          primary: AppColors.darkGrey38,
        ),
        child: Icon(
          Icons.delete_outline,
          size: 18,
        ),
        onPressed: () async {
          final delete = await showAlertDialog(context, object) ?? false;
          if (delete == true) {
            if (object == "мем") {
              bloc.deleteMeme(id);
            } else {
              bloc.deleteTemplate(id);
            }
          }
        },
      ),
    );
  }

  Future<bool?> showAlertDialog(BuildContext context, String object) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Удалить $object?"),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16),
          content: Text("Выбранный $object будет удален навсегда"),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: "Отмена",
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: "Удалить",
            ),
          ],
        );
      },
    );
  }
}

class MemeGridItem extends StatelessWidget {
  const MemeGridItem({
    Key? key,
    required this.docsPath,
    required this.meme,
  }) : super(key: key);

  final Meme meme;
  final String docsPath;

  @override
  Widget build(BuildContext context) {
    final imageFile = File("$docsPath${Platform.pathSeparator}${meme.id}.png");
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return CreateMemePage(id: meme.id);
                },
              ),
            );
          },
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey, width: 1),
            ),
            child: imageFile.existsSync() ? Image.file(imageFile) : Text(meme.id),
          ),
        ),
        DeleteElevatedButton(id: meme.id, object: "мем"),
      ],
    );
  }
}

class TemplatesGrid extends StatelessWidget {
  const TemplatesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<TemplateFull>>(
      stream: bloc.observeTemplates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final templates = snapshot.requireData;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: templates.map((template) {
            return TemplateGridItem(template: template);
          }).toList(),
        );
      },
    );
  }
}

class TemplateGridItem extends StatelessWidget {
  const TemplateGridItem({
    Key? key,
    required this.template,
  }) : super(key: key);

  final TemplateFull template;

  @override
  Widget build(BuildContext context) {
    final imageFile = File(template.fullImagePath);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateMemePage(
                  selectedMemePath: template.fullImagePath,
                ),
              ),
            );
          },
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey, width: 1),
            ),
            child: imageFile.existsSync() ? Image.file(imageFile) : Text(template.id),
          ),
        ),
        DeleteElevatedButton(id: template.id, object: "шаблон"),
      ],
    );
  }
}
