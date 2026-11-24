// Un annuncio di lavoro come arriva dal server.
class Annuncio {
  final int id;
  final String aziendaNome; // chi offre il lavoro
  final String titolo;
  final String descrizione;
  final String sede; // può essere vuota
  final DateTime? createdAt; // data di pubblicazione (null se non leggibile)
  final int numCandidature; // presente solo in "i miei annunci", altrimenti 0

  const Annuncio({
    required this.id,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    required this.sede,
    required this.createdAt,
    required this.numCandidature,
  });

  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
    id: j['id'] as int,
    aziendaNome: (j['aziendaNome'] ?? '').toString(),
    titolo: (j['titolo'] ?? '').toString(),
    descrizione: (j['descrizione'] ?? '').toString(),
    sede: (j['sede'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()), // testo ISO -> DateTime
    numCandidature: (j['numCandidature'] as int?) ?? 0, // se il campo non c'è, vale 0
  );
}