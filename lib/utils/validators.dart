// Controlli sui campi dei form, con le stesse regole del server (come nel prof).
// Ogni funzione restituisce il messaggio d'errore, oppure null se il valore va bene.
class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'); // stessa espressione usata sul server

  // Campo di testo obbligatorio. "label" completa la frase, es. "Inserisci il nome".
  static String? required(String? v, String label) {
    final s = (v ?? '').trim(); // se v è null usa stringa vuota, poi toglie gli spazi
    if (s.isEmpty) return 'Inserisci $label'; // vuoto: errore
    return null; // tutto ok
  }

  // Email obbligatoria e con un formato plausibile.
  static String? email(String? v) {
    final s = (v ?? '').trim(); // testo senza spazi ai lati
    if (s.isEmpty) return 'Inserisci l\'email'; // "\'" = apostrofo dentro una stringa
    if (!_email.hasMatch(s)) return 'Email non valida'; // non rispetta il formato
    return null; // tutto ok
  }
}

// Formattazione dei valori da mostrare a schermo.
class Fmt {
  // DateTime -> "24/11/2026".
  static String date(DateTime? d) {
    if (d == null) return '-'; // data mancante
    final l = d.toLocal(); // dall'ora UTC del server all'ora del telefono
    final giorno = l.day.toString().padLeft(2, '0'); // 5 -> "05"
    final mese = l.month.toString().padLeft(2, '0'); // 3 -> "03"
    return '$giorno/$mese/${l.year}'; // compone la data
  }
}