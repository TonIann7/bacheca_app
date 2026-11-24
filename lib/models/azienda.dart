// L'azienda come la vede l'app (senza password: il server non la manda mai).
class Azienda {
  final int id;
  final String nome;
  final String email;

  const Azienda({required this.id, required this.nome, required this.email});

  // Crea un'Azienda dal JSON ricevuto dal server. "?? ''" evita errori se un campo manca.
  factory Azienda.fromJson(Map<String, dynamic> j) => Azienda(
    id: j['id'] as int,
    nome: (j['nome'] ?? '').toString(),
    email: (j['email'] ?? '').toString(),
  );
}