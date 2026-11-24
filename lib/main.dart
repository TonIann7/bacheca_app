import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // MultiProvider, ChangeNotifierProvider

import 'providers/auth_provider.dart';
import 'services/api_client.dart';

void main() {
  runApp(const BachecaApp()); // avvia l'app
}

class BachecaApp extends StatefulWidget {
  const BachecaApp({super.key});

  @override
  State<BachecaApp> createState() => _BachecaAppState();
}

class _BachecaAppState extends State<BachecaApp> {
  late final ApiClient _api; // "late": verrà inizializzato in initState
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(); // un solo client per tutta l'app
    _auth = AuthProvider(_api); // lo stato del login usa quel client
    _auth.restoreSession(); // all'avvio prova a ripristinare un login precedente
  }

  @override
  void dispose() {
    _auth.dispose(); // libera le risorse del provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // rende ApiClient e AuthProvider disponibili a TUTTE le schermate
      providers: [
        Provider<ApiClient>.value(value: _api),
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
      ],
      child: MaterialApp(
        title: 'Bacheca Lavoro',
        debugShowCheckedModeBanner: false, // niente fascetta DEBUG (utile per i video)
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), // colori dell'app
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(), // tutti i campi di testo con il bordo
          ),
        ),
        home: const _ProvaConnessione(), // TEMPORANEO: lo sostituiremo con la bacheca in B1
      ),
    );
  }
}

// TEMPORANEO: schermata che verifica che l'app raggiunga il server.
class _ProvaConnessione extends StatelessWidget {
  const _ProvaConnessione();

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>(); // prende l'ApiClient fornito dal MultiProvider
    return Scaffold(
      appBar: AppBar(title: const Text('Prova connessione')),
      body: Center(
        child: FutureBuilder( // costruisce la UI in base al risultato di un Future
          future: api.get('/api/health'), // chiede al server "sei vivo?"
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator(); // in attesa: rotellina
            }
            if (snapshot.hasError) {
              return Text('Errore: ${snapshot.error}'); // es. server spento
            }
            return Text('Server raggiungibile: ${snapshot.data}'); // {status: ok}
          },
        ),
      ),
    );
  }
}