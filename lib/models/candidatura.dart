// Una candidatura come la riceve l'azienda dal server.
class Candidatura {
  final int id;
  final int annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String cvNomeOriginale; // nome del PDF caricato dal candidato
  final DateTime? createdAt; // data di invio

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvNomeOriginale,
    required this.createdAt,
  });

  String get nomeCompleto => '$nome $cognome'; // comodo per i titoli delle liste

  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
    id: j['id'] as int,
    annuncioId: j['annuncioId'] as int,
    nome: (j['nome'] ?? '').toString(),
    cognome: (j['cognome'] ?? '').toString(),
    email: (j['email'] ?? '').toString(),
    cvNomeOriginale: (j['cvNomeOriginale'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()),
  );
}