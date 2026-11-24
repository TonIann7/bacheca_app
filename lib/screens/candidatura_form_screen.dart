import 'dart:convert'; // base64Encode

import 'package:file_picker/file_picker.dart'; // scelta del file PDF
import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../models/annuncio.dart'; // modello Annuncio
import '../services/api_client.dart'; // richieste al server
import '../utils/validators.dart'; // controlli sui campi
import '../widgets/error_view.dart'; // InlineErrorBanner

const int _maxCvBytes = 5 * 1024 * 1024; // 5 MB, lo stesso limite del server

// R6: form di candidatura (il candidato non fa login).
class CandidaturaFormScreen extends StatefulWidget {
  final Annuncio annuncio; // annuncio a cui ci si candida

  const CandidaturaFormScreen({super.key, required this.annuncio}); // costruttore

  @override
  State<CandidaturaFormScreen> createState() => _CandidaturaFormScreenState(); // crea lo stato
}

class _CandidaturaFormScreenState extends State<CandidaturaFormScreen> {
  final _formKey = GlobalKey<FormState>(); // chiave del form, come nella to-do list
  final _nomeCtrl = TextEditingController(); // testo del campo Nome
  final _cognomeCtrl = TextEditingController(); // testo del campo Cognome
  final _emailCtrl = TextEditingController(); // testo del campo Email
  String? _cvNome; // nome del PDF scelto (null = nessuno)
  List<int>? _cvBytes; // contenuto del PDF scelto
  String? _cvError; // errore sul curriculum
  String? _serverError; // errore ricevuto dal server
  bool _sending = false; // true durante l'invio

  @override
  void dispose() {
    _nomeCtrl.dispose(); // libera la memoria del controller Nome
    _cognomeCtrl.dispose(); // ...Cognome
    _emailCtrl.dispose(); // ...Email
    super.dispose(); // sempre per ultimo
  }

  // Apre il selettore di file del telefono.
  Future<void> _pickCv() async {
    try {
      final file = await FilePicker.pickFile( // aspetta che l'utente scelga
        type: FileType.custom, // filtro personalizzato...
        allowedExtensions: ['pdf'], // ...solo PDF
      );
      if (file == null) return; // l'utente ha annullato: non cambia nulla
      final bytes = await file.readAsBytes(); // legge il contenuto del file
      if (!mounted) return; // schermata chiusa nel frattempo
      setState(() {
        if (!file.name.toLowerCase().endsWith('.pdf')) { // non è un PDF
          _cvError = 'Il curriculum deve essere un file PDF'; // messaggio
        } else if (bytes.length > _maxCvBytes) { // troppo grande
          _cvError = 'Il curriculum supera i 5 MB'; // messaggio
        } else { // tutto ok: lo memorizza
          _cvNome = file.name; // nome del file
          _cvBytes = bytes; // contenuto del file
          _cvError = null; // nessun errore
        }
      });
    } catch (_) { // problema nell'apertura o nella lettura del file
      if (!mounted) return; // schermata chiusa: basta
      setState(() => _cvError = 'Impossibile leggere il file scelto'); // messaggio
    }
  }

  // Controlla i dati e invia la candidatura al server.
  Future<void> _invia() async {
    final formOk = _formKey.currentState!.validate(); // controlla i tre campi di testo
    setState(() {
      _serverError = null; // cancella il vecchio errore del server
      if (_cvBytes == null) _cvError = 'Allega il curriculum in PDF'; // manca il CV
    });
    if (!formOk || _cvBytes == null) return; // qualcosa non va: ci si ferma

    setState(() => _sending = true); // disabilita il pulsante e mostra la rotellina
    try {
      await context.read<ApiClient>().post( // POST al server
        '/api/annunci/${widget.annuncio.id}/candidature', // endpoint dell'annuncio
        body: {
          'nome': _nomeCtrl.text.trim(), // nome senza spazi ai lati
          'cognome': _cognomeCtrl.text.trim(), // cognome
          'email': _emailCtrl.text.trim(), // email
          'cvNome': _cvNome, // nome del file
          'cvBase64': base64Encode(_cvBytes!), // byte del PDF -> testo
        },
      );
      if (!mounted) return; // schermata chiusa: basta
      ScaffoldMessenger.of(context).showSnackBar( // messaggio di conferma (S2, passo 4)
        const SnackBar(content: Text('Candidatura inviata con successo!')), // testo
      );
      Navigator.of(context).pop(); // torna al dettaglio dell'annuncio
    } on ApiException catch (e) { // il server ha rifiutato, o non risponde
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _serverError = e.message; // mostra il motivo
        _sending = false; // riabilita il pulsante
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme; // colori del tema
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.inversePrimary, // colore della barra
        title: const Text('Candidatura'), // titolo
      ),
      body: SingleChildScrollView( // scorrevole: la tastiera copre parte dello schermo
        padding: const EdgeInsets.all(16), // spazio attorno
        child: Form(
          key: _formKey, // collega il form alla chiave
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // figli larghi quanto lo schermo
            children: [
              Text(
                'Candidatura per: ${widget.annuncio.titolo}', // "widget." = dati della classe sopra
                style: Theme.of(context).textTheme.titleMedium, // stile del testo
              ),
              const SizedBox(height: 16), // spazio
              if (_serverError != null) InlineErrorBanner(message: _serverError!), // errore del server
              TextFormField(
                controller: _nomeCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Nome'), // etichetta
                textCapitalization: TextCapitalization.words, // iniziale maiuscola
                textInputAction: TextInputAction.next, // tasto "avanti" sulla tastiera
                autovalidateMode: AutovalidateMode.onUserInteraction, // l'errore sparisce correggendo
                validator: (v) => Validators.required(v, 'il nome'), // obbligatorio
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _cognomeCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Cognome'), // etichetta
                textCapitalization: TextCapitalization.words, // iniziale maiuscola
                textInputAction: TextInputAction.next, // tasto "avanti"
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: (v) => Validators.required(v, 'il cognome'), // obbligatorio
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _emailCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Email'), // etichetta
                keyboardType: TextInputType.emailAddress, // tastiera con la @
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: Validators.email, // senza parentesi: passiamo la funzione
              ),
              const SizedBox(height: 16), // spazio
              OutlinedButton.icon(
                onPressed: _sending ? null : _pickCv, // null = pulsante disabilitato durante l'invio
                icon: const Icon(Icons.attach_file), // graffetta
                label: Text(_cvNome ?? 'Allega curriculum (PDF)'), // dopo la scelta mostra il nome
              ),
              if (_cvError != null) // errore sul curriculum, in rosso
                Padding(
                  padding: const EdgeInsets.only(top: 8), // spazio sopra
                  child: Text(_cvError!, style: TextStyle(color: scheme.error)), // messaggio
                ),
              const SizedBox(height: 24), // spazio
              FilledButton(
                onPressed: _sending ? null : _invia, // evita il doppio invio
                child: _sending
                    ? const SizedBox( // rotellina piccola durante l'invio
                  width: 20, // larghezza
                  height: 20, // altezza
                  child: CircularProgressIndicator(strokeWidth: 2), // rotellina sottile
                )
                    : const Text('Invia candidatura'), // testo normale
              ),
            ],
          ),
        ),
      ),
    );
  }
}