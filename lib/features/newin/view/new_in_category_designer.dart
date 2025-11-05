import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../designer/bloc/designers_bloc.dart';
import '../../designer_details.dart';

class DesignerListScreen extends StatefulWidget {
  const DesignerListScreen({super.key});

  @override
  State<DesignerListScreen> createState() => _DesignerListScreenState();
}

class _DesignerListScreenState extends State<DesignerListScreen> {
  final Map<String, bool> selectedDesigners = {};

  @override
  void initState() {
    super.initState();
    context.read<DesignersBloc>().add(FetchDesigners());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Select Designers"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocBuilder<DesignersBloc, DesignersState>(
        builder: (context, state) {
          if (state is DesignersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DesignersLoaded) {
            final designers = state.designers;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: designers.length,
                    itemBuilder: (context, index) {
                      final designer = designers[index].name;
                      final isSelected = selectedDesigners[designer] ?? false;

                      return CheckboxListTile(
                        title: Text(designer),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedDesigners[designer] = value!;
                          });
                        },
                      );
                    },
                  ),
                ),

                // ✅ Apply Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
          onPressed: () {
          final selected = selectedDesigners.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

          if (selected.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one designer")),
          );
          return;
          }

          // Navigate to detail screen with the first selected designer
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => DesignerDetailScreen(designerName: selected.first),
          ),
          );
          },

                      child: const Text(
                        "Apply",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is DesignersError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("Something went wrong."));
          }
        },
      ),
    );
  }
}
