import 'package:flutter/material.dart';

class OfferPopup extends StatefulWidget {
  final VoidCallback onClose;

  const OfferPopup({required this.onClose});

  @override
  State<OfferPopup> createState() => _OfferPopupState();
}

class _OfferPopupState extends State<OfferPopup> {
  final TextEditingController _emailController = TextEditingController();
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Pop-Up_B.jpg'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                height: 400, // Adjust this to match image height
              ),

              // Email, button, and checkbox on top of image
              Positioned(
                left: 220,
                right: 10,
                top: 180, // Adjust this to place below “Get 10% Off”
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 280,
                      height: 32, // slightly increased to give room for vertical centering
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          height: 1.0, // controls line height
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 10, height: 1.0),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // smaller vertical padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true, // makes the TextField more compact
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 100, // adjust width as needed
                        height: 32,  // reduce height
                        child: ElevatedButton(
                          onPressed: () {
                            if (_dontShowAgain) {
                              // Save preference
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8), // reduced vertical padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "Subscribe",
                            style: TextStyle(color: Colors.white, fontSize: 12), // smaller font size if needed
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.7, // reduces checkbox size
                          child: Checkbox(
                            value: _dontShowAgain,
                            onChanged: (val) {
                              setState(() {
                                _dontShowAgain = val!;
                              });
                            },
                            activeColor: Colors.black,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduce touch area
                            visualDensity: VisualDensity.compact, // make it more compact
                          ),
                        ),
                        const SizedBox(width: 0),
                        const Expanded(
                          child: Text(
                            "Don't show this popup again",
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close button positioned on the right side of the image
              Positioned(
                top: 50,
                right: 0, // Adjusted to be slightly inside the image boundary
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
