import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../models/annuncio.dart'; // modello Annuncio
import '../routes.dart'; // nomi delle schermate
import '../services/api_client.dart'; // richieste al server
import '../widgets/app_drawer.dart'; // menu laterale
import '../widgets/error_view.dart'; // ErrorView

// Area riservata: gli annunci dell'azienda loggata (R7) e il pulsante per pubblicarne (R4).
class AreaScreen extends StatefulWidget {
  const AreaScreen({super.key}); // costruttore

  @override
  State<AreaScreen> createState() => _AreaScreenState(); // crea lo stato
}

class _AreaScreenState extends State<AreaScreen> {
  List<Annuncio> _annunci = []; // i miei annunci
  bool _loading = true; // true mentre aspettiamo la risposta
  String? _error; // messaggio d'errore

  @override
  void initState() {
    super.initState(); // sempre per primo
    _load(); // carica subito gli annunci
  }

  // Chiede al server gli annunci dell'azienda loggata.
  Future<void> _load() async {
    setState(() {
      _loading = true; // caricamento in corso
      _error = null; // cancella il vecchio errore
    });
    try {
      final data = await context.read<ApiClient>().get('/api/me/annunci') as List; // richiesta con il token
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _annunci = data // per ogni elemento...
            .map((e) => Annuncio.fromJson((e as Map).cast<String, dynamic>())) // ...Map -> Annuncio
            .toList(); // torna una lista
        _loading = false; // finito
      });
    } on ApiException catch (e) { // errore del server o di rete
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = e.message; // messaggio
        _loading = false; // finito
      });
    }
  }

  // R4: apre il form; se l'annuncio è stato pubblicato, ricarica l'elenco.
  Future<void> _nuovoAnnuncio() async {
    final pubblicato = await Navigator.of(context).pushNamed(Routes.annuncioForm); // aspetta la chiusura del form
    if (pubblicato == true && mounted) _load(); // true = pubblicato (null = l'utente è tornato indietro)
  }

  // R7: apre le candidature di un annuncio; al ritorno aggiorna i conteggi.
  Future<void> _apriCandidature(Annuncio a) async {
    await Navigator.of(context).pushNamed(Routes.candidature, arguments: a); // aspetta il ritorno
    if (mounted) _load(); // aggiorna
  }

  // ListView anche per i contenuti singoli, per "trascina per aggiornare".
  Widget _scrollable(Widget child) => ListView(
    physics: const AlwaysScrollableScrollPhysics(), // sempre trascinabile
    children: [SizedBox(height: 400, child: child)], // area con il contenuto
  );

  // Decide cosa mostrare.
  Widget _buildBody() {
    if (_error != null) { // errore
      return _scrollable(ErrorView(message: _error!, onRetry: _load)); // errore + Riprova
    }
    if (_loading && _annunci.isEmpty) { // primo caricamento
      return _scrollable(const Center(child: CircularProgressIndicator())); // rotellina
    }
    if (_annunci.isEmpty) { // nessun annuncio
      return _scrollable(const Center(
        child: Text('Nessun annuncio.\nPremi + per pubblicarne uno.', textAlign: TextAlign.center), // invito
      ));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // sempre trascinabile
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88), // 88 sotto: il pulsante + non copre l'ultima riga
      itemCount: _annunci.length, // quante righe
      itemBuilder: (context, index) { // costruisce una riga
        final a = _annunci[index]; // annuncio della riga
        return Card(
          child: ListTile(
            leading: const Icon(Icons.work_outline), // icona
            title: Text(a.titolo), // titolo
            subtitle: Text('Candidature ricevute: ${a.numCandidature}'), // conteggio dal server
            trailing: const Icon(Icons.chevron_right), // freccia
            onTap: () => _apriCandidature(a), // apre le candidature
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
        title: const Text('I miei annunci'), // titolo
      ),
      drawer: const AppDrawer(currentRoute: Routes.area), // menu con il logout
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()), // trascina per aggiornare
      floatingActionButton: FloatingActionButton(
        onPressed: _nuovoAnnuncio, // apre il form
        tooltip: 'Nuovo annuncio', // suggerimento
        child: const Icon(Icons.add), // icona +
      ),
    );
  }
}