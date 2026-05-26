import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/api_service.dart';
import '../providers/listing_provider.dart';
import '../../../features/tenant/providers/property_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  final String? propertyId;
  const AddPropertyScreen({super.key, this.propertyId});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  PropertyType _propertyType = PropertyType.apartment;
  int _bedrooms = 1;
  int _bathrooms = 1;
  int? _floor;
  bool _isNegotiable = false;
  bool _isLoading = false;
  AreaModel? _selectedArea;
  final List<String> _selectedAmenities = [];

  static const _allAmenities = [
    'AC', 'Gas', 'Lift', 'Parking', 'CCTV', 'Generator', 'Security Guard',
    'Wifi', 'Balcony', 'Rooftop', 'Water 24/7', 'Servant Quarter',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _rentCtrl.dispose();
    _rulesCtrl.dispose();
    _sizeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an area'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'areaId': _selectedArea!.id,
        'fullAddress': _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
        'rentAmount': double.parse(_rentCtrl.text),
        'negotiable': _isNegotiable,
        'propertyType': _propertyType.name.toUpperCase(),
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'floorNumber': _floor,
        'sizeSqft': _sizeCtrl.text.isNotEmpty ? double.tryParse(_sizeCtrl.text) : null,
        'amenities': _selectedAmenities,
        'houseRules': _rulesCtrl.text.trim().isNotEmpty ? _rulesCtrl.text.trim() : null,
      };

      if (widget.propertyId != null) {
        await ref.read(ownerListingProvider.notifier).updateListing(widget.propertyId!, data);
      } else {
        await ref.read(ownerListingProvider.notifier).createListing(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.propertyId != null ? 'Listing updated!' : 'Listing submitted for approval!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } on DioException catch (e) {
      if (mounted) {
        final err = ApiException.fromDioError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString()), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAreaPicker(List<AreaModel> areas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AreaPickerSheet(
        areas: areas,
        selected: _selectedArea,
        onSelected: (a) {
          setState(() => _selectedArea = a);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(areasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propertyId != null ? 'Edit Listing' : 'Add Listing'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Basic Information'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Property Title *', hintText: 'e.g. 3BHK Apartment in Dhanmondi'),
                validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe the property, neighborhood, transport links...'),
                validator: (v) => v?.trim().isEmpty == true ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Location *'),
              areasAsync.when(
                data: (areas) => GestureDetector(
                  onTap: () => _showAreaPicker(areas),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedArea == null ? AppColors.error.withOpacity(0.5) : AppColors.divider,
                        width: _selectedArea == null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: _selectedArea != null ? AppColors.primary : AppColors.textHint, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedArea != null
                                ? '${_selectedArea!.areaName}${_selectedArea!.subArea != null ? ", ${_selectedArea!.subArea}" : ""}${_selectedArea!.city.isNotEmpty ? " — ${_selectedArea!.city}" : ""}'
                                : 'Select area *',
                            style: TextStyle(
                              color: _selectedArea != null ? AppColors.textPrimary : AppColors.textHint,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load areas', style: TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Full Address (optional)', hintText: 'House no, Road, Block...'),
              ),
              const SizedBox(height: 20),

              _SectionLabel('Property Type'),
              DropdownButtonFormField<PropertyType>(
                value: _propertyType,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: PropertyType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                )).toList(),
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 20),

              _SectionLabel('Rooms'),
              Row(
                children: [
                  Expanded(child: _CounterField(label: 'Bedrooms', value: _bedrooms, onChanged: (v) => setState(() => _bedrooms = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _CounterField(label: 'Bathrooms', value: _bathrooms, onChanged: (v) => setState(() => _bathrooms = v))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Size (sqft)', hintText: 'Optional'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Floor No.', hintText: 'Optional'),
                      onChanged: (v) => _floor = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionLabel('Rent'),
              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent (৳) *', prefixText: '৳ '),
                validator: (v) {
                  if (v?.isEmpty == true) return 'Rent amount is required';
                  if (double.tryParse(v!) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isNegotiable,
                onChanged: (v) => setState(() => _isNegotiable = v),
                title: const Text('Rent is Negotiable', style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allAmenities.map((a) {
                  final selected = _selectedAmenities.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) _selectedAmenities.add(a);
                      else _selectedAmenities.remove(a);
                    }),
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _SectionLabel('House Rules (Optional)'),
              TextFormField(
                controller: _rulesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. No pets, No smoking, Family preferred...',
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: widget.propertyId != null ? 'Update Listing' : 'Submit for Approval',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your listing will be reviewed by our team before going live (usually within 24 hours).',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaPickerSheet extends StatefulWidget {
  final List<AreaModel> areas;
  final AreaModel? selected;
  final ValueChanged<AreaModel> onSelected;

  const _AreaPickerSheet({required this.areas, required this.selected, required this.onSelected});

  @override
  State<_AreaPickerSheet> createState() => _AreaPickerSheetState();
}

class _AreaPickerSheetState extends State<_AreaPickerSheet> {
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
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
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
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20) : null,
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                iconSize: 20,
              ),
              Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => onChanged(value + 1),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
