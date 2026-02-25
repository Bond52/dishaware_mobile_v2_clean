import 'package:flutter/material.dart';

import '../theme/da_colors.dart';
import '../services/api_service.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  List<dynamic> _results = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _cuisine;
  String? _diet;
  int? _maxCalories;
  int? _maxReadyTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.searchExplorer(
        query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        cuisine: _cuisine,
        diet: _diet,
        maxCalories: _maxCalories,
        maxReadyTime: _maxReadyTime,
      );
      if (mounted) {
        setState(() {
          _results = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openFilters() async {
    String? cuisine = _cuisine;
    String? diet = _diet;
    int? maxCalories = _maxCalories;
    int? maxReadyTime = _maxReadyTime;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DAColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: cuisine,
                    decoration: const InputDecoration(
                      labelText: 'Cuisine',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Toutes')),
                      DropdownMenuItem(value: 'African', child: Text('Africaine')),
                      DropdownMenuItem(value: 'American', child: Text('Américaine')),
                      DropdownMenuItem(value: 'Chinese', child: Text('Chinoise')),
                      DropdownMenuItem(value: 'French', child: Text('Française')),
                      DropdownMenuItem(value: 'Indian', child: Text('Indienne')),
                      DropdownMenuItem(value: 'Italian', child: Text('Italienne')),
                      DropdownMenuItem(value: 'Japanese', child: Text('Japonaise')),
                      DropdownMenuItem(value: 'Mediterranean', child: Text('Méditerranéenne')),
                      DropdownMenuItem(value: 'Mexican', child: Text('Mexicaine')),
                      DropdownMenuItem(value: 'Thai', child: Text('Thaïlandaise')),
                    ],
                    onChanged: (v) => setModalState(() => cuisine = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    value: diet,
                    decoration: const InputDecoration(
                      labelText: 'Régime',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Aucun')),
                      DropdownMenuItem(value: 'vegetarian', child: Text('Végétarien')),
                      DropdownMenuItem(value: 'vegan', child: Text('Végan')),
                      DropdownMenuItem(value: 'gluten free', child: Text('Sans gluten')),
                      DropdownMenuItem(value: 'dairy free', child: Text('Sans lactose')),
                      DropdownMenuItem(value: 'ketogenic', child: Text('Keto')),
                      DropdownMenuItem(value: 'paleo', child: Text('Paléo')),
                    ],
                    onChanged: (v) => setModalState(() => diet = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: maxCalories?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Calories max',
                      border: OutlineInputBorder(),
                      suffixText: 'kcal',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      maxCalories = int.tryParse(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: maxReadyTime?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Temps max (min)',
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      maxReadyTime = int.tryParse(v);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            cuisine = null;
                            diet = null;
                            maxCalories = null;
                            maxReadyTime = null;
                          });
                        },
                        child: const Text('Réinitialiser'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _cuisine = cuisine;
                            _diet = diet;
                            _maxCalories = maxCalories;
                            _maxReadyTime = maxReadyTime;
                          });
                          Navigator.pop(context);
                          _search();
                        },
                        child: const Text('Appliquer'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _isLoading ? null : _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: DAColors.mutedForeground,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun résultat.\nLancez une recherche ou modifiez les filtres.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: DAColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final dish = _results[index];
                        final imageUrl = dish['image']?.toString() ?? '';
                        final name = dish['name']?.toString() ?? 'Sans nom';
                        final calories = dish['calories'];
                        final calStr = calories != null
                            ? '${calories is num ? calories.round() : calories} kcal'
                            : '-- kcal';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            leading: imageUrl.isEmpty
                                ? Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: DAColors.muted,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.restaurant),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 56,
                                        height: 56,
                                        color: DAColors.muted,
                                        child: const Icon(Icons.restaurant),
                                      ),
                                    ),
                                  ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: DAColors.foreground,
                              ),
                            ),
                            subtitle: Text(
                              calStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: DAColors.mutedForeground,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
