import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // MultiProvider, ChangeNotifierProvider

import 'providers/auth_provider.dart'; // stato del login
import 'routes.dart'; // nomi e apertura delle schermate
import 'services/api_client.dart'; // richieste al server

void main() {
  runApp(const BachecaApp()); // avvia l'app
}

class BachecaApp extends StatefulWidget {
  const BachecaApp({super.key}); // costruttore

  @override
  State<BachecaApp> createState() => _BachecaAppState(); // crea lo stato
}

class _BachecaAppState extends State<BachecaApp> {
  final _navKey = GlobalKey<NavigatorState>(); // per cambiare schermata da qui
  late final ApiClient _api; // "late": verrà inizializzato in initState
  late final AuthProvider _auth; // stato del login

  @override
  void initState() {
    super.initState(); // sempre per primo
    _api = ApiClient(); // un solo client per tutta l'app
    _auth = AuthProvider(_api); // lo stato del login usa quel client
    _auth.addListener(_onAuthChanged); // chiama _onAuthChanged a ogni cambio di login
    _auth.restoreSession(); // all'avvio prova a ripristinare un login precedente
  }

  // Se la sessione è scaduta, torna alla bacheca e apre il login.
  void _onAuthChanged() {
    if (!_auth.sessionExpired) return; // caso normale: niente da fare
    _auth.sessionExpired = false; // gestita: azzera il segnale
    final nav = _navKey.currentState; // il Navigator dell'app
    nav?.pushNamedAndRemoveUntil(Routes.bacheca, (r) => false); // chiude l'area riservata
    nav?.pushNamed(Routes.login); // e apre il login sopra la bacheca
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged); // smette di ascoltare
    _auth.dispose(); // libera le risorse del provider
    super.dispose(); // sempre per ultimo
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // rende ApiClient e AuthProvider disponibili a tutte le schermate
      providers: [
        Provider<ApiClient>.value(value: _api), // richieste al server
        ChangeNotifierProvider<AuthProvider>.value(value: _auth), // stato del login
      ],
      child: MaterialApp(
        title: 'Bacheca Lavoro', // nome dell'app
        debugShowCheckedModeBanner: false, // niente fascetta DEBUG (utile per i video)
        navigatorKey: _navKey, // collega la chiave al Navigator
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), // colori dell'app
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(), // tutti i campi di testo con il bordo
          ),
        ),
        initialRoute: Routes.bacheca, // prima schermata
        onGenerateRoute: (s) => Routes.generate(s, _auth), // apre le schermate controllando il login
      ),
    );
  }
}