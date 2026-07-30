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
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = widget.initialDate;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    // Filter by date first if selected
    final dateFilteredDiaries = widget.diaries.where((d) {
      if (_selectedDateFilter == null) return true;
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

    final titleText = _selectedDateFilter != null
        ? '${_selectedDateFilter!.month}月${_selectedDateFilter!.day}日的心情记录 (${dateFilteredDiaries.length}条)'
        : '全部心情记录 (${widget.diaries.length}条)';

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
          // Date Filter Chip Bar (If date filter active)
          if (_selectedDateFilter != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8C52EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8C52EE).withOpacity(0.24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF8C52EE)),
                      const SizedBox(width: 6),
                      Text(
                        '正在查看 ${_selectedDateFilter!.month}月${_selectedDateFilter!.day}日 (${dateFilteredDiaries.length}条记录)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8C52EE),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => setState(() => _selectedDateFilter = null),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: const [
                          Text(
                            '查看全量历史',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8C52EE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.clear, size: 13, color: Color(0xFF8C52EE)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      _searchQuery.isEmpty
                          ? (_selectedDateFilter != null ? '🌱 当天没有记录心情' : '🌱 暂无心情记录')
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
