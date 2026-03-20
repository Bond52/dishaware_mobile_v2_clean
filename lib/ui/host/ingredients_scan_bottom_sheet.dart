import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ingredient_service.dart';
import '../../theme/da_colors.dart';
import '../../utils/image_resize_util.dart';

const _purple = Color(0xFF6A5FD3);
const _purpleSoft = Color(0xFFF3F1FF);
const _mint = Color(0xFF26A69A);
const _tipBlue = Color(0xFFE3F2FD);
const _tipBlueText = Color(0xFF1565C0);

/// Bottom sheet « Mes ingrédients disponibles » (scan + saisie manuelle).
class IngredientsScanBottomSheet extends StatefulWidget {
  const IngredientsScanBottomSheet({
    super.key,
    required this.initialDetected,
    required this.initialManual,
  });

  final List<String> initialDetected;
  final List<String> initialManual;

  @override
  State<IngredientsScanBottomSheet> createState() =>
      _IngredientsScanBottomSheetState();
}

class _IngredientsScanBottomSheetState extends State<IngredientsScanBottomSheet> {
  late List<String> _detected;
  late List<String> _manual;
  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _analyzing = false;

  List<String> get _allIngredients => {
        ..._detected,
        ..._manual,
      }.toList();

  @override
  void initState() {
    super.initState();
    _detected = List<String>.from(widget.initialDetected);
    _manual = List<String>.from(widget.initialManual);
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_analyzing) return;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null || !mounted) return;

      setState(() {
        _analyzing = true;
      });

      final rawBytes = await image.readAsBytes();
      final jpegBytes = resizeImageBytesToJpeg(rawBytes, maxWidth: 800, quality: 85);
      final b64 = base64Encode(jpegBytes);

      final found = await IngredientService.ingredientsFromImageBase64(b64);
      if (!mounted) return;
      setState(() {
        for (final i in found) {
          final t = i.trim();
          if (t.isNotEmpty && !_detected.contains(t)) {
            _detected.add(t);
          }
        }
        _analyzing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’analyser l’image'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _addManual() {
    final raw = _manualController.text.trim();
    if (raw.isEmpty) return;
    final parts = raw.split(RegExp(r'[,;\n]'));
    setState(() {
      for (final p in parts) {
        final t = p.trim();
        if (t.isNotEmpty && !_manual.contains(t)) {
          _manual.add(t);
        }
      }
      _manualController.clear();
    });
  }

  void _removeDetected(String s) {
    setState(() => _detected.remove(s));
  }

  void _removeManual(String s) {
    setState(() => _manual.remove(s));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxH),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DAColors.mutedForeground.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: DAColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mes ingrédients disponibles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: DAColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scannez ou ajoutez vos ingrédients pour des suggestions adaptées',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: DAColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_analyzing) ...[
                          const LinearProgressIndicator(
                            minHeight: 3,
                            color: _purple,
                            backgroundColor: _purpleSoft,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Analyse en cours…',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _purple,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          'Scanner avec l’appareil photo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: DAColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _analyzing
                                    ? null
                                    : () => _pickAndAnalyze(ImageSource.camera),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.photo_camera_outlined, size: 20),
                                label: const Text('Prendre une photo'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _analyzing
                                    ? null
                                    : () => _pickAndAnalyze(ImageSource.gallery),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _purple,
                                  side: const BorderSide(color: _purple, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.photo_library_outlined, size: 20),
                                label: const Text('Importer'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_detected.isNotEmpty) ...[
                          Text(
                            'Détectés (${_detected.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DAColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _detected
                                .map(
                                  (ingredient) => Chip(
                                    label: Text(ingredient),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () => _removeDetected(ingredient),
                                    backgroundColor: _purpleSoft,
                                    side: const BorderSide(color: Color(0xFFE6E3FF)),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          'Ajouter manuellement',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: DAColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _manualController,
                                minLines: 1,
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: 'Ex: Carottes, Pommes de terre…',
                                  filled: true,
                                  fillColor: DAColors.muted.withValues(alpha: 0.35),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _addManual(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: _addManual,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Ajouter'),
                            ),
                          ],
                        ),
                        if (_manual.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _manual
                                .map(
                                  (ingredient) => Chip(
                                    label: Text(ingredient),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () => _removeManual(ingredient),
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    side: const BorderSide(color: Color(0xFFC8E6C9)),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _tipBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome, size: 20, color: _tipBlueText.withValues(alpha: 0.9)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Astuce IA : Photographiez votre frigo ou placards pour une détection automatique rapide',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: _tipBlueText.withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop<Map<String, List<String>>>(
                            context,
                            {
                              'detected': List<String>.from(_detected),
                              'manual': List<String>.from(_manual),
                            },
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _mint,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          'Valider mes ingrédients (${_allIngredients.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
      ),
    );
  }
}

/// Affiche la feuille ; retour `null` si fermée sans valider.
Future<Map<String, List<String>>?> showIngredientsScanSheet(
  BuildContext context, {
  required List<String> initialDetected,
  required List<String> initialManual,
}) {
  return showModalBottomSheet<Map<String, List<String>>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => IngredientsScanBottomSheet(
      initialDetected: initialDetected,
      initialManual: initialManual,
    ),
  );
}
