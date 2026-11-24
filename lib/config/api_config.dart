// Configurazione di rete (come api_config.dart del prof).
// Per il telefono vero si avvia con:
//   flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:8080
class ApiConfig {
  static const String baseUrl = String.fromEnvironment( // valore letto all'avvio da --dart-define
    'API_BASE_URL', // nome della variabile
    defaultValue: 'http://10.0.2.2:8080', // se non la passi: indirizzo del PC visto dall'emulatore Android
  );
  static const Duration timeout = Duration(seconds: 10); // dopo 10 secondi senza risposta: errore di rete
}