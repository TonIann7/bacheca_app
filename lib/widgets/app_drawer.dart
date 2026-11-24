import 'package:flutter/material.dart'; // widget Material
import 'package:provider/provider.dart'; // context.watch, context.read

import '../providers/auth_provider.dart'; // stato del login
import '../routes.dart'; // nomi delle schermate

// Menu laterale (come app_drawer.dart del prof): le voci cambiano se l'azienda è loggata.
class AppDrawer extends StatelessWidget {
  final String currentRoute; // schermata in cui ci troviamo

  const AppDrawer({super.key, required this.currentRoute}); // costruttore

  // Va a una schermata principale, chiudendo tutte le altre (così si ricarica aggiornata).
  void _goMain(BuildContext context, String route) {
    Navigator.of(context).pop(); // chiude il menu
    if (route == currentRoute) return; // siamo già lì
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false); // "false" = non tenere nessuna schermata sotto
  }

  // Apre una schermata sopra quella attuale (si può tornare indietro).
  void _open(BuildContext context, String route) {
    Navigator.of(context).pop(); // chiude il menu
    Navigator.of(context).pushNamed(route); // apre la schermata
  }

  // R3: logout e ritorno alla bacheca pubblica.
  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context); // lo prendiamo prima dell'await
    final auth = context.read<AuthProvider>(); // anche questo
    nav.pop(); // chiude il menu
    await auth.logout(); // esce dall'account
    nav.pushNamedAndRemoveUntil(Routes.bacheca, (r) => false); // area riservata rimossa dalla pila
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>(); // "watch": si ridisegna quando il login cambia
    final azienda = auth.azienda; // azienda loggata o null
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // niente spazio in alto
        children: [
          UserAccountsDrawerHeader( // intestazione con i dati dell'utente
            accountName: Text(azienda?.nome ?? 'Ospite'), // nome azienda, oppure "Ospite"
            accountEmail: Text(azienda?.email ?? 'Consulta gli annunci e candidati'), // email o invito
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.business)), // icona tonda
          ),
          ListTile(
            leading: const Icon(Icons.work_outline), // icona
            title: const Text('Bacheca'), // sempre visibile
            onTap: () => _goMain(context, Routes.bacheca), // va alla bacheca
          ),
          if (auth.isLoggedIn) ...[ // voci solo per l'azienda autenticata
            ListTile(
              leading: const Icon(Icons.folder_shared_outlined), // icona
              title: const Text('Area riservata'), // i miei annunci
              onTap: () => _goMain(context, Routes.area), // va all'area riservata
            ),
            ListTile(
              leading: const Icon(Icons.logout), // icona
              title: const Text('Logout'), // esci
              onTap: () => _logout(context), // esegue il logout
            ),
          ] else ...[ // voci per chi non è autenticato
            ListTile(
              leading: const Icon(Icons.login), // icona
              title: const Text('Login azienda'), // accedi
              onTap: () => _open(context, Routes.login), // apre il login
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt), // icona
              title: const Text('Registra azienda'), // crea account
              onTap: () => _open(context, Routes.register), // apre la registrazione
            ),
          ],
        ],
      ),
    );
  }
}