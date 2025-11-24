import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      "q": "What is Lorem Ipsum?",
      "a":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
    },
    {
      "q": "Why do we use it?",
      "a":
          "It is a long established fact that a reader will be distracted by the readable content."
    },
    {
      "q": "Where does it come from?",
      "a":
          "Contrary to popular belief, Lorem Ipsum is not simply random text."
    },
    {
      "q": "Where can I get some?",
      "a":
          "There are many variations of passages of Lorem Ipsum available."
    },
    {
      "q": "Is Lorem Ipsum safe to use?",
      "a": "Yes, it has been the industry's standard dummy text for centuries."
    },
  ];

  void _onExpand(int index) async {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // Auto scroll ke item yang dibuka
    _scrollController.animateTo(
      index * 140,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ==== BACK BUTTON ====
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A6CF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==== TITLE ====
              const Text(
                "Frequently Asked\nQuestions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A6CF7),
                ),
              ),

              const SizedBox(height: 26),

              // ==== FAQ LIST ====
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  bool isOpen = _expandedIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ==== HEADER ROW ====
                        GestureDetector(
                          onTap: () => _onExpand(index),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                faqs[index]["q"]!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AnimatedRotation(
                                turns: isOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 26,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        ),

                        // ==== EXPANDED CONTENT ====
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              faqs[index]["a"]!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                          crossFadeState: isOpen
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
