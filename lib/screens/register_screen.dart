import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../providers/auth_provider.dart'; // registrazione
import '../routes.dart'; // nomi delle schermate
import '../services/api_client.dart'; // ApiException
import '../utils/validators.dart'; // controlli sui campi
import '../widgets/error_view.dart'; // InlineErrorBanner

// R1: registrazione dell'azienda.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // costruttore

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(); // crea lo stato
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // chiave del form
  final _nomeCtrl = TextEditingController(); // testo del nome azienda
  final _emailCtrl = TextEditingController(); // testo dell'email
  final _passwordCtrl = TextEditingController(); // testo della password
  bool _submitting = false; // true durante l'invio
  String? _error; // errore del server

  @override
  void dispose() {
    _nomeCtrl.dispose(); // libera la memoria
    _emailCtrl.dispose(); // libera la memoria
    _passwordCtrl.dispose(); // libera la memoria
    super.dispose(); // sempre per ultimo
  }

  // Controlla i campi e crea l'account.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // campi non validi: ci si ferma
    setState(() {
      _submitting = true; // mostra la rotellina
      _error = null; // cancella il vecchio errore
    });
    try {
      await context.read<AuthProvider>().register( // chiede al server di creare l'account
        _nomeCtrl.text.trim(), // nome
        _emailCtrl.text.trim(), // email
        _passwordCtrl.text, // password (senza trim)
      );
      if (!mounted) return; // schermata chiusa: basta
      ScaffoldMessenger.of(context).showSnackBar( // messaggio di conferma
        const SnackBar(content: Text('Account creato! Ora effettua il login')), // testo
      );
      Navigator.of(context).pushReplacementNamed(Routes.login); // passa al login (S1, passo 2)
    } on ApiException catch (e) { // es. "Email già registrata"
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
        title: const Text('Registra azienda'), // titolo
      ),
      body: SingleChildScrollView( // scorrevole
        padding: const EdgeInsets.all(24), // spazio attorno
        child: Form(
          key: _formKey, // collega il form alla chiave
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // figli a tutta larghezza
            children: [
              if (_error != null) InlineErrorBanner(message: _error!), // errore del server
              TextFormField(
                controller: _nomeCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Nome azienda'), // etichetta
                textInputAction: TextInputAction.next, // tasto "avanti"
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: (v) => Validators.required(v, 'il nome dell\'azienda'), // obbligatorio
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _emailCtrl, // collega il controller
                decoration: const InputDecoration(labelText: 'Email'), // etichetta
                keyboardType: TextInputType.emailAddress, // tastiera con la @
                textInputAction: TextInputAction.next, // tasto "avanti"
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: Validators.email, // controllo dell'email
              ),
              const SizedBox(height: 16), // spazio
              TextFormField(
                controller: _passwordCtrl, // collega il controller
                obscureText: true, // pallini al posto delle lettere
                decoration: const InputDecoration(
                  labelText: 'Password', // etichetta
                  helperText: 'Almeno 6 caratteri', // suggerimento sotto il campo
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: Validators.password, // almeno 6 caratteri
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
                    : const Text('Registrati'), // testo normale
              ),
              const SizedBox(height: 12), // spazio
              TextButton(
                onPressed: () => Navigator.of(context) // sostituisce la registrazione...
                    .pushReplacementNamed(Routes.login), // ...con il login
                child: const Text('Hai già un account? Accedi'), // testo
              ),
            ],
          ),
        ),
      ),
    );
  }
}