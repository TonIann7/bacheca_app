import 'package:flutter/material.dart'; // widget Material

// Errore a tutta area con il pulsante "Riprova" (come nel prof).
class ErrorView extends StatelessWidget {
  final String message; // testo dell'errore
  final VoidCallback onRetry; // funzione da chiamare quando si preme "Riprova"

  const ErrorView({super.key, required this.message, required this.onRetry}); // costruttore

  @override
  Widget build(BuildContext context) {
    return Center( // tutto al centro
      child: Padding(
        padding: const EdgeInsets.all(24), // spazio attorno
        child: Column(
          mainAxisSize: MainAxisSize.min, // alta solo quanto serve
          children: [
            const Icon(Icons.cloud_off, size: 56), // icona "nessuna connessione"
            const SizedBox(height: 12), // spazio
            Text(message, textAlign: TextAlign.center), // il messaggio
            const SizedBox(height: 16), // spazio
            FilledButton.icon( // pulsante con icona
              onPressed: onRetry, // riprova a caricare
              icon: const Icon(Icons.refresh), // icona "ricarica"
              label: const Text('Riprova'), // testo del pulsante
            ),
          ],
        ),
      ),
    );
  }
}

// Riquadro rosso per gli errori del server dentro i form (come nel prof).
class InlineErrorBanner extends StatelessWidget {
  final String message; // testo dell'errore

  const InlineErrorBanner({super.key, required this.message}); // costruttore

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme; // colori del tema
    return Container(
      width: double.infinity, // largo quanto lo schermo
      margin: const EdgeInsets.only(bottom: 16), // spazio sotto
      padding: const EdgeInsets.all(12), // spazio interno
      decoration: BoxDecoration(
        color: scheme.errorContainer, // sfondo rosso chiaro
        borderRadius: BorderRadius.circular(8), // angoli arrotondati
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer), // icona di errore
          const SizedBox(width: 8), // spazio
          Expanded( // il testo occupa lo spazio rimanente e va a capo
            child: Text(message, style: TextStyle(color: scheme.onErrorContainer)), // il messaggio
          ),
        ],
      ),
    );
  }
}