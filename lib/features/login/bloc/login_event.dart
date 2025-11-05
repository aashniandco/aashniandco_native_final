import '../model/login_model.dart';

abstract class LoginEvent {}

class SubmitLoginForm extends LoginEvent {
  final MagentoLoginRequest request;

  SubmitLoginForm(this.request);
}
