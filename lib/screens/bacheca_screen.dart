import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../models/annuncio.dart'; // modello Annuncio
import '../routes.dart'; // nomi delle schermate
import '../services/api_client.dart'; // richieste al server
import '../utils/validators.dart'; // Fmt
import '../widgets/error_view.dart'; // ErrorView

// R5: elenco pubblico degli annunci. È la schermata iniziale dell'app.
class BachecaScreen extends StatefulWidget {
  const BachecaScreen({super.key}); // costruttore

  @override
  State<BachecaScreen> createState() => _BachecaScreenState(); // crea lo stato
}

class _BachecaScreenState extends State<BachecaScreen> {
  List<Annuncio> _annunci = []; // annunci ricevuti dal server
  bool _loading = true; // true mentre aspettiamo la risposta
  String? _error; // messaggio d'errore (null = nessun errore)

  @override
  void initState() {
    super.initState(); // sempre per primo
    _load(); // appena la schermata nasce, carica gli annunci
  }

  // Chiede gli annunci al server.
  Future<void> _load() async {
    setState(() {
      _loading = true; // mostra la rotellina
      _error = null; // cancella eventuali errori precedenti
    });
    try {
      final api = context.read<ApiClient>(); // prende l'ApiClient dal MultiProvider
      final data = await api.get('/api/annunci') as List; // GET: lista di Map
      if (!mounted) return; // la schermata è stata chiusa nel frattempo? allora basta
      setState(() {
        _annunci = data // per ogni elemento della lista...
            .map((e) => Annuncio.fromJson((e as Map).cast<String, dynamic>())) // ...Map -> Annuncio
            .toList(); // il risultato torna a essere una lista
        _loading = false; // caricamento finito
      });
    } on ApiException catch (e) { // errore del server o di rete
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = e.message; // messaggio da mostrare
        _loading = false; // caricamento finito
      });
    } catch (_) { // risposta con un formato inatteso
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = 'Risposta non valida dal server.'; // messaggio generico
        _loading = false; // caricamento finito
      });
    }
  }

  // ListView anche per i contenuti singoli: così "trascina per aggiornare" funziona sempre.
  Widget _scrollable(Widget child) => ListView(
    physics: const AlwaysScrollableScrollPhysics(), // si può trascinare anche se il contenuto è corto
    children: [SizedBox(height: 400, child: child)], // area alta 400 con il contenuto
  );

  // Decide cosa mostrare: errore, caricamento, lista vuota oppure elenco.
  Widget _buildBody() {
    if (_error != null) { // c'è un errore
      return _scrollable(ErrorView(message: _error!, onRetry: _load)); // errore + Riprova
    }
    if (_loading && _annunci.isEmpty) { // primo caricamento
      return _scrollable(const Center(child: CircularProgressIndicator())); // rotellina
    }
    if (_annunci.isEmpty) { // nessun annuncio
      return _scrollable(const Center(child: Text('Nessun annuncio pubblicato.'))); // lista vuota
    }
    return ListView.builder( // elenco vero e proprio
      physics: const AlwaysScrollableScrollPhysics(), // per "trascina per aggiornare"
      padding: const EdgeInsets.all(12), // spazio attorno alla lista
      itemCount: _annunci.length, // quante righe
      itemBuilder: (context, index) { // costruisce una riga alla volta
        final a = _annunci[index]; // annuncio di questa riga
        final sede = a.sede.isEmpty ? '' : ' • ${a.sede}'; // la sede è facoltativa
        return Card( // riquadro con ombra
          child: ListTile(
            leading: const Icon(Icons.work_outline), // icona a sinistra
            title: Text(a.titolo), // titolo dell'annuncio
            subtitle: Text('${a.aziendaNome}$sede\n${Fmt.date(a.createdAt)}'), // azienda, sede, data
            isThreeLine: true, // lascia spazio per il sottotitolo su due righe
            trailing: const Icon(Icons.chevron_right), // freccia a destra
            onTap: () => Navigator.of(context) // al tocco apre il dettaglio...
                .pushNamed(Routes.annuncioDetail, arguments: a), // ...passandogli l'annuncio
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // colore della barra
        title: const Text('Bacheca Lavoro'), // titolo
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()), // trascina in basso per aggiornare
    );
  }
}