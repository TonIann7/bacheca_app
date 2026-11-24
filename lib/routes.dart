import 'package:flutter/material.dart'; // Route, MaterialPageRoute

import 'models/annuncio.dart'; // modello Annuncio
import 'providers/auth_provider.dart'; // stato del login
import 'screens/annuncio_detail_screen.dart'; // dettaglio annuncio
import 'screens/annuncio_form_screen.dart'; // nuovo annuncio
import 'screens/area_screen.dart'; // area riservata
import 'screens/bacheca_screen.dart'; // bacheca
import 'screens/candidatura_form_screen.dart'; // form di candidatura
import 'screens/login_screen.dart'; // login
import 'screens/register_screen.dart'; // registrazione
import 'models/candidatura.dart'; // modello Candidatura
import 'screens/candidatura_detail_screen.dart'; // dettaglio candidatura
import 'screens/candidature_screen.dart'; // candidature ricevute

// Elenco delle schermate dell'app, ciascuna con un nome (come routes.dart del prof).
class Routes {
  static const bacheca = '/'; // schermata iniziale, pubblica
  static const annuncioDetail = '/annuncio'; // dettaglio di un annuncio
  static const candidaturaForm = '/candidatura'; // form di candidatura
  static const login = '/login'; // login azienda
  static const register = '/register'; // registrazione azienda
  static const area = '/area'; // area riservata: i miei annunci
  static const annuncioForm = '/area/nuovo'; // nuovo annuncio
  static const candidature = '/area/candidature'; // candidature di un annuncio (schermata in B3)
  static const candidaturaDetail = '/area/candidatura'; // dati di un candidato (schermata in B3)

  // Schermate solo per l'azienda loggata (il server controlla comunque davvero).
  static const _riservate = {area, annuncioForm, candidature, candidaturaDetail};

  // Crea la pagina con l'animazione standard di Android.
  static MaterialPageRoute<dynamic> _page(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);

  // Dato il nome richiesto, restituisce la schermata corrispondente.
  static Route<dynamic> generate(RouteSettings s, AuthProvider auth) {
    final arg = s.arguments; // dato passato alla schermata
    if (_riservate.contains(s.name) && !auth.isLoggedIn) { // area riservata senza login
      return _page(const RouteSettings(name: login), const LoginScreen()); // si viene mandati al login
    }
    switch (s.name) { // quale schermata è stata chiesta?
      case annuncioDetail: // dettaglio annuncio
        if (arg is Annuncio) return _page(s, AnnuncioDetailScreen(annuncio: arg)); // serve un Annuncio
      case candidaturaForm: // form di candidatura
        if (arg is Annuncio) return _page(s, CandidaturaFormScreen(annuncio: arg)); // serve un Annuncio
      case login: // login
        return _page(s, const LoginScreen()); // apre il login
      case register: // registrazione
        return _page(s, const RegisterScreen()); // apre la registrazione
      case area: // area riservata
        return _page(s, const AreaScreen()); // apre l'area riservata
      case annuncioForm: // nuovo annuncio
        return _page(s, const AnnuncioFormScreen()); // apre il form
      case candidature: // candidature ricevute
        if (arg is Annuncio) return _page(s, CandidatureScreen(annuncio: arg)); // serve un Annuncio
      case candidaturaDetail: // dati del candidato
        if (arg is Candidatura) return _page(s, CandidaturaDetailScreen(candidatura: arg)); // serve una Candidatura
    }
    // Nome sconosciuto (o dato mancante): si torna alla bacheca.
    return _page(const RouteSettings(name: bacheca), const BachecaScreen());
  }
}