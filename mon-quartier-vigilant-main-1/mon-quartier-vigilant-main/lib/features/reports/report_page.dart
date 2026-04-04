import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/models/quartier_model.dart';
import '../../core/provider/report_provider.dart';
import '../../core/store/app_store.dart';
import '../../core/widgets/app_shell.dart';

class ReportPage extends StatefulWidget {
  final bool quickMode;

  const ReportPage({super.key, this.quickMode = false});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategory = categories.keys.first;
  Quartier? _selectedQuartier;
  String _initialQuartierName = '';
  String _quartierText = '';

  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  String? _locationError;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoFilename;
  bool _isPickingPhoto = false;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    final profileQuartier = store.citizenProfile['quartier'];
    if (profileQuartier != null && profileQuartier.trim().isNotEmpty) {
      _initialQuartierName = profileQuartier.trim();
      _quartierText = _initialQuartierName;
      _selectedQuartier = _resolveQuartier(
        _initialQuartierName,
        _quartiersForStore(store),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final reportProvider = context.watch<ReportProvider>();
    final canQuickReport = widget.quickMode ? store.canCreateQuickReport() : true;

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.quickMode ? 'Signalement rapide' : 'Nouveau signalement',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Decrivez le probleme observe pour permettre un traitement rapide.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _requiredField(
            controller: _titleController,
            label: 'Titre',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: categories.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Categorie',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            onChanged: (value) => setState(() => _selectedCategory = value ?? _selectedCategory),
          ),
          const SizedBox(height: 12),
          _requiredField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.subject_rounded,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          _QuartierAutocompleteField(
            initialValue: _initialQuartierName,
            quartierOptions: _quartiersForStore(store),
            onSelected: (quartier) => setState(() => _selectedQuartier = quartier),
            onChanged: (value) {
              _quartierText = value;
              if (_selectedQuartier != null &&
                  _normalizeSearch(_selectedQuartier!.name) != _normalizeSearch(value)) {
                _selectedQuartier = null;
              }
            },
          ),
          const SizedBox(height: 12),
          _requiredField(
            controller: _addressController,
            label: 'Adresse',
            icon: Icons.place_outlined,
            hintText: 'Ex: Rue principale, a cote du marche',
          ),
          const SizedBox(height: 12),
          _locationCard(),
          const SizedBox(height: 12),
          _photoCard(),
          const SizedBox(height: 18),
          if (reportProvider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                reportProvider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ElevatedButton.icon(
            onPressed: reportProvider.isSubmitting || !canQuickReport ? null : _submit,
            icon: reportProvider.isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(reportProvider.isSubmitting ? 'Envoi en cours' : 'Envoyer le signalement'),
          ),
        ],
      ),
    );

