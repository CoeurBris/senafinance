// lib/models/user.dart
class User {
  final int? id;
  final String email;
  final String nom;
  final String passwordHash;   // On garde le hash seulement pour la connexion

  User({
    this.id,
    required this.email,
    required this.nom,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'password_hash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      nom: map['nom'],
      passwordHash: map['password_hash'],
    );
  }

  // Pour créer un User sans le mot de passe (après login)
  User toSafeUser() {
    return User(
      id: id,
      email: email,
      nom: nom,
      passwordHash: '', // on vide le hash pour la sécurité
    );
  }
}