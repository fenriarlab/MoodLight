import 'package:flutter/material.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../widgets/diary_card.dart';

class AllDiariesScreen extends StatefulWidget {
  final List<MoodDiaryModel> diaries;
  final Function(MoodDiaryModel) onDeleteDiary;
  final VoidCallback onReload;

  const AllDiariesScreen({
    super.key,
    required this.diaries,
    required this.onDeleteDiary,
    required this.onReload,
  });

  @override
  State<AllDiariesScreen> createState() => _AllDiariesScreenState();
}

class _AllDiariesScreenState extends State<AllDiariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final filteredList = widget.diaries.where((d) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchContent = d.content.toLowerCase().contains(query);
      final matchTag = d.tags.any((t) => t.toLowerCase().contains(query));
      return matchContent || matchTag;
    }).toList();

    return Scaffold(
      backgroundColor: tc.isDark ? const Color(0xFF14121A) : const Color(0xFFF9F4FE),
      appBar: AppBar(
        title: Text(
          '全部心情记录 (${widget.diaries.length})',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        backgroundColor: tc.isDark ? const Color(0xFF14121A) : const Color(0xFFF9F4FE),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: TextStyle(color: tc.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索心情感悟或标签...',
                hintStyle: TextStyle(color: tc.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8C52EE), size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: tc.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
                  ),
                ),
              ),
            ),
          ),

          // List Body
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? '🌱 暂无心情记录' : '没有找到匹配的心情日记',
                      style: TextStyle(color: tc.textSecondary, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, idx) {
                      final item = filteredList[idx];
                      return DiaryCard(
                        item: item,
                        onDelete: () async {
                          await widget.onDeleteDiary(item);
                          setState(() {});
                          widget.onReload();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