    final body = SafeArea(
      child: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.quickMode) _QuickModeCard(store: store),
                if (widget.quickMode) const SizedBox(height: 16),
                form,
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.quickMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Signalement rapide')),
        body: body,
      );
    }

    return AppShell(
      store: store,
      title: 'Signaler',
      currentIndex: 2,
      body: body,
    );
  }

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hintText,
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? '$label requis' : null,
    );
  }

  Widget _locationCard() {
    final hasLocation = _latitude != null && _longitude != null;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Géolocalisation (optionnel)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLocating ? null : _captureLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.gps_fixed_rounded),
                  label: Text(_isLocating ? 'Localisation…' : 'Ma position'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasLocation
                  ? 'Latitude: ${_latitude!.toStringAsFixed(6)} • Longitude: ${_longitude!.toStringAsFixed(6)}'
                  : 'Aucune position attachée au signalement.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_locationError != null) ...[
              const SizedBox(height: 6),
              Text(
                _locationError!,
                style: TextStyle(color: scheme.error),
              ),
            ],
            if (hasLocation) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() {
                  _latitude = null;
                  _longitude = null;
                  _locationError = null;
                }),
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Retirer la position'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photoCard() {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = _photoBytes != null && _photoBytes!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Photo (optionnel)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isPickingPhoto ? null : _pickPhoto,
                  icon: _isPickingPhoto
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(_isPickingPhoto ? 'Chargement…' : 'Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasPhoto)
              Text(
                "Optionnel: ajoute une photo du lieu (l'upload nécessite d'être connecté).",
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              if (_photoFilename != null && _photoFilename!.trim().isNotEmpty)
                Text(
                  _photoFilename!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.memory(
                    _photoBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() {
                  _photoBytes = null;
                  _photoFilename = null;
                  _photoError = null;
                }),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Retirer la photo'),
              ),
            ],
            if (_photoError != null) ...[
              const SizedBox(height: 6),
              Text(
                _photoError!,
                style: TextStyle(color: scheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    setState(() {
      _isPickingPhoto = true;
      _photoError = null;
    });
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (!mounted) return;
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoFilename = file.name;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _photoError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      } else {
        _isPickingPhoto = false;
      }
    }
  }

  Future<void> _captureLocation() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw StateError('Service de localisation désactivé.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw StateError('Permission de localisation refusée.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw StateError('Permission de localisation refusée définitivement. Activez-la dans les réglages.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _locationError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      } else {
        _isLocating = false;
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final store = context.read<AppStore>();
    final reportProvider = context.read<ReportProvider>();
    if (reportProvider.isSubmitting) return;

    final quartiers = _quartiersForStore(store);
    final quartier = _selectedQuartier ?? _resolveQuartier(_quartierText, quartiers);
    if (quartier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un quartier valide.')),
      );
      return;
    }

    try {
      await reportProvider.submitReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        quartier: quartier.name,
        quartierId: quartier.id,
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        photoBytes: _photoBytes,
        photoFilename: _photoFilename,
        isQuickReport: widget.quickMode,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement envoye avec succes.')),
      );

      if (widget.quickMode) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/signalements', (route) => false);
      }
    } catch (error) {
      if (!mounted) return;
      final message = reportProvider.error ?? error.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  static List<Quartier> _quartiersForStore(AppStore store) {
    if (store.quartiers.isNotEmpty) return store.quartiers;
    return List<Quartier>.generate(
      quartierNames.length,
      (i) => Quartier(id: i + 1, name: quartierNames[i], communeId: 1),
      growable: false,
    );
  }

  static Quartier? _resolveQuartier(String value, List<Quartier> quartiers) {
    final normalized = _normalizeSearch(value);
    if (normalized.isEmpty) return null;
    for (final quartier in quartiers) {
      if (_normalizeSearch(quartier.name) == normalized) {
        return quartier;
      }
    }
    return null;
  }

  static String _normalizeSearch(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ì': 'i',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ÿ': 'y',
      'œ': 'oe',
    };
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    normalized = normalized.replaceAll(RegExp(r"['’]"), ' ');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }
}

class _QuartierAutocompleteField extends StatefulWidget {
  const _QuartierAutocompleteField({
    required this.initialValue,
    required this.quartierOptions,
    required this.onSelected,
    required this.onChanged,
  });

  final String initialValue;
  final List<Quartier> quartierOptions;
  final ValueChanged<Quartier> onSelected;
  final ValueChanged<String> onChanged;

  @override
  State<_QuartierAutocompleteField> createState() => _QuartierAutocompleteFieldState();
}

class _QuartierAutocompleteFieldState extends State<_QuartierAutocompleteField> {
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Quartier>(
      displayStringForOption: (q) => q.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = _ReportPageState._normalizeSearch(textEditingValue.text);
        if (query.isEmpty) {
          return const Iterable<Quartier>.empty();
        }
        return widget.quartierOptions.where((quartier) {
          final name = _ReportPageState._normalizeSearch(quartier.name);
          return name.contains(query);
        });
      },
      onSelected: (quartier) {
        widget.onSelected(quartier);
        widget.onChanged(quartier.name);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 520),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final quartier = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(quartier.name),
                    onTap: () => onSelected(quartier),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (!_seeded && widget.initialValue.isNotEmpty) {
          controller.text = widget.initialValue;
          widget.onChanged(widget.initialValue);
          _seeded = true;
        }

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Quartier',
            prefixIcon: Icon(Icons.location_city_outlined),
            hintText: 'Tapez pour voir les suggestions',
          ),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'Quartier requis';
            final match = _ReportPageState._resolveQuartier(v, widget.quartierOptions);
            if (match == null) return 'Quartier non reconnu';
            return null;
          },
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

class _QuickModeCard extends StatelessWidget {
  final AppStore store;

  const _QuickModeCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final remaining = store.quickReportsRemaining;
    final banned = store.isGuestReporterBanned;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signalement rapide',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Identifiant: ${store.maskedGuestReporterId}'),
            const SizedBox(height: 6),
            Text('Signalements restants: $remaining/${AppStore.quickReportLimit}'),
            if (banned) ...[
              const SizedBox(height: 8),
              Text(
                'Votre identifiant est suspendu. Contactez un administrateur.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
