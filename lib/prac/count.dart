import 'package:aashniandco/bloc/text_change/state/text_bloc.dart';
import 'package:aashniandco/bloc/text_change/state/text_event.dart';
import 'package:aashniandco/bloc/text_change/state/text_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<TextBloc, TextState>(
              builder: (context, state) {
                // Extract values from the state
                String name = "Hello";
                Color textColor = Colors.black;

                if (state is InitialTextState) {
                  name = state.name;
                  textColor = state.textColor;
                } else if (state is UpdatedTextState) {
                  name = state.name;
                  textColor = state.textColor;
                }

                print("Building Text with name: $name and color: $textColor"); // Debugging

                return Text(
                  name,
                  style: TextStyle(fontSize: 24, color: textColor),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                print("Button pressed, dispatching UpdateTextEvent"); // Debugging
                context.read<TextBloc>().add(UpdatedTextEvent());
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}