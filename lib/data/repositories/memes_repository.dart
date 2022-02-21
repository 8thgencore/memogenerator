import 'dart:convert';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class MemesRepository {
  final updater = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() =>
      _instance ??= MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  // from Shared Preference to jsonString. Add new element to jsonString
  Future<bool> addToMemes(final Meme newMeme) async {
    final memes = await getMemes();
    final memeIndex = memes.indexWhere((meme) => meme.id == newMeme.id);
    if (memeIndex == -1) {
      memes.add(newMeme);
    } else {
      memes[memeIndex] = newMeme;
    }
    return _setMemes(memes);
  }

  // delete from list
  Future<bool> removeFromMemes(final String id) async {
    final memes = await getMemes();
    memes.removeWhere((meme) => meme.id == id);
    return _setMemes(memes);
  }

  // get object by id
  Future<Meme?> getMeme(final String id) async {
    final memes = await getMemes();
    return memes.firstWhereOrNull((meme) => meme.id == id);
  }

  // dynamic get List
  Stream<List<Meme>> observeMemes() async* {
    yield await getMemes();
    await for (final _ in updater) {
      yield await getMemes();
    }
  }

  // from Shared Preference to List
  Future<List<Meme>> getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes.map((rawMeme) => Meme.fromJson(json.decode(rawMeme))).toList();
  }

  // List to jsonString
  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes.map((meme) => json.encode(meme.toJson())).toList();
    return _setRawMemes(rawMemes);
  }

  // jsonString to Shared Preference
  Future<bool> _setRawMemes(final List<String> rawMemes) {
    updater.add(null);
    return spData.setMemes(rawMemes);
  }
}
