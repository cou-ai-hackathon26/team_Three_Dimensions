import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/source_sheet.dart';
import '../../domain/models/source_record.dart';

class SourcesLibraryScreen extends ConsumerStatefulWidget {
  const SourcesLibraryScreen({super.key});

  @override
  ConsumerState<SourcesLibraryScreen> createState() =>
      _SourcesLibraryScreenState();
}

class _SourcesLibraryScreenState extends ConsumerState<SourcesLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  // Canonical statutory corpus entries
  static const List<SourceRecord> _corpusSources = [
    SourceRecord(
      id: 'labour-121',
      title: 'Time of payment of wages',
      provisionPath: 'The Bangladesh Labour Act, 2006, Section 121',
      originalText:
          'The wages of every worker shall be paid before the expiry of the seventh day after the last day of the wage period in respect of which the wages are payable.',
      plainExplanation:
          'প্রত্যেক শ্রমিকের মজুরি যে মজুরি মেয়াদের মজুরি প্রদেয় সেই মেয়াদ সমাপ্তির পরবর্তী সাত দিনের মধ্যে পরিশোধ করতে হবে।',
      officialUrl: 'http://bdlaws.minlaw.gov.bd/act-952/section-35677.html',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      categories: ['labour'],
    ),
    SourceRecord(
      id: 'labour-33',
      title: 'Grievance procedure',
      provisionPath: 'The Bangladesh Labour Act, 2006, Section 33',
      originalText:
          'Any worker who has a grievance in respect of any matter shall submit his grievance to his employer in writing by registered post or by hand within thirty days of the occurrence of the cause of such grievance.',
      plainExplanation:
          'কোনো শ্রমিকের কোনো অভিযোগ থাকিলে তিনি উক্ত অভিযোগের কারণ ঘটার ৩০ দিনের মধ্যে রেজিস্ট্রেশন ডাকযোগে বা স্বহস্তে লিখিতভাবে তাহার মালিকের নিকট পেশ করিবেন।',
      officialUrl: 'http://bdlaws.minlaw.gov.bd/act-952/section-35589.html',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      categories: ['labour'],
    ),
    SourceRecord(
      id: 'consumer-45',
      title: 'Punishment for selling adulterated goods or medicines',
      provisionPath: 'The Consumer Rights Protection Act, 2009, Section 45',
      originalText:
          'If any person sells or offers to sell any adulterated goods or medicines, he shall be punished with imprisonment for a term which may extend to one year, or with fine not exceeding taka fifty thousand, or with both.',
      plainExplanation:
          'যদি কোনো ব্যক্তি ভেজাল পণ্য বা ঔষধ বিক্রয় করেন বা করিবার প্রস্তাব করেন, তাহা হইলে তিনি অনধিক এক বৎসর কারাদণ্ড, বা অনধিক পঞ্চাশ হাজার টাকা অর্থদণ্ড, বা উভয় দণ্ডে দণ্ডিত হইবেন।',
      officialUrl: 'http://bdlaws.minlaw.gov.bd/act-1014/section-38012.html',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      categories: ['consumer'],
    ),
    SourceRecord(
      id: 'penal-379',
      title: 'Punishment for theft',
      provisionPath: 'The Penal Code, 1860, Section 379',
      originalText:
          'Whoever commits theft shall be punished with imprisonment of either description for a term which may extend to three years, or with fine, or with both.',
      plainExplanation:
          'যে ব্যক্তি চুরি করে, সে তিন বৎসর পর্যন্ত মেয়াদের সশ্রম বা বিনাশ্রম কারাদণ্ডে, অথবা অর্থদণ্ডে, অথবা উভয় দণ্ডেই দণ্ডিত হইবে।',
      officialUrl: 'http://bdlaws.minlaw.gov.bd/act-11/section-3079.html',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      categories: ['penal'],
    ),
    SourceRecord(
      id: 'cyber-24',
      title: 'Offence regarding identity fraud or deception',
      provisionPath: 'Cyber Security Act, 2023, Section 24',
      originalText:
          'If any person intentionally or knowingly, by using computer, computer system or digital device, cheats by personation or identity theft...',
      plainExplanation:
          'যদি কোনো ব্যক্তি ইচ্ছাকৃতভাবে বা জ্ঞাতসারে কম্পিউটার বা ডিজিটাল ডিভাইস ব্যবহার করিয়া পরিচয় প্রতারণা বা ছলনা করেন...',
      officialUrl: 'http://bdlaws.minlaw.gov.bd/act-1456/section-48901.html',
      recordVersion: '1.0',
      packVersion: 'bd-pilot-2026-10-27.1',
      categories: ['cyber'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';

    final categories = [
      {'key': 'all', 'label': isBn ? 'সকল আইন' : 'All Laws'},
      {'key': 'labour', 'label': isBn ? 'শ্রম আইন' : 'Labour'},
      {'key': 'consumer', 'label': isBn ? 'ভোক্তা অধিকার' : 'Consumer'},
      {'key': 'cyber', 'label': isBn ? 'সাইবার নিরাপত্তা' : 'Cyber Security'},
      {'key': 'penal', 'label': isBn ? 'দণ্ডবিধি' : 'Penal Code'},
    ];

    final filtered = _corpusSources.where((s) {
      if (_selectedCategory != 'all' &&
          !s.categories.contains(_selectedCategory)) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return s.provisionPath.toLowerCase().contains(q) ||
            s.title.toLowerCase().contains(q) ||
            (s.plainExplanation?.toLowerCase().contains(q) ?? false) ||
            s.originalText.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBarShell(
        title: isBn ? 'আইন ও ধারা সংগ্রহশালা' : 'Statutory Sources & Acts',
        showBack: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isBn
                      ? 'ধারা, আইনের নাম বা বিষয় খুঁজুন...'
                      : 'Search section, act or topic...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: ext.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ext.outlineVariant),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final isSelected = _selectedCategory == cat['key'];
                  return ChoiceChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat['key']!),
                    selectedColor: ext.primary.withOpacity(0.18),
                    labelStyle: TextStyle(
                      color: isSelected ? ext.primary : ext.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Provisions List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        isBn
                            ? 'কোনো আইন বা ধারা পাওয়া যায়নি'
                            : 'No sections found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ext.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final source = filtered[index];
                        return Card(
                          elevation: 0,
                          color: ext.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: ext.outlineVariant),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => SourceSheet.show(
                              context,
                              sourceRecord: source,
                              isBangla: isBn,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: ext.primary.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          source.id.toUpperCase(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: ext.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          source.provisionPath,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: ext.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 14, color: ext.outlineVariant),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    source.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: ext.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isBn && source.plainExplanation != null
                                        ? source.plainExplanation!
                                        : source.originalText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: ext.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
