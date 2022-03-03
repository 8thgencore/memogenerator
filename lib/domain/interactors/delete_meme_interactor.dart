import 'package:memogenerator/data/repositories/memes_repository.dart';

class DeleteMemeInteractor {
  static DeleteMemeInteractor? _instance;

  factory DeleteMemeInteractor.getInstance() => _instance ?? DeleteMemeInteractor._internal();

  DeleteMemeInteractor._internal();

  Future<bool> deleteMeme({
    required final String id,
  }) async {
    return MemesRepository.getInstance().removeFromMemes(id);
  }
}
