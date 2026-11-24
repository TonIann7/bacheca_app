import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.read

import '../providers/auth_provider.dart'; // login
import '../routes.dart'; // nomi delle schermate
import '../services/api_client.dart'; // ApiException
import '../utils/validators.dart'; // controlli sui campi
import '../widgets/error_view.dart'; // InlineErrorBanner

// R2: login dell'azienda.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // costruttore

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // crea lo stato
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // chiave del form
  final _emailCtrl = TextEditingController(); // testo dell'email
  final _passwordCtrl = TextEditingController(); // testo della password
  bool _obscure = true; // true = password nascosta
  bool _submitting = false; // true durante l'invio
  String? _error; // errore del server

  @override
  void dispose() {
    _emailCtrl.dispose(); // libera la memoria
    _passwordCtrl.dispose(); // libera la memoria
    super.dispose(); // sempre per ultimo
  }

  // Controlla i campi ed esegue il login.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // campi non validi: ci si ferma
    final auth = context.read<AuthProvider>(); // lo prendiamo prima dell'await
    setState(() {
      _submitting = true; // mostra la rotellina
      _error = null; // cancella il vecchio errore
    });
    try {
      await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text); // chiede al server
      if (!mounted) return; // schermata chiusa: basta
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.area, (r) => false); // apre l'area riservata
    } on ApiException catch (e) { // es. "Credenziali non valide"
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = e.message; // mostra il motivo
        _submitting = false; // riabilita il pulsante
      });
    } catch (_) { // risposta con un formato inatteso
      if (!mounted) return; // schermata chiusa: basta
      setState(() {
        _error = 'Risposta non valida dal server.'; // messaggio generico
        _submitting = false; // riabilita il pulsante
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // colore della barra
        title: const Text('Login azienda'), // titolo
      ),
      body: SingleChildScrollView( // scorrevole: la tastiera copre lo schermo
        padding: const EdgeInsets.all(24), // spazio attorno
        child: Form(
          key: _formKey, // collega il form alla chiave
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // figli a tutta larghezza
            children: [
              if (_error != null) InlineErrorBanner(message: _error!), // errore del server
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
                obscureText: _obscure, // mostra i pallini al posto delle lettere
                decoration: InputDecoration(
                  labelText: 'Password', // etichetta
                  suffixIcon: IconButton( // occhio per mostrare/nascondere
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), // icona
                    onPressed: () => setState(() => _obscure = !_obscure), // inverte
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction, // ricontrolla mentre scrivi
                validator: (v) => (v ?? '').isEmpty ? 'Inserisci la password' : null, // obbligatoria
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
                    : const Text('Accedi'), // testo normale
              ),
              const SizedBox(height: 12), // spazio
              TextButton(
                onPressed: () => Navigator.of(context) // sostituisce il login...
                    .pushReplacementNamed(Routes.register), // ...con la registrazione
                child: const Text('Non hai un account? Registrati'), // testo
              ),
            ],
          ),
        ),
      ),
    );
  }
}