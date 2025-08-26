import '../lib/core/services/password_hash_service.dart';

/// Démonstration du fonctionnement du hachage des mots de passe
void main() {
  print('=== DÉMONSTRATION DU HACHAGE DES MOTS DE PASSE ===\n');

  // 1. Hachage d'un mot de passe
  const password = 'monMotDePasseSecret123!';
  print('🔐 Mot de passe original: $password');
  
  final hash1 = PasswordHashService.hashPassword(password);
  print('🔑 Hash généré: $hash1');
  
  // 2. Vérification du mot de passe
  final isValid = PasswordHashService.verifyPassword(password, hash1);
  print('✅ Vérification réussie: $isValid');
  
  // 3. Tentative avec un mauvais mot de passe
  final isInvalid = PasswordHashService.verifyPassword('mauvaisMotDePasse', hash1);
  print('❌ Vérification avec mauvais mot de passe: $isInvalid');
  
  print('\n--- SÉCURITÉ ---');
  
  // 4. Démonstration que chaque hash est unique
  final hash2 = PasswordHashService.hashPassword(password);
  print('🔄 Nouveau hash du même mot de passe: $hash2');
  print('🔒 Les hash sont différents: ${hash1 != hash2}');
  print('✅ Mais les deux sont valides: ${PasswordHashService.verifyPassword(password, hash2)}');
  
  print('\n--- DÉTECTION DE FORMAT ---');
  
  // 5. Détection de format
  print('🔍 "$hash1" est un hash: ${PasswordHashService.isHashedPassword(hash1)}');
  print('🔍 "$password" est un hash: ${PasswordHashService.isHashedPassword(password)}');
  
  print('\n--- STRUCTURE DU HASH ---');
  final parts = hash1.split(':');
  print('📋 Salt (${parts[0].length} caractères): ${parts[0]}');
  print('📋 Hash SHA-256 (${parts[1].length} caractères): ${parts[1]}');
  
  print('\n=== DÉMONSTRATION TERMINÉE ===');
} 