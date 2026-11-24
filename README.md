# Bacheca Lavoro - App

App Flutter per gestire una bacheca di annunci di lavoro (corso EMAD).
Il back-end è qui: https://github.com/TonIann7/bacheca_server

## Funzionalità

- Azienda: registrazione, login, logout, pubblicazione di annunci,
  consultazione delle candidature e apertura del curriculum
- Candidato (senza account): bacheca, dettaglio annuncio,
  candidatura con curriculum in PDF

## Avvio

1. Avviare il server.
2. Collegare il telefono alla stessa rete del PC.
3. Avviare l'app indicando l'indirizzo del server:

```bash
flutter pub get  # scarica i pacchetti
flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:8080  # avvia l'app
```

Sull'emulatore Android `--dart-define` non serve: si usa `http://10.0.2.2:8080`.

## Struttura di `lib`

- `config`: indirizzo del server
- `services`: richieste HTTP
- `providers`: stato del login
- `models`: azienda, annuncio, candidatura
- `screens` e `widgets`: interfaccia
- `routes.dart`: navigazione e protezione dell'area riservata