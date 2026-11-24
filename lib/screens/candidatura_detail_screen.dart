import 'dart:io'; // File

import 'package:flutter/material.dart'; // widget Material
import 'package:open_filex/open_filex.dart'; // apre un file con l'app adatta
import 'package:path_provider/path_provider.dart'; // cartella temporanea del telefono
import 'package:provider/provider.dart'; // context.read

import '../models/candidatura.dart'; // modello Candidatura
import '../services/api_client.dart'; // richieste al server
import '../utils/validators.dart'; // Fmt

// R7: dati del candidato e apertura del curriculum.
class CandidaturaDetailScreen extends StatefulWidget {
  final Candidatura candidatura; // candidatura scelta

  const CandidaturaDetailScreen({super.key, required this.candidatura}); // costruttore

  @override
  State<CandidaturaDetailScreen> createState() => _CandidaturaDetailScreenState(); // crea lo stato
}

class _CandidaturaDetailScreenState extends State<CandidaturaDetailScreen> {
  bool _opening = false; // true mentre scarichiamo il CV

  // Mostra un messaggio temporaneo in basso.
  void _messaggio(String testo) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(testo))); // SnackBar
  }

  // Scarica il PDF, lo salva in una cartella temporanea e lo apre.
  Future<void> _apriCv() async {
    final c = widget.candidatura; // abbreviazione
    setState(() => _opening = true); // disabilita il pulsante
    try {
      final bytes = await context.read<ApiClient>().getBytes('/api/candidature/${c.id}/cv'); // scarica con il token
      final dir = await getTemporaryDirectory(); // cartella temporanea dell'app
      final file = File('${dir.path}/cv_${c.id}.pdf'); // dove salvarlo
      await file.writeAsBytes(bytes, flush: true); // scrive il PDF
      final result = await OpenFilex.open(file.path, type: 'application/pdf'); // apre il lettore PDF
      if (!mounted) return; // schermata chiusa: basta
      if (result.type != ResultType.done) { // apertura non riuscita
        _messaggio('Impossibile aprire il PDF: installa un lettore PDF'); // spiegazione
      }
    } on ApiException catch (e) { // errore del server o di rete
      if (mounted) _messaggio(e.message); // mostra il motivo
    } catch (_) { // errore nel salvataggio o nell'apertura del file
      if (mounted) _messaggio('Impossibile aprire il curriculum'); // messaggio generico
    } finally {
      if (mounted) setState(() => _opening = false); // in ogni caso riabilita il pulsante
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.candidatura; // abbreviazione
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // colore della barra
        title: const Text('Dati del candidato'), // titolo
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), // spazio attorno
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline), // icona
            title: Text(c.nomeCompleto), // valore
            subtitle: const Text('Nome e cognome'), // descrizione
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined), // icona
            title: Text(c.email), // valore
            subtitle: const Text('Email'), // descrizione
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined), // icona
            title: Text(Fmt.date(c.createdAt)), // valore
            subtitle: const Text('Data di invio'), // descrizione
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined), // icona
            title: Text(c.cvNomeOriginale), // valore
            subtitle: const Text('Curriculum'), // descrizione
          ),
          const SizedBox(height: 16), // spazio
          FilledButton.icon(
            onPressed: _opening ? null : _apriCv, // disabilitato durante lo scaricamento
            icon: const Icon(Icons.open_in_new), // icona
            label: Text(_opening ? 'Apertura...' : 'Apri curriculum'), // testo
          ),
        ],
      ),
    );
  }
}