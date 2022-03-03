import 'package:memogenerator/data/repositories/templates_repository.dart';

class DeleteTemplateInteractor {
  static DeleteTemplateInteractor? _instance;

  factory DeleteTemplateInteractor.getInstance() =>
      _instance ?? DeleteTemplateInteractor._internal();

  DeleteTemplateInteractor._internal();

  Future<bool> deleteTemplate({
    required final String id,
  }) async {
    return TemplatesRepository.getInstance().removeFromTemplates(id);
  }
}
