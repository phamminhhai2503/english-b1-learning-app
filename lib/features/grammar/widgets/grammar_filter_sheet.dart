import 'package:flutter/material.dart';

class GrammarFilterResult {
  final int? page;
  final String? section;

  const GrammarFilterResult({
    required this.page,
    required this.section,
  });
}

class GrammarFilterSheet extends StatefulWidget {
  final List<int> pages;
  final List<String> sections;
  final int? selectedPage;
  final String? selectedSection;

  const GrammarFilterSheet({
    super.key,
    required this.pages,
    required this.sections,
    required this.selectedPage,
    required this.selectedSection,
  });

  @override
  State<GrammarFilterSheet> createState() => _GrammarFilterSheetState();
}

class _GrammarFilterSheetState extends State<GrammarFilterSheet> {
  int? _page;
  String? _section;

  @override
  void initState() {
    super.initState();
    _page = widget.selectedPage;
    _section = widget.selectedSection;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lọc Grammar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Theo page',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _page == null,
                    onSelected: (_) => setState(() => _page = null),
                  ),
                  ...widget.pages.map(
                    (page) => ChoiceChip(
                      label: Text('Page $page'),
                      selected: _page == page,
                      onSelected: (_) => setState(() => _page = page),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Theo section',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _section == null,
                    onSelected: (_) => setState(() => _section = null),
                  ),
                  ...widget.sections.map(
                    (section) => ChoiceChip(
                      label: Text(section),
                      selected: _section == section,
                      onSelected: (_) => setState(() => _section = section),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _page = null;
                          _section = null;
                        });
                      },
                      child: const Text('Xóa lọc'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          GrammarFilterResult(page: _page, section: _section),
                        );
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}