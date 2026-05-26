import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/property_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/empty_state.dart';

class TenantHomeScreen extends ConsumerStatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  ConsumerState<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends ConsumerState<TenantHomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  PropertyType? _selectedType;

  static const _propertyTypes = [
    (type: null, label: 'All', icon: Icons.apps_rounded),
    (type: PropertyType.apartment, label: 'Apartment', icon: Icons.apartment_rounded),
    (type: PropertyType.sublet, label: 'Sublet', icon: Icons.house_outlined),
    (type: PropertyType.mess, label: 'Mess', icon: Icons.people_rounded),
    (type: PropertyType.bachelor, label: 'Bachelor', icon: Icons.person_rounded),
    (type: PropertyType.family, label: 'Family', icon: Icons.family_restroom_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertySearchProvider.notifier).search();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(propertySearchProvider.notifier).search(reset: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    ref.read(propertySearchProvider.notifier).search(
          filter: PropertyFilter(
            propertyType: _selectedType,
            keyword: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
          ),
          reset: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final searchState = ref.watch(propertySearchProvider);
    final firstName = authState.user?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            snap: false,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $firstName 👋',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Find your perfect home',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _NotificationButton(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stat chips
                        Row(
                          children: [
                            _HeroStat(label: '${searchState.properties.length}+ Listings', icon: Icons.home_rounded),
                            const SizedBox(width: 12),
                            _HeroStat(label: 'Dhaka & more', icon: Icons.location_city_rounded),
                            const SizedBox(width: 12),
                            _HeroStat(label: 'Verified Owners', icon: Icons.verified_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _SearchBar(
                  controller: _searchController,
                  onSubmit: _applyFilter,
                  onFilter: _showFilterSheet,
                ),
              ),
            ),
          ),

          // ── Type Filter Chips ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _propertyTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tab = _propertyTypes[i];
                  final isSelected = _selectedType == tab.type;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = tab.type);
                      _applyFilter();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab.icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Results Header ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    '${searchState.properties.length} properties found',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showSortSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text('Sort', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Properties List ───────────────────────────────────────────
          if (searchState.isLoading && searchState.properties.isEmpty)
            const SliverToBoxAdapter(child: ListShimmer(count: 4))
          else if (searchState.error != null && searchState.properties.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Failed to load',
                subtitle: searchState.error,
                actionLabel: 'Retry',
                onAction: () => ref.read(propertySearchProvider.notifier).search(),
              ),
            )
          else if (searchState.properties.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.home_outlined,
                title: 'No properties found',
                subtitle: 'Try adjusting your search or filters',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= searchState.properties.length) {
                    return searchState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                  final property = searchState.properties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () => context.push('/tenant/property/${property.id}'),
                  );
                },
                childCount: searchState.properties.length + (searchState.hasMore ? 1 : 0),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FilterSheet(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Sort Properties', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            ...['Newest First', 'Rent: Low to High', 'Rent: High to Low', 'Most Popular'].map(
              (s) => ListTile(
                leading: Icon(
                  s == 'Newest First' ? Icons.schedule_rounded :
                  s == 'Rent: Low to High' ? Icons.trending_up_rounded :
                  s == 'Rent: High to Low' ? Icons.trending_down_rounded : Icons.star_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                title: Text(s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/tenant/notifications'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final IconData icon;
  const _HeroStat({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white60),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onFilter;

  const _SearchBar({required this.controller, required this.onSubmit, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          hintText: 'Search area, type, or keyword...',
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          suffixIcon: GestureDetector(
            onTap: onFilter,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  RangeValues _rentRange = const RangeValues(0, 50000);
  int? _bedrooms;
  AreaModel? _selectedArea;

  void _showAreaPicker(List<AreaModel> areas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AreaSearchSheet(
        areas: areas,
        selected: _selectedArea,
        onSelected: (area) {
          setState(() => _selectedArea = area);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(areasProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _rentRange = const RangeValues(0, 50000);
                    _bedrooms = null;
                    _selectedArea = null;
                  }),
                  child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Area filter
            const Text('Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            areasAsync.when(
              data: (areas) => GestureDetector(
                onTap: () => _showAreaPicker(areas),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: _selectedArea != null ? AppColors.primary.withOpacity(0.07) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedArea != null ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: _selectedArea != null ? AppColors.primary : AppColors.textHint,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedArea != null ? _selectedArea!.fullName : 'Any location',
                          style: TextStyle(
                            color: _selectedArea != null ? AppColors.textPrimary : AppColors.textHint,
                            fontSize: 14,
                            fontWeight: _selectedArea != null ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (_selectedArea != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedArea = null),
                          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            // Rent range
            Row(
              children: [
                const Text('Rent Range', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const Spacer(),
                Text(
                  '৳${_rentRange.start.round()} — ৳${_rentRange.end.round()}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
            RangeSlider(
              values: _rentRange,
              min: 0,
              max: 100000,
              divisions: 100,
              activeColor: AppColors.primary,
              labels: RangeLabels('৳${_rentRange.start.round()}', '৳${_rentRange.end.round()}'),
              onChanged: (v) => setState(() => _rentRange = v),
            ),
            const SizedBox(height: 16),
            const Text('Bedrooms', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [1, 2, 3, 4, 5].map((n) {
                final isSelected = _bedrooms == n;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _bedrooms = isSelected ? null : n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                      ),
                      child: Text(
                        '${n}+',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                ref.read(propertySearchProvider.notifier).search(
                      filter: PropertyFilter(
                        areaId: _selectedArea?.id,
                        minRent: _rentRange.start,
                        maxRent: _rentRange.end,
                        bedrooms: _bedrooms,
                      ),
                      reset: true,
                    );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaSearchSheet extends StatefulWidget {
  final List<AreaModel> areas;
  final AreaModel? selected;
  final ValueChanged<AreaModel> onSelected;

  const _AreaSearchSheet({required this.areas, required this.selected, required this.onSelected});

  @override
  State<_AreaSearchSheet> createState() => _AreaSearchSheetState();
}

class _AreaSearchSheetState extends State<_AreaSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.areas.where((a) {
      final q = _query.toLowerCase();
      return a.areaName.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          (a.subArea?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search area...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No areas found', style: TextStyle(color: AppColors.textHint)))
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final area = filtered[i];
                        final isSelected = widget.selected?.id == area.id;
                        return ListTile(
                          onTap: () => widget.onSelected(area),
                          leading: Icon(Icons.location_on_rounded,
                              color: isSelected ? AppColors.primary : AppColors.textHint, size: 20),
                          title: Text(
                            area.subArea != null ? '${area.areaName}, ${area.subArea}' : area.areaName,
                            style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                          ),
                          subtitle: Text('${area.city}, ${area.district}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                              : null,
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
