import 'package:bloc/bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetCubit extends Cubit<bool> {
  final InternetConnection _checker = InternetConnection();

  InternetCubit() : super(true) {
    _checker.onStatusChange.listen((status) {
      emit(status == InternetStatus.connected);
    });
  }
}
