import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../services/api_client.dart'; // richieste al server
import '../utils/validators.dart'; // controlli sui campi
import '../widgets/error_view.dart'; // InlineErrorBanner

// R4: form per pubblicare un nuovo annuncio.
class AnnuncioFormScreen extends StatefulWidget {
  const AnnuncioFormScreen({super.key}); // costruttore

  @override
  State<AnnuncioFormScreen> createState() => _AnnuncioFormScreenState(); // crea lo stato
}

class _AnnuncioFormScreenState extends State<AnnuncioFormScreen> {
  final _formKey = GlobalKey<FormState>(); // chiave del form
  final _titoloCtrl = TextEditingController(); // testo del titolo
  final _descrizioneCtrl = TextEditingController(); // testo della descrizione
  final _sedeCtrl = TextEditingController(); // testo della sede
  bool _submitting = false; // true durante l'invio
  String? _error; // errore del server

  @override
  void dispose() {
    _titoloCtrl.dispose(); // libera la memoria
    _descrizioneCtrl.dispose(); // libera la memoria
    _sedeCtrl.dispose(); // libera la memoria
    super.dispose(); // sempre per ultimo
  }

  // Controlla i campi e pubblica l'annuncio.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // campi non validi: ci si ferma
    setState(() {
      _submitting = true; // mostra la rotellina
      _error = null; // cancella il vecchio errore
    });
    try {
      await context.read<ApiClient>().post('/api/annunci', body: { // POST con il token
        'titolo': _titoloCtrl.text.trim(), // titolo
        'descrizione': _descrizioneCtrl.text.trim(), // descrizione
        'sede': _sedeCtrl.text.trim(), // sede (può essere vuota)
      });
      if (!mounted) return; // schermata chiusa: basta
      ScaffoldMessenger.of(context).showSnackBar( // conferma
        const SnackBar(content: Text('Annuncio pubblicato')), // testo
      );
      Navigator.of(context).pop(true); // torna all'area riservata dicendo "pubblicato"
    } on ApiException catch (e) { // errore del server o di rete
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = e.message; // mostra il motivo
        _submitting = false; // riabilita il pulsante
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // colore della barra
        title: const Text('Nuovo annuncio'), // titolo
      ),
      body: SingleChildScrollView( // scorrevole
        padding: const EdgeInsets.all(16), // spazio attorno
        child: Form(
          key: _formKey, // collega il form alla chiave
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // figli a tutta larghezza
            children: [
              if (_error != null) InlineErrorBanner(message: _error!), // errore del server
              TextFormField(
                controller: _titoloCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Titolo'), // etichetta
                textCapitalization: TextCapitalization.sentences, // prima lettera maiuscola
                textInputAction: TextInputAction.next, // tasto "avanti"
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: (v) => Validators.required(v, 'il titolo'), // obbligatorio
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _sedeCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Sede (facoltativa)'), // etichetta
                textCapitalization: TextCapitalization.words, // iniziali maiuscole
                textInputAction: TextInputAction.next, // tasto "avanti"
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _descrizioneCtrl, // collega il controller
                decoration: const InputDecoration(
                  labelText: 'Descrizione', // etichetta
                  alignLabelWithHint: true, // etichetta in alto
                ),
                textCapitalization: TextCapitalization.sentences, // prima lettera maiuscola
                maxLines: 6, // campo alto 6 righe
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: (v) => Validators.required(v, 'la descrizione'), // obbligatoria
              ),
              const SizedBox(height: 24), // spazio
              FilledButton(
                onPressed: _submitting ? null : _submit, // evita il doppio invio
                child: _submitting
                    ? const SizedBox( // rotellina piccola
                  width: 20, // larghezza
                  height: 20, // altezza
                  child: CircularProgressIndicator(strokeWidth: 2), // rotellina
                )
                    : const Text('Pubblica'), // testo normale
              ),
            ],
          ),
        ),
      ),
    );
  }
}