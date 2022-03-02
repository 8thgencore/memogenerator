import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/domain/interactors/copy_unique_file_interactor.dart';
import 'package:memogenerator/domain/interactors/screenshot_interactor.dart';
import 'package:screenshot/screenshot.dart';

class DeleteMemeInteractor {
  static const memesPathName = "memes";

  static DeleteMemeInteractor? _instance;

  factory DeleteMemeInteractor.getInstance() => _instance ?? DeleteMemeInteractor._internal();

  DeleteMemeInteractor._internal();

  Future<bool> deleteMeme({
    required final String id,
  }) async {
    return MemesRepository.getInstance().removeFromMemes(id);
  }
}
