{{flutter_js}}
{{flutter_build_config}}

// El panel administrativo cambia con frecuencia durante la fase piloto.
// Cargamos siempre los recursos publicados más recientes y evitamos que un
// service worker antiguo mantenga una interfaz obsoleta en el navegador.
_flutter.loader.load();
