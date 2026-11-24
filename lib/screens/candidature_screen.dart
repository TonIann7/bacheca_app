import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../models/annuncio.dart'; // modello Annuncio
import '../models/candidatura.dart'; // modello Candidatura
import '../routes.dart'; // nomi delle schermate
import '../services/api_client.dart'; // richieste al server
import '../utils/validators.dart'; // Fmt
import '../widgets/error_view.dart'; // ErrorView

// R7: candidature ricevute da un annuncio dell'azienda.
class CandidatureScreen extends StatefulWidget {
  final Annuncio annuncio; // annuncio scelto nell'area riservata

  const CandidatureScreen({super.key, required this.annuncio}); // costruttore

  @override
  State<CandidatureScreen> createState() => _CandidatureScreenState(); // crea lo stato
}

class _CandidatureScreenState extends State<CandidatureScreen> {
  List<Candidatura> _candidature = []; // candidature ricevute
  bool _loading = true; // true mentre aspettiamo la risposta
  String? _error; // messaggio d'errore

  @override
  void initState() {
    super.initState(); // sempre per primo
    _load(); // carica subito
  }

  // Chiede al server le candidature di questo annuncio.
  Future<void> _load() async {
    setState(() {
      _loading = true; // caricamento in corso
      _error = null; // cancella il vecchio errore
    });
    try {
      final api = context.read<ApiClient>(); // prende l'ApiClient dal MultiProvider
      final data = await api.get('/api/annunci/${widget.annuncio.id}/candidature') as List; // richiesta con il token
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _candidature = data // per ogni elemento...
            .map((e) => Candidatura.fromJson((e as Map).cast<String, dynamic>())) // ...Map -> Candidatura
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
    if (_loading && _candidature.isEmpty) { // primo caricamento
      return _scrollable(const Center(child: CircularProgressIndicator())); // rotellina
    }
    if (_candidature.isEmpty) { // nessuna candidatura
      return _scrollable(const Center(child: Text('Nessuna candidatura ricevuta.'))); // messaggio
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // sempre trascinabile
      padding: const EdgeInsets.all(12), // spazio attorno
      itemCount: _candidature.length, // quante righe
      itemBuilder: (context, index) { // costruisce una riga
        final c = _candidature[index]; // candidatura della riga
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline), // icona
            title: Text(c.nomeCompleto), // nome e cognome
            subtitle: Text('Ricevuta il ${Fmt.date(c.createdAt)}'), // data
            trailing: const Icon(Icons.chevron_right), // freccia
            onTap: () => Navigator.of(context) // apre il dettaglio...
                .pushNamed(Routes.candidaturaDetail, arguments: c), // ...di questa candidatura
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
        title: Text('Candidature: ${widget.annuncio.titolo}'), // titolo con l'annuncio
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()), // trascina per aggiornare
    );
  }
}