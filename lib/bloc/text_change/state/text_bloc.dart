import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:aashniandco/bloc/text_change/state/text_event.dart';
import 'package:aashniandco/bloc/text_change/state/text_state.dart';



class TextBloc extends Bloc<TextEvent, TextState> {
  TextBloc()
      : super(InitialTextState(name: "Hello", textColor: Colors.black)) {
    on<UpdatedTextEvent>((event, emit) {
      print("Event received: UpdateTextEvent"); // Debugging log
      emit(UpdatedTextState(name: "World", textColor: Colors.red)); // Correct state update
    });
  }
}
