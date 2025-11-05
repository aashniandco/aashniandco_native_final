// tab_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class TabState {
  final int index;
  const TabState(this.index);
}

class TabBloc extends Cubit<TabState> {
  TabBloc() : super(const TabState(0));

  void setTab(int newIndex) => emit(TabState(newIndex));
}
