import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/projet.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';
import '../../providers/projet_provider.dart';

class NewTronconFormPage extends ConsumerStatefulWidget {
  final int projetId;
  
  const NewTronconFormPage({
    super.key,
    required this.projetId,
  });

  @override
  ConsumerState<NewTronconFormPage> createState() => _NewTronconFormPageState();
}

class _NewTronconFormPageState extends ConsumerState<NewTronconFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Listes pour les champs multi-sélection
  final List<String> _selectedOccupationSol = [];
  final List<String> _selectedEquipementsSociaux = [];
  final List<String> _selectedInterventions = [];
  final Map<String, String> _observations = {};
  
  // Gestion des images avec coordonnées GPS
  final List<TronconImage> _images = [];
  final ImagePicker _picker = ImagePicker();
  
  // Variables pour la géolocalisation
  bool _isLoadingLocation = false;
  double? _currentLatitude;
  double? _currentLongitude;
  double? _currentAltitude; // Nouvelle variable pour l'altitude
  
  // Distance calculée automatiquement
  double? _calculatedDistance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
    
    // Récupérer automatiquement la position GPS au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Vérifier les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _currentAltitude = position.altitude; // Mettre à jour l'altitude
      });

      // Mettre à jour les champs du formulaire
      _formKey.currentState?.fields['latitude']?.didChange(position.latitude.toString());
      _formKey.currentState?.fields['longitude']?.didChange(position.longitude.toString());
      _formKey.currentState?.fields['altitude']?.didChange(position.altitude.toString()); // Mettre à jour l'altitude

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Position GPS récupérée avec succès !'),
              Text('Latitude: ${_currentLatitude!.toStringAsFixed(6)}°'),
              Text('Longitude: ${_currentLongitude!.toStringAsFixed(6)}°'),
              Text('Altitude: ${_currentAltitude!.toStringAsFixed(1)} m'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

    } catch (e) {
      _showLocationErrorDialog(e.toString());
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service de localisation désactivé'),
        content: const Text('Veuillez activer le service de localisation dans les paramètres de votre appareil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission de localisation refusée'),
        content: const Text('L\'accès à la localisation est nécessaire pour enregistrer les coordonnées GPS du tronçon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de localisation'),
        content: Text('Impossible d\'obtenir la position GPS: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Ajoute un watermark à l'image avec les informations du projet et les coordonnées GPS
  Future<File> _addWatermarkToImage(String imagePath, Projet? projet) async {
    try {
      // Lire l'image originale
      final originalImage = img.decodeImage(File(imagePath).readAsBytesSync());
      if (originalImage == null) return File(imagePath);

      // Créer une copie de l'image pour y ajoter le watermark
      final watermarkedImage = img.copyResize(originalImage, 
        width: originalImage.width, 
        height: originalImage.height
      );

      // Informations pour le watermark
      final projetName = projet?.nom ?? 'Projet Inconnu';
      const companyName = 'Horion Engineering';
      final latitude = _currentLatitude?.toStringAsFixed(6) ?? 'N/A';
      final longitude = _currentLongitude?.toStringAsFixed(6) ?? 'N/A';
      final altitude = _currentAltitude?.toStringAsFixed(1) ?? 'N/A';
      
      // Ajouter la date et l'heure au format jj/mm/aaaa hh:mm
      final now = DateTime.now();
      final dateTime = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Texte du watermark
      final watermarkText = '$projetName\n$companyName\nLat: $latitude°, Lng: $longitude°\nAlt: ${altitude}m - $dateTime';

      // Paramètres du watermark
      const fontSize = 24;
      const padding = 20;
      final textColor = img.ColorRgb8(255, 255, 255); // Blanc
      final backgroundColor = img.ColorRgb8(0, 0, 0); // Noir avec transparence

      // Calculer la position en bas à droite
      final lines = watermarkText.split('\n');
      final lineHeight = fontSize + 4;
      final textHeight = lines.length * lineHeight;
      final maxLineWidth = lines.map((line) => line.length * (fontSize ~/ 2)).reduce((a, b) => a > b ? a : b);
      
      final startX = watermarkedImage.width - maxLineWidth - padding;
      final startY = watermarkedImage.height - textHeight - padding;

      // Dessiner un rectangle de fond semi-transparent
      img.fillRect(
        watermarkedImage,
        x1: startX - 10,
        y1: startY - 10,
        x2: startX + maxLineWidth + 10,
        y2: startY + textHeight + 10,
        color: img.ColorRgba8(0, 0, 0, 180), // Noir semi-transparent
      );

      // Dessiner chaque ligne de texte
      for (int i = 0; i < lines.length; i++) {
        img.drawString(
          watermarkedImage,
          lines[i],
          font: img.arial24,
          x: startX,
          y: startY + (i * lineHeight),
          color: textColor,
        );
      }

      // Sauvegarder l'image avec watermark
      final watermarkedImagePath = imagePath.replaceAll('.jpg', '_watermarked.jpg');
      File(watermarkedImagePath).writeAsBytesSync(img.encodeJpg(watermarkedImage));
      
      return File(watermarkedImagePath);
    } catch (e) {
      print('Erreur lors de l\'ajout du watermark: $e');
      return File(imagePath); // Retourner l'image originale en cas d'erreur
    }
  }

  Future<void> _takePicture() async {
    await _requestPermissions();
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (image != null) {
      // Récupérer la position GPS actuelle pour cette photo
      double? photoLatitude;
      double? photoLongitude;
      double? photoAltitude;
      
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        photoLatitude = position.latitude;
        photoLongitude = position.longitude;
        photoAltitude = position.altitude;
      } catch (e) {
        // En cas d'erreur GPS, utiliser les coordonnées générales du tronçon
        photoLatitude = _currentLatitude;
        photoLongitude = _currentLongitude;
        photoAltitude = _currentAltitude;
      }
      
      // Récupérer les informations du projet
      final projetAsync = ref.read(projetByIdProvider(widget.projetId));
      final projet = projetAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (_, __) => null,
      );

      // Sauvegarder l'image dans le répertoire des documents
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'troncon_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${directory.path}/$fileName';
      
      await File(image.path).copy(filePath);
      
      // Ajouter le watermark à l'image
      final watermarkedImage = await _addWatermarkToImage(filePath, projet);
      
      // Créer l'objet TronconImage avec les coordonnées GPS
      final tronconImage = TronconImage(
        path: watermarkedImage.path,
        latitude: photoLatitude,
        longitude: photoLongitude,
        altitude: photoAltitude,
      );
      
      setState(() {
        _images.add(tronconImage);
      });
      
      // Supprimer l'image originale sans watermark
      if (watermarkedImage.path != filePath) {
        File(filePath).delete().catchError((_) => File(''));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    await _requestPermissions();
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (image != null) {
      // Pour les images de la galerie, utiliser les coordonnées générales du tronçon
      // car elles peuvent avoir été prises à un autre moment/lieu
      final photoLatitude = _currentLatitude;
      final photoLongitude = _currentLongitude;
      final photoAltitude = _currentAltitude;
      
      // Récupérer les informations du projet
      final projetAsync = ref.read(projetByIdProvider(widget.projetId));
      final projet = projetAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (_, __) => null,
      );

      // Sauvegarder l'image dans le répertoire des documents
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'troncon_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${directory.path}/$fileName';
      
      await File(image.path).copy(filePath);
      
      // Ajouter le watermark à l'image
      final watermarkedImage = await _addWatermarkToImage(filePath, projet);
      
      // Créer l'objet TronconImage avec les coordonnées GPS
      final tronconImage = TronconImage(
        path: watermarkedImage.path,
        latitude: photoLatitude,
        longitude: photoLongitude,
        altitude: photoAltitude,
      );
      
      setState(() {
        _images.add(tronconImage);
      });
      
      // Supprimer l'image originale sans watermark
      if (watermarkedImage.path != filePath) {
        File(filePath).delete().catchError((_) => File(''));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      final tronconImage = _images[index];
      _images.removeAt(index);
      // Optionnellement supprimer le fichier physique
      File(tronconImage.path).delete().catchError((_) => File(''));
    });
  }

  void _calculateDistance() {
    final pkDebutField = _formKey.currentState?.fields['pkDebut'];
    final pkFinField = _formKey.currentState?.fields['pkFin'];
    
    if (pkDebutField?.value != null && pkFinField?.value != null) {
      try {
        final pkDebut = double.parse(pkDebutField!.value.toString());
        final pkFin = double.parse(pkFinField!.value.toString());
        final distance = (pkFin - pkDebut).abs();
        
        setState(() {
          _calculatedDistance = distance;
        });
        
        // Mettre à jour le champ distance dans le formulaire
        _formKey.currentState?.fields['distance']?.didChange(distance.toString());
      } catch (e) {
        setState(() {
          _calculatedDistance = null;
        });
        _formKey.currentState?.fields['distance']?.didChange(null);
      }
    } else {
      setState(() {
        _calculatedDistance = null;
      });
      _formKey.currentState?.fields['distance']?.didChange(null);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() == true) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;
        
        // Calculer la distance si PK début et fin sont fournis
        double? distance;
        if (formData['pkDebut'] != null && formData['pkFin'] != null) {
          try {
            final pkDebut = double.parse(formData['pkDebut'].toString());
            final pkFin = double.parse(formData['pkFin'].toString());
            distance = (pkFin - pkDebut).abs();
          } catch (e) {
            // Ignore si la conversion échoue
          }
        }
        
        // Créer l'objet Troncon avec les données du formulaire
        final troncon = Troncon(
          projetId: widget.projetId,
          pkDebut: formData['pkDebut']?.toString(),
          pkFin: formData['pkFin']?.toString(),
          distance: distance ?? double.tryParse(formData['distance']?.toString() ?? ''),
          latitude: double.tryParse(formData['latitude']?.toString() ?? ''),
          longitude: double.tryParse(formData['longitude']?.toString() ?? ''),
          altitude: double.tryParse(formData['altitude']?.toString() ?? ''), // Ajouter l'altitude
          
          // 1️⃣ INFORMATIONS GÉNÉRALES
          longueurTroncon: double.tryParse(formData['longueurTroncon']?.toString() ?? ''),
          largeurEmprise: double.tryParse(formData['largeurEmprise']?.toString() ?? ''),
          classeRoute: formData['classeRoute'] as String?,
          profilTopographique: formData['profilTopographique'] as String?,
          conditionsClimatiques: formData['conditionsClimatiques'] as String?,

          // 2️⃣ ÉTAT DE LA CHAUSSÉE
          typeChaussee: formData['typeChaussee'] as String?,
          presenceNidsPoules: formData['presenceNidsPoules'] as bool? ?? false,
          zonesErosion: formData['zonesErosion'] as bool? ?? false,
          zonesEauStagnante: formData['zonesEauStagnante'] as bool? ?? false,
          bourbiers: formData['bourbiers'] as bool? ?? false,
          deformations: formData['deformations'] as bool? ?? false,

          // 3️⃣ DÉGRADATIONS SPÉCIFIQUES
          typeSol: formData['typeSol'] as String?,

          // 4️⃣ OUVRAGES D'ART & ASSAINISSEMENT
          etatPontsDalots: formData['etatPontsDalots'] as String?,
          busesFonctionnelles: formData['busesFonctionnelles'] as bool?,
          exutoiresZonesEvac: formData['exutoiresZonesEvac'] as bool? ?? false,
          zonesErosionDepots: formData['zonesErosionDepots'] as bool? ?? false,
          drainageSuffisant: formData['drainageSuffisant'] as bool? ?? false,

          // 5️⃣ SÉCURITÉ ROUTIÈRE
          signalisationVerticale: formData['signalisationVerticale'] as bool? ?? false,
          signalisationHorizontale: formData['signalisationHorizontale'] as bool? ?? false,
          glissieresSecurite: formData['glissieresSecurite'] as bool? ?? false,
          visibilite: formData['visibilite'] as String?,
          zonesSensibles: formData['zonesSensibles'] as bool? ?? false,

          // 6️⃣ VILLAGES ET EMPRISE
          nombreVillages: int.tryParse(formData['nombreVillages']?.toString() ?? ''),
          occupationSol: _selectedOccupationSol,
          equipementsSociaux: _selectedEquipementsSociaux,

          // 7️⃣ RECOMMANDATIONS TECHNIQUES
          interventionsSuggerees: _selectedInterventions,
          observationsInterventions: _observations,
          observationsGenerales: formData['observations'] as String?,

          // 8️⃣ IMAGES ET DOCUMENTATION
          images: _images,
        );

        // Sauvegarder le tronçon
        await ref.read(tronconsByProjetProvider(widget.projetId).notifier).createTroncon(troncon);

        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorDialog();
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tronçon ajouté avec succès !',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Le nouveau tronçon a été ajouté au projet ${widget.projetId}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Rediriger vers la page de détail du projet
              context.go('${AppRoutes.projetDetail}/${widget.projetId}');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('Erreur lors de la création du tronçon'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, colorScheme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildForm(context, theme, colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.go('${AppRoutes.projetDetail}/${widget.projetId}'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Nouveau Tronçon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
                             Icons.alt_route,
              size: 80,
              color: colorScheme.onPrimaryContainer.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(theme, colorScheme),
            const SizedBox(height: 30),
            
            // INFORMATIONS DE BASE
            _buildSection(
              title: 'Informations de base',
              icon: Icons.info_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldWithCallback(
                        name: 'pkDebut',
                        label: 'PK Début',
                        icon: Icons.place_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculateDistance(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFieldWithCallback(
                        name: 'pkFin',
                        label: 'PK Fin',
                        icon: Icons.place_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculateDistance(),
                      ),
                    ),
                  ],
                ),
                // Champ distance caché pour stocker la valeur calculée
                FormBuilderTextField(
                  name: 'distance',
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(height: 0, color: Colors.transparent),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                _buildCalculatedDistanceField(),
                const SizedBox(height: 20),
                _buildLocationSection(theme, colorScheme),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 1️⃣ INFORMATIONS GÉNÉRALES
            _buildSection(
              title: '1️⃣ Informations générales',
              icon: Icons.info,
              children: [
                 
                _buildTextField(
                  name: 'largeurEmprise',
                  label: 'Largeur d\'emprise (m)',
                  icon: Icons.width_full,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  name: 'classeRoute',
                  label: 'Classe de route',
                  icon: Icons.alt_route,
                  items: const [
                    ('nationale', 'Route Nationale'),
                    ('provinciale', 'Route Provinciale'),
                    ('locale', 'Route Locale'),
                    ('piste', 'Piste'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  name: 'profilTopographique',
                  label: 'Profil topographique',
                  icon: Icons.terrain,
                  items: const [
                    ('plat', 'Plat'),
                    ('ondule', 'Ondulé'),
                    ('montagneux', 'Montagneux'),
                    ('accidente', 'Accidenté'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  name: 'conditionsClimatiques',
                  label: 'Conditions climatiques',
                  icon: Icons.wb_sunny,
                  items: const [
                    ('seche', 'Saison sèche'),
                    ('pluvieuse', 'Saison pluvieuse'),
                    ('mixte', 'Conditions mixtes'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 2️⃣ ÉTAT DE LA CHAUSSÉE
            _buildSection(
              title: '2️⃣ État de la chaussée',
              icon: Icons.construction,
              children: [
                _buildDropdownField(
                  name: 'typeChaussee',
                  label: 'Type de chaussée',
                  icon: Icons.layers,
                  items: const [
                    ('bitume', 'Bitume'),
                    ('beton', 'Béton'),
                    ('terre', 'Terre'),
                    ('pave', 'Pavé'),
                    ('laterite', 'Latérite'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSwitchField(
                  name: 'presenceNidsPoules',
                  title: 'Présence de nids-de-poule',
                  subtitle: 'Dégradations ponctuelles de la chaussée',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'zonesErosion',
                  title: 'Zones d\'érosion',
                  subtitle: 'Érosion visible de la chaussée',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'zonesEauStagnante',
                  title: 'Zones d\'eau stagnante',
                  subtitle: 'Accumulation d\'eau sur la chaussée',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'bourbiers',
                  title: 'Bourbiers',
                  subtitle: 'Zones boueuses difficiles à franchir',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'deformations',
                  title: 'Déformations',
                  subtitle: 'Déformations structurelles de la chaussée',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 3️⃣ DÉGRADATIONS SPÉCIFIQUES
            _buildSection(
              title: '3️⃣ Dégradations spécifiques',
              icon: Icons.warning,
              children: [
                _buildDropdownField(
                  name: 'typeSol',
                  label: 'Type de sol',
                  icon: Icons.landscape,
                  items: const [
                    ('argile_graveleuse', 'Argile graveleuse'),
                    ('sable', 'Sable'),
                    ('laterite', 'Latérite'),
                    ('argile', 'Argile'),
                    ('roche', 'Roche'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 4️⃣ OUVRAGES D'ART & ASSAINISSEMENT
            _buildSection(
              title: '4️⃣ Ouvrages d\'art & assainissement',
              icon: Icons.water,
              children: [
                _buildDropdownField(
                  name: 'etatPontsDalots',
                  label: 'État des ponts et dalots',
                                     icon: Icons.architecture,
                  items: const [
                    ('bon', 'Bon état'),
                    ('moyen', 'État moyen'),
                    ('mauvais', 'Mauvais état'),
                    ('absent', 'Absent'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  name: 'busesFonctionnelles',
                  label: 'Buses fonctionnelles',
                  icon: Icons.water_drop,
                  items: const [
                    ('oui', 'Oui'),
                    ('non', 'Non'),
                    ('partiellement', 'Partiellement'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSwitchField(
                  name: 'exutoiresZonesEvac',
                  title: 'Exutoires zones d\'évacuation',
                  subtitle: 'Présence d\'exutoires pour l\'évacuation',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'zonesErosionDepots',
                  title: 'Zones d\'érosion/dépôts',
                  subtitle: 'Zones d\'érosion ou de dépôts de sédiments',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'drainageSuffisant',
                  title: 'Drainage suffisant',
                  subtitle: 'Système de drainage adapté',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 5️⃣ SÉCURITÉ ROUTIÈRE
            _buildSection(
              title: '5️⃣ Sécurité routière',
              icon: Icons.security,
              children: [
                _buildSwitchField(
                  name: 'signalisationVerticale',
                  title: 'Signalisation verticale',
                  subtitle: 'Panneaux de signalisation présents',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'signalisationHorizontale',
                  title: 'Signalisation horizontale',
                  subtitle: 'Marquage au sol présent',
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  name: 'glissieresSecurite',
                  title: 'Glissières de sécurité',
                  subtitle: 'Barrières de protection installées',
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  name: 'visibilite',
                  label: 'Visibilité',
                  icon: Icons.visibility,
                  items: const [
                    ('bonne', 'Bonne'),
                    ('moyenne', 'Moyenne'),
                    ('mauvaise', 'Mauvaise'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSwitchField(
                  name: 'zonesSensibles',
                  title: 'Zones sensibles',
                  subtitle: 'Écoles, hôpitaux, marchés à proximité',
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 6️⃣ VILLAGES ET EMPRISE
            _buildSection(
              title: '6️⃣ Villages et emprise',
              icon: Icons.location_city,
              children: [
                _buildTextField(
                  name: 'nombreVillages',
                  label: 'Nombre de villages traversés',
                  icon: Icons.home,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildMultiSelectField(
                  title: 'Occupation du sol',
                  subtitle: 'Sélectionnez les types d\'occupation',
                  icon: Icons.terrain,
                  options: const [
                    'Habitat',
                    'Cultures',
                    'Emprises',
                    'Forêt',
                    'Pâturages',
                    'Zones commerciales',
                  ],
                  selectedItems: _selectedOccupationSol,
                ),
                const SizedBox(height: 20),
                _buildMultiSelectField(
                  title: 'Équipements sociaux',
                  subtitle: 'Infrastructures sociales à proximité',
                  icon: Icons.business,
                  options: const [
                    'École',
                    'Centre de santé',
                    'Marché',
                    'Église',
                    'Mosquée',
                    'Centre communautaire',
                  ],
                  selectedItems: _selectedEquipementsSociaux,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 7️⃣ RECOMMANDATIONS TECHNIQUES
            _buildSection(
              title: '7️⃣ Recommandations techniques',
              icon: Icons.build,
              children: [
                _buildMultiSelectField(
                  title: 'Interventions suggérées',
                  subtitle: 'Types d\'interventions nécessaires',
                  icon: Icons.construction,
                  options: const [
                    'Réfection complète',
                    'Reprofilage',
                    'Drainage',
                    'Revêtement',
                    'Signalisation',
                    'Ouvrages d\'art',
                    'Élargissement',
                    'Renforcement',
                  ],
                  selectedItems: _selectedInterventions,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  name: 'observations',
                  label: 'Observations générales',
                  icon: Icons.note,
                  maxLines: 4,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 8️⃣ IMAGES ET DOCUMENTATION
            _buildSection(
              title: '8️⃣ Images et documentation',
              icon: Icons.camera_alt,
              children: [
                _buildImageSection(),
              ],
            ),
            
            const SizedBox(height: 40),
            _buildActionButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_road,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter un nouveau tronçon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remplissez les informations détaillées du tronçon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Position GPS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Récupérez automatiquement les coordonnées GPS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_isLoadingLocation ? 'Localisation...' : 'Localiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  name: 'latitude',
                  label: 'Latitude',
                  icon: Icons.place,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  initialValue: _currentLatitude?.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  name: 'longitude',
                  label: 'Longitude',
                  icon: Icons.place,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  initialValue: _currentLongitude?.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            name: 'altitude',
            label: 'Altitude (m)',
            icon: Icons.terrain,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: _currentAltitude?.toString(),
            helpText: 'Altitude en mètres au-dessus du niveau de la mer',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? initialValue,
    TextInputType? keyboardType,
    List<String? Function(String?)>? validators,
    String? helpText,
  }) {
    return FormBuilderTextField(
      name: name,
      maxLines: maxLines,
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        helperText: helpText, // Utiliser helperText au lieu de helpText
      ),
      validator: validators != null 
          ? FormBuilderValidators.compose(validators)
          : null,
    );
  }

  Widget _buildTextFieldWithCallback({
    required String name,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? initialValue,
    TextInputType? keyboardType,
    List<String? Function(String?)>? validators,
    void Function(String?)? onChanged,
  }) {
    return FormBuilderTextField(
      name: name,
      maxLines: maxLines,
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validators != null 
          ? FormBuilderValidators.compose(validators)
          : null,
    );
  }

  Widget _buildDropdownField({
    required String name,
    required String label,
    required IconData icon,
    String? initialValue,
    required List<(String, String)> items,
  }) {
    return FormBuilderDropdown<String>(
      name: name,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item.$1,
        child: Text(item.$2),
      )).toList(),
    );
  }

  Widget _buildSwitchField({
    required String name,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: FormBuilderSwitch(
        name: name,
        initialValue: false,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '\n$subtitle',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> options,
    required List<String> selectedItems,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedItems.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedItems.add(option);
                    } else {
                      selectedItems.remove(option);
                    }
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedDistanceField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.straighten,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance (m)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _calculatedDistance != null 
                      ? '${_calculatedDistance!.toStringAsFixed(3)} m'
                      : 'Saisissez PK Début et PK Fin pour calculer automatiquement',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _calculatedDistance != null 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: _calculatedDistance != null 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (_calculatedDistance != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos du tronçon',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Boutons pour ajouter des images
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre une photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galerie'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Affichage des images prises
        if (_images.isNotEmpty) ...[
          Text(
            '${_images.length} photo(s) ajoutée(s)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.file(
                                  File(_images[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_images[index].latitude != null && _images[index].longitude != null) ...[
                                      Text(
                                        'GPS',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${_images[index].latitude!.toStringAsFixed(4)}, ${_images[index].longitude!.toStringAsFixed(4)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 7,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ] else ...[
                                      Text(
                                        'Pas de GPS',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 8,
                                          color: Colors.red,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      // Icône GPS pour indiquer que l'image a des coordonnées
                      if (_images[index].latitude != null && _images[index].longitude != null)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucune photo ajoutée',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: colorScheme.outline,
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_road, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Valider',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
