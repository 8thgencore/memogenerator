import 'dart:io';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class SaveMemeInteractor {
  static const memesPathName = "memes";

  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() => _instance ?? SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    final String? imagePath,
  }) async {
    if (imagePath == null) {
      final meme = Meme(id: id, texts: textWithPositions);
      return MemesRepository.getInstance().addToMemes(meme);
    }
    await createNewFile(imagePath);

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: imagePath,
    );
    return MemesRepository.getInstance().addToMemes(meme);
  }

  Future<void> createNewFile(final String imagePath) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memeDirectoryPath = "${docsPath.absolute.path}${Platform.pathSeparator}$memesPathName";
    final memesDirectory = Directory(memeDirectoryPath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    final tempFile = File(imagePath);
    final imageName = _getFileNameByPath(imagePath);
    final newImagePath = "$memeDirectoryPath${Platform.pathSeparator}$imageName";

    // check for exists file
    final oldFileWithTheSameName = currentFiles.firstWhereOrNull(
      (element) {
        return _getFileNameByPath(element.path) == imageName && element is File;
      },
    );
    if (oldFileWithTheSameName == null) {
      await tempFile.copy(newImagePath);
      return;
    }

    // check different length file
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return;
    }

    return _createFileForSameNameButDifferentLength(
      imageName: imageName,
      tempFile: tempFile,
      newImagePath: newImagePath,
      memeDirectoryPath: memeDirectoryPath,
    );
  }

  Future<void> _createFileForSameNameButDifferentLength({
    required final String imageName,
    required final File tempFile,
    required final String newImagePath,
    required final String memeDirectoryPath,
  }) async {
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      await tempFile.copy(newImagePath);
      return;
    }

    final extension = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");
    // if not underscore
    if (indexOfLastUnderscore == -1) {
      final correctedNewImagePath =
          "$memeDirectoryPath${Platform.pathSeparator}${imageNameWithoutExtension}_1$extension";
      await tempFile.copy(correctedNewImagePath);
      return;
    } else {
      // get suffixNumber
      final suffixNumberString = imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);
      final suffixNumber = int.tryParse(suffixNumberString);
      // if not suffixNumber
      if (suffixNumber == null) {
        final correctedNewImagePath =
            "$memeDirectoryPath${Platform.pathSeparator}${imageNameWithoutExtension}_1$extension";
        await tempFile.copy(correctedNewImagePath);
      } else {
        // increment suffixNumber
        final imageNameWithoutSuffix =
            imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
        final correctedNewImagePath =
            "$memeDirectoryPath${Platform.pathSeparator}${imageNameWithoutSuffix}_${suffixNumber + 1}$extension";
        await tempFile.copy(correctedNewImagePath);
      }
    }
  }

  String _getFileNameByPath(String imagePath) => imagePath.split(Platform.pathSeparator).last;
}
