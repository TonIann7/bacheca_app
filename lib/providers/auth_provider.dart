import 'package:flutter/foundation.dart'; // ChangeNotifier
import 'package:shared_preferences/shared_preferences.dart'; // memoria persistente del telefono

import '../models/azienda.dart';
import '../services/api_client.dart';

// Tiene lo stato del login dell'azienda e avvisa le schermate quando cambia (come nel prof).
class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token'; // chiave con cui salviamo il token sul telefono

  final ApiClient _api; // per parlare col server
  Azienda? _azienda; // azienda loggata (null = nessuno)
  bool _initializing = true; // true mentre all'avvio controlliamo se c'era una sessione salvata

  AuthProvider(this._api) {
    _api.onUnauthorized = _clearLocal; // se il server dice 401, usciamo in locale
  }

  Azienda? get azienda => _azienda; // chi è loggato
  bool get isLoggedIn => _azienda != null; // c'è qualcuno loggato?
  bool get initializing => _initializing; // stiamo ancora caricando?

  // All'avvio: se sul telefono c'è un token salvato, chiede al server "chi sono?".
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // apre la memoria del telefono
      final token = prefs.getString(_tokenKey); // legge il token (o null)
      if (token != null) {
        _api.token = token; // lo usa per la prossima richiesta
        try {
          final json = await _api.get('/api/auth/me'); // il server lo riconosce ancora?
          _azienda = Azienda.fromJson((json as Map).cast<String, dynamic>());
        } catch (_) {
          await _clearLocal(); // token scaduto (es. server riavviato): lo cancelliamo
        }
      }
    } finally {
      _initializing = false; // in ogni caso abbiamo finito di caricare
      notifyListeners(); // avvisa le schermate di ridisegnarsi
    }
  }

  // R2: login con email e password.
  Future<void> login(String email, String password) async {
    final json = await _api.post('/api/auth/login',
        body: {'email': email, 'password': password});
    await _setSession((json as Map).cast<String, dynamic>());
  }
  // R1: registrazione (dopo la quale il server ci considera già loggati).
  // R1: registrazione. Crea solo l'account: poi l'azienda dovrà fare il login (S1, passo 2).
  Future<void> register(String nome, String email, String password) async {
    await _api.post('/api/auth/register', // chiede al server di creare l'account
        body: {'nome': nome, 'email': email, 'password': password}); // dati inseriti nel form
  }

  // R3: logout.
  Future<void> logout() async {
    try {
      await _api.post('/api/auth/logout'); // invalida il token sul server
    } catch (_) {
      // anche se il server non risponde, usciamo comunque in locale
    }
    await _clearLocal();
  }

  // Salva token e azienda dopo login/registrazione.
  Future<void> _setSession(Map<String, dynamic> json) async {
    final token = json['token'] as String;
    _api.token = token; // da ora tutte le richieste portano il token
    _azienda = Azienda.fromJson((json['azienda'] as Map).cast<String, dynamic>());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token); // lo ricordiamo anche se l'app viene chiusa
    notifyListeners(); // le schermate che ascoltano si aggiornano
  }

  // Dimentica la sessione: niente token, niente azienda.
  Future<void> _clearLocal() async {
    _api.token = null;
    _azienda = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}