import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/services/password_hash_service.dart';

void main() {
  group('PasswordHashService', () {
    test('should hash password correctly', () {
      const password = 'testPassword123';
      final hash = PasswordHashService.hashPassword(password);
      
      // Le hash ne doit pas être vide
      expect(hash.isNotEmpty, true);
      
      // Le hash doit contenir un salt et un hash séparés par :
      expect(hash.contains(':'), true);
      
      // Le hash ne doit pas être identique au mot de passe original
      expect(hash, isNot(equals(password)));
    });

    test('should verify password correctly', () {
      const password = 'mySecurePassword456';
      final hash = PasswordHashService.hashPassword(password);
      
      // Le mot de passe correct doit être vérifié avec succès
      expect(PasswordHashService.verifyPassword(password, hash), true);
      
      // Un mauvais mot de passe doit échouer
      expect(PasswordHashService.verifyPassword('wrongPassword', hash), false);
    });

    test('should generate different hashes for same password', () {
      const password = 'samePassword';
      final hash1 = PasswordHashService.hashPassword(password);
      final hash2 = PasswordHashService.hashPassword(password);
      
      // Les hash doivent être différents (salt différent)
      expect(hash1, isNot(equals(hash2)));
      
      // Mais les deux doivent être vérifiés avec succès
      expect(PasswordHashService.verifyPassword(password, hash1), true);
      expect(PasswordHashService.verifyPassword(password, hash2), true);
    });

    test('should detect hashed passwords correctly', () {
      const password = 'testPassword';
      final hash = PasswordHashService.hashPassword(password);
      
      // Doit détecter qu'il s'agit d'un hash
      expect(PasswordHashService.isHashedPassword(hash), true);
      
      // Ne doit pas détecter un mot de passe en clair comme un hash
      expect(PasswordHashService.isHashedPassword(password), false);
      expect(PasswordHashService.isHashedPassword('plaintext'), false);
    });

    test('should handle invalid hash format gracefully', () {
      const password = 'testPassword';
      
      // Hash invalide (pas de :)
      expect(PasswordHashService.verifyPassword(password, 'invalidhash'), false);
      
      // Hash invalide (format incorrect)
      expect(PasswordHashService.verifyPassword(password, 'salt:'), false);
      expect(PasswordHashService.verifyPassword(password, ':hash'), false);
    });

    test('should handle empty passwords', () {
      const emptyPassword = '';
      final hash = PasswordHashService.hashPassword(emptyPassword);
      
      expect(PasswordHashService.verifyPassword(emptyPassword, hash), true);
      expect(PasswordHashService.verifyPassword('notEmpty', hash), false);
    });
  });
} 