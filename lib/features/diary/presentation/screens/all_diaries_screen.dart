import 'package:flutter/material.dart';
import '../../../../core/constants/theme_colors.dart';
import '../../data/models/mood_diary_model.dart';
import '../widgets/diary_card.dart';

class AllDiariesScreen extends StatefulWidget {
  final List<MoodDiaryModel> diaries;
  final DateTime? initialDate;
  final Function(MoodDiaryModel) onDeleteDiary;
  final Function(MoodDiaryModel)? onEditDiary;
  final VoidCallback onReload;

  const AllDiariesScreen({
    super.key,
    required this.diaries,
    this.initialDate,
    required this.onDeleteDiary,
    this.onEditDiary,
    required this.onReload,
  });

  @override
  State<AllDiariesScreen> createState() => _AllDiariesScreenState();
}

class _AllDiariesScreenState extends State<AllDiariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late DateTime? _selectedDateFilter;
  bool _showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = widget.initialDate ?? DateTime.now();
    _showAllHistory = widget.initialDate == null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    // Filter by date first if not viewing all history
    final dateFilteredDiaries = widget.diaries.where((d) {
      if (_showAllHistory || _selectedDateFilter == null) return true;
      return _isSameDay(d.createdAt, _selectedDateFilter!);
    }).toList();

    // Filter by search query second
    final filteredList = dateFilteredDiaries.where((d) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchContent = d.content.toLowerCase().contains(query);
      final matchTag = d.tags.any((t) => t.toLowerCase().contains(query));
      return matchContent || matchTag;
    }).toList();

    final dateStr = _selectedDateFilter != null
        ? '${_selectedDateFilter!.month}月${_selectedDateFilter!.day}日'
        : '当日';

    final titleText = _showAllHistory
        ? '全部历史记录 (${widget.diaries.length}条)'
        : '$dateStr的心情记录 (${dateFilteredDiaries.length}条)';

    return Scaffold(
      backgroundColor: tc.isDark ? const Color(0xFF14121A) : const Color(0xFFF9F4FE),
      appBar: AppBar(
        title: Text(
          titleText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        backgroundColor: tc.isDark ? const Color(0xFF14121A) : const Color(0xFFF9F4FE),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Mode Toggle Pill Bar ( [ 📅 当日记录 ] | [ 📜 全部历史 ] )
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: tc.isDark ? const Color(0xFF39334D) : const Color(0xFFEFE8FB),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showAllHistory = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_showAllHistory
                              ? const Color(0xFF8C52EE)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '📅 $dateStr记录 (${dateFilteredDiaries.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_showAllHistory ? Colors.white : tc.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showAllHistory = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _showAllHistory
                              ? const Color(0xFF8C52EE)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '📜 全部历史 (${widget.diaries.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _showAllHistory ? Colors.white : tc.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      _searchQuery.isEmpty
                          ? (!_showAllHistory ? '🌱 $dateStr没有记录心情' : '🌱 暂无心情记录')
                          : '没有找到匹配的心情日记',
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
                        onEdit: widget.onEditDiary != null ? () => widget.onEditDiary!(item) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
