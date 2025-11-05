import '../model/signup_model.dart';

abstract class SignupEvent {}

class SubmitSignupForm extends SignupEvent {
  final MagentoSignupRequest request;

  SubmitSignupForm(this.request);
}
