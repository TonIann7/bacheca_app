import 'package:flutter/material.dart'; // widget Material

import '../models/annuncio.dart'; // modello Annuncio
import '../routes.dart'; // nomi delle schermate
import '../utils/validators.dart'; // Fmt

// R5: dettaglio di un annuncio, con il pulsante per candidarsi.
class AnnuncioDetailScreen extends StatelessWidget { // Stateless: qui non cambia nulla
  final Annuncio annuncio; // l'annuncio scelto nella bacheca

  const AnnuncioDetailScreen({super.key, required this.annuncio}); // costruttore

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme; // stili di testo del tema
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // colore della barra
        title: const Text('Dettaglio annuncio'), // titolo
      ),
      body: ListView( // scorrevole: la descrizione può essere lunga
        padding: const EdgeInsets.all(16), // spazio attorno
        children: [
          Text(annuncio.titolo, style: text.headlineSmall), // titolo grande
          const SizedBox(height: 12), // spazio
          Row(children: [ // riga con icona e nome dell'azienda
            const Icon(Icons.business, size: 20), // icona azienda
            const SizedBox(width: 8), // spazio
            Expanded(child: Text(annuncio.aziendaNome)), // nome (va a capo se lungo)
          ]),
          if (annuncio.sede.isNotEmpty) ...[ // solo se c'è una sede ("...[" = aggiunge più widget)
            const SizedBox(height: 8), // spazio
            Row(children: [ // riga con la sede
              const Icon(Icons.place_outlined, size: 20), // icona luogo
              const SizedBox(width: 8), // spazio
              Expanded(child: Text(annuncio.sede)), // sede
            ]),
          ],
          const SizedBox(height: 8), // spazio
          Row(children: [ // riga con la data
            const Icon(Icons.calendar_today_outlined, size: 20), // icona calendario
            const SizedBox(width: 8), // spazio
            Text('Pubblicato il ${Fmt.date(annuncio.createdAt)}'), // data
          ]),
          const Divider(height: 32), // linea di separazione
          Text(annuncio.descrizione, style: text.bodyLarge), // descrizione completa
        ],
      ),
      bottomNavigationBar: SafeArea( // barra fissa in basso, fuori dai bordi del telefono
        child: Padding(
          padding: const EdgeInsets.all(16), // spazio attorno
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context) // apre il form...
                .pushNamed(Routes.candidaturaForm, arguments: annuncio), // ...per questo annuncio
            icon: const Icon(Icons.send), // icona "invia"
            label: const Text('Candidati'), // testo del pulsante
          ),
        ),
      ),
    );
  }
}