import 'package:flutter/material.dart'; // Route, MaterialPageRoute

import 'models/annuncio.dart'; // modello Annuncio
import 'screens/annuncio_detail_screen.dart'; // dettaglio
import 'screens/bacheca_screen.dart'; // bacheca
import 'screens/candidatura_form_screen.dart'; // form

// Elenco delle schermate dell'app, ciascuna con un nome (come routes.dart del prof).
class Routes {
  static const bacheca = '/'; // schermata iniziale
  static const annuncioDetail = '/annuncio'; // dettaglio di un annuncio
  static const candidaturaForm = '/candidatura'; // form di candidatura

  // Crea la pagina con l'animazione standard di Android.
  static MaterialPageRoute<dynamic> _page(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);

  // Dato il nome richiesto, restituisce la schermata corrispondente.
  static Route<dynamic> generate(RouteSettings s) {
    final arg = s.arguments; // dato passato alla schermata (es. l'annuncio scelto)
    switch (s.name) { // quale schermata è stata chiesta?
      case annuncioDetail: // dettaglio
        if (arg is Annuncio) return _page(s, AnnuncioDetailScreen(annuncio: arg)); // serve un Annuncio
      case candidaturaForm: // form di candidatura
        if (arg is Annuncio) return _page(s, CandidaturaFormScreen(annuncio: arg)); // serve un Annuncio
    }
    // Nome sconosciuto (o dato mancante): si torna alla bacheca.
    return _page(const RouteSettings(name: bacheca), const BachecaScreen());
  }
}