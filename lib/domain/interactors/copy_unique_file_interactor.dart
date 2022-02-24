import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class CopyUniqueFileInteractor {
  static CopyUniqueFileInteractor? _instance;

  factory CopyUniqueFileInteractor.getInstance() =>
      _instance ?? CopyUniqueFileInteractor._internal();

  CopyUniqueFileInteractor._internal();

  Future<String> copyUniqueFile({
    required final String directoryWithFiles,
    required final String filePath,
  }) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memeDirPath = "${docsPath.absolute.path}${Platform.pathSeparator}$directoryWithFiles";
    final memesDirectory = Directory(memeDirPath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    final tempFile = File(filePath);
    final imageName = _getFileNameByPath(filePath);
    final newImagePath = "$memeDirPath${Platform.pathSeparator}$imageName";

    // check for exists file
    final oldFileWithTheSameName = currentFiles.firstWhereOrNull(
      (element) {
        return _getFileNameByPath(element.path) == imageName && element is File;
      },
    );

    // if new file
    if (oldFileWithTheSameName == null) {
      await tempFile.copy(newImagePath);
      return imageName;
    }

    // check different length file
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return imageName;
    }

    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      await tempFile.copy(newImagePath);
      return imageName;
    }

    final ext = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");

    // if not underscore
    if (indexOfLastUnderscore == -1) {
      final newImageName = "${imageNameWithoutExtension}_1$ext";
      final correctedNewImagePath = "$memeDirPath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }

    // get suffixNumber
    final suffixNumberString = imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);
    final suffixNumber = int.tryParse(suffixNumberString);

    // if not suffixNumber
    if (suffixNumber == null) {
      final newImageName = "${imageNameWithoutExtension}_1$ext";
      final correctedNewImagePath = "$memeDirPath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }

    // increment suffixNumber
    final imageNameWithoutSuffix = imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
    final newImageName = "${imageNameWithoutSuffix}_${suffixNumber + 1}$ext";
    final correctedNewImagePath = "$memeDirPath${Platform.pathSeparator}$newImageName";
    await tempFile.copy(correctedNewImagePath);
    return newImageName;
  }

  String _getFileNameByPath(String imagePath) => imagePath.split(Platform.pathSeparator).last;
}
