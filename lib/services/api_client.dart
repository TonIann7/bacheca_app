import 'dart:async'; // TimeoutException
import 'dart:convert'; // jsonEncode, jsonDecode, utf8
import 'dart:io'; // SocketException (errore di rete)

import 'package:http/http.dart' as http; // il pacchetto per fare richieste HTTP

import '../config/api_config.dart'; // baseUrl e timeout

// Errore restituito dal server (o di rete) con codice e messaggio da mostrare all'utente.
class ApiException implements Exception {
  final int statusCode; // codice HTTP; 0 = errore di rete (server spento, IP sbagliato...)
  final String message; // messaggio leggibile, es. "Credenziali non valide"
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message; // così basta "$e" per mostrare il messaggio
}

// Messaggio usato per tutti i problemi di connessione.
const String _networkMessage =
    'Impossibile contattare il server. Controlla che sia avviato e che l\'indirizzo sia corretto.';

class ApiClient {
  final http.Client _client = http.Client(); // un solo client HTTP per tutta l'app

  String? token; // token dell'azienda loggata (null = candidato/ospite)

  void Function()? onUnauthorized; // funzione chiamata se il server risponde 401 (sessione scaduta)

  // Scorciatoie per i metodi HTTP che usiamo.
  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  // Esegue una richiesta e restituisce il JSON della risposta già decodificato.
  Future<dynamic> _send(String method, String path, {Object? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path'); // es. http://10.0.2.2:8080/api/annunci
    final req = http.Request(method, uri); // prepara la richiesta
    req.headers['Accept'] = 'application/json'; // "voglio una risposta JSON"
    if (token != null) req.headers['Authorization'] = 'Bearer $token'; // se loggati, alleghiamo il token
    if (body != null) {
      req.headers['Content-Type'] = 'application/json; charset=utf-8'; // "ti mando JSON"
      req.body = jsonEncode(body); // Map Dart -> testo JSON
    }
    final res = await _sendRaw(req); // invio vero e proprio (con gestione errori di rete)

    dynamic data; // qui mettiamo il JSON decodificato
    final text = utf8.decode(res.bodyBytes, allowMalformed: true); // byte -> testo (con accenti corretti)
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text); // testo JSON -> Map o List
      } catch (_) {
        data = null; // risposta non JSON: la ignoriamo
      }
    }
    _throwIfError(res.statusCode, data); // se il codice è >= 400 lancia ApiException
    return data;
  }

  // Scarica un file (es. il CV in PDF) e ne restituisce i byte.
  Future<List<int>> getBytes(String path) async {
    final req = http.Request('GET', Uri.parse('${ApiConfig.baseUrl}$path'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token'; // il CV è riservato: serve il token
    final res = await _sendRaw(req);
    if (res.statusCode >= 400) {
      dynamic data; // in caso di errore il server risponde comunque in JSON
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {}
      _throwIfError(res.statusCode, data);
    }
    return res.bodyBytes; // i byte del file
  }

  // Invia la richiesta trasformando i problemi di rete in ApiException(0, ...).
  Future<http.Response> _sendRaw(http.Request req) async {
    try {
      final streamed = await _client.send(req).timeout(ApiConfig.timeout); // invia e aspetta (max 10 s)
      return await http.Response.fromStream(streamed).timeout(ApiConfig.timeout); // legge tutta la risposta
    } on TimeoutException {
      throw const ApiException(0, _networkMessage); // il server non ha risposto in tempo
    } on SocketException {
      throw const ApiException(0, _networkMessage); // server irraggiungibile
    } on http.ClientException {
      throw const ApiException(0, _networkMessage); // altro errore di connessione
    }
  }

  // Se la risposta è un errore, lancia ApiException con il messaggio {"error": ...} del server.
  void _throwIfError(int status, dynamic data) {
    if (status < 400) return; // 2xx: tutto ok
    var msg = 'Errore del server ($status)'; // messaggio generico di riserva
    if (data is Map && data['error'] is String) {
      msg = data['error'] as String; // messaggio preciso scritto dal nostro server
    }
    if (status == 401 && token != null) onUnauthorized?.call(); // eravamo loggati ma il token non vale più
    throw ApiException(status, msg);
  }
}