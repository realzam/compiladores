import 'dart:io';
import 'dart:math';

enum Estado_tipo { inicial, fin, normal }

class Transicion {
  int _inicio;
  int _fin;
  String _simbolo;
  Transicion(int inicio, int fin, String simbolo) {
    this._inicio = inicio;
    this._fin = fin;
    this._simbolo = simbolo;
  }
  String get simbolo => this._simbolo;
  int get fin => this._fin;
  int get inicio => this._inicio;

  @override
  String toString() => '$_inicio->$_fin,$_simbolo';
}

class Estado {
  int etiqueta;
  Estado_tipo estado_tipo;
  Estado(this.etiqueta, {this.estado_tipo = Estado_tipo.normal});
  List<Transicion> tranciones = List();
  void agregar_Transicion(int estado, String simbolo) {
    Transicion tran = Transicion(etiqueta, estado, simbolo);
    tranciones.add(tran);
  }

  bool determinista() {
    List<String> auxSimbolos = List();
    for (var i = 0; i < tranciones.length; i++) {
      String s = tranciones[i].simbolo;
      if (auxSimbolos.contains(s))
        return false;
      else
        auxSimbolos.add(s);
    }
    return true;
  }

  bool eliminar_transicion(int estado, String simbolo) {
    for (var i = 0; i < tranciones.length; i++) {
      Transicion aux = tranciones[i];
      if (aux.fin == estado && aux.simbolo == simbolo) {
        tranciones.removeAt(i);
        return true;
      }
    }
    return false;
  }
}

class _AF {
  List<Estado> _estados = List();
  int _edoInicial;
  List<int> _edosFinal = List();

  void cargar_desde(String nombre) {
    RegExp estadoRegexr = RegExp(r"^[1-9][0-9]*->[1-9][0-9]*,([a-z]|E)$");
    String ext = nombre.substring(nombre.lastIndexOf('.'));
    int inicio;
    if (ext != '.af')
      throw Exception('La extensión del archivo ($ext) no es valido');
    final file = File(nombre);
    List<String> contenido = file.readAsLinesSync();

    if (!contenido[0].trim().startsWith('inicial:') ||
        !contenido[1].trim().startsWith('finales:'))
      throw Exception('Formato del archivo no valido');

    try {
      inicio = int.parse(contenido[0].trim().split(':')[1]);
      _edoInicial = inicio;
      Estado inicial = Estado(inicio, estado_tipo: Estado_tipo.inicial);
      _estados.add(inicial);

      String tempFinal = contenido[1].trim().split(':')[1];
      List<String> tempFinales = tempFinal.split(',');
      tempFinales.forEach((element) {
        int auxfin = int.parse(element);
        _edosFinal.add(auxfin);
        Estado finalE = Estado(auxfin, estado_tipo: Estado_tipo.fin);
        _estados.add(finalE);
      });
    } catch (e) {
      throw Exception('Formato del archivo no valido');
    }

    for (var i = 2; i < contenido.length; i++) {
      String linea = contenido[i];
      if (linea == '') continue;
      if (!estadoRegexr.hasMatch(linea.trim())) {
        throw Exception('Formato del archivo no valido');
      }
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      int index = _buscarEstado(estadoAux);
      if (index == -1) {
        Estado estadoAdd = Estado(estadoAux);
        estadoAdd.agregar_Transicion(estadoAux2, simboloAux);
        _estados.add(estadoAdd);
      } else {
        _estados[index].agregar_Transicion(estadoAux2, simboloAux);
      }
    }
    _validarAutomata();
  }

  void guardar_en(String nombre) {
    _validarAutomata();
    List<String> contenido = List();
    contenido.add('inicial:$_edoInicial');
    contenido.add('finales:' + _edosFinal.join(','));
    List<Transicion> auxTran = List();
    for (var estado in _estados) {
      for (var transicion in estado.tranciones) {
        auxTran.add(transicion);
      }
    }
    auxTran.sort((a, b) {
      int inicial = a._inicio.compareTo(b._inicio);
      if (inicial == 0) {
        int fin = a._fin.compareTo(b._fin);
        if (fin == 0) {
          return a._simbolo.compareTo(b._simbolo);
        } else
          return fin;
      } else
        return inicial;
    });
    for (var s in auxTran) {
      contenido.add(s.toString());
    }
    File(nombre).writeAsStringSync(contenido.join('\n'));
  }

  void agregar_transicion(int inicio, int fin, String simbolo) {
    int index = _buscarEstado(fin);
    if (index == -1) {
      Estado estadoAdd = Estado(fin);
      _estados.add(estadoAdd);
    }
    index = _buscarEstado(inicio);
    if (index == -1) {
      Estado estadoAdd = Estado(inicio);
      estadoAdd.agregar_Transicion(fin, simbolo);
      _estados.add(estadoAdd);
    } else {
      _estados[index].agregar_Transicion(fin, simbolo);
    }
  }

  void eliminar_transicion(int inicio, int fin, String simbolo) {
    int index = _buscarEstado(inicio);

    if (index == -1) {
      throw Exception('El estado $inicio no existe en el autómata');
    } else {
      bool res = _estados[index].eliminar_transicion(fin, simbolo);

      if (_estados[index].tranciones.isEmpty) {
        if (_edosFinal.contains(_estados[index].etiqueta) &&
            _edosFinal.length != 1) _edosFinal.remove(_estados[index].etiqueta);
        if (_edoInicial != _estados[index].etiqueta) _estados.removeAt(index);
      }
      int index2 = _buscarEstado(fin);
      if (_estados[index2].tranciones.isEmpty) {
        if (_edosFinal.contains(_estados[index2].etiqueta) &&
            _edosFinal.length != 1)
          _edosFinal.remove(_estados[index2].etiqueta);
        if (_edoInicial != _estados[index2].etiqueta) _estados.removeAt(index);
      }
      if (!res)
        throw Exception(
            'No existe una transición a $fin usando el símbolo "$simbolo"  desde el estado $inicio en el autómata');
    }
  }

  int obtener_inicial() => _edoInicial;

  List<int> obtener_finales() => _edosFinal;

  void establecer_inicial(int estado) {
    if (estado == _edosFinal)
      throw Exception('El estado inicial no puede ser igual al estado final');
    _edoInicial = estado;
  }

  void establecer_final(int estado) {
    if (estado == _edoInicial)
      throw Exception('El estado final no puede ser igual al estado inicial');
    if (!_edosFinal.contains(estado)) _edosFinal.add(estado);
  }

  bool esAFN() => !esAFD();

  bool esAFD() {
    for (var i = 0; i < _estados.length; i++) {
      if (!_estados[i].determinista()) return false;
    }
    return true;
  }

  bool acepta(String cadena) {
    int index = _buscarEstado(_edoInicial);
    return _acepta(cadena, _estados[index]);
  }

  String generar_cadena() {
    int intentos = 70;
    int index = _buscarEstado(_edoInicial);
    String res;
    do {
      res = _generar_letra("", _estados[index]);
      intentos--;
    } while (res == null && intentos > 0);
    if (res == null)
      throw Exception(
          'No es posible generar una cadena con el autómata. Autómata no puede llegar al estado final desde el estado inicial');
    return res;
  }

// Metodos auxiliares

  bool _avanzar(Estado estado) {
    if (estado.tranciones.isEmpty && estado.estado_tipo != Estado_tipo.fin) {
      return false;
    }
    for (Transicion trans in estado.tranciones) {
      if (trans._fin != estado.etiqueta) return true;
    }
    return false;
  }

  Transicion _radomTransicion(Estado estado) {
    var rng = Random();
    int random = rng.nextInt(estado.tranciones.length);
    return estado.tranciones[random];
  }

  String _generar_letra(String cadena, Estado estado) {
    if (!_avanzar(estado)) return null;
    Transicion trancision = _radomTransicion(estado);
    String cadenaNew = cadena;
    if (trancision.simbolo != 'E') {
      cadenaNew += trancision.simbolo;
    }

    if (_edosFinal.contains(trancision.fin)) return cadenaNew;
    int index = _buscarEstado(trancision.fin);
    if (index == -1) return null;
    return _generar_letra(cadenaNew, _estados[index]);
  }

  bool _acepta(String cadena, Estado estado) {
    if (!_avanzar(estado)) return false;
    for (Transicion transicion in estado.tranciones) {
      if (transicion.simbolo == cadena[0] || transicion.simbolo == 'E') {
        int index = _buscarEstado(transicion.fin);
        if (index == -1) return false;
        Estado edoAux = _estados[index];
        String cadenaAux = '';
        if (edoAux.estado_tipo == Estado_tipo.fin && cadena.length == 1)
          return true;
        if (transicion.simbolo == cadena[0]) {
          if (cadena.length == 1)
            cadenaAux = 'E';
          else
            cadenaAux = cadena.substring(1);
        } else
          cadenaAux = cadena;

        if (_acepta(cadenaAux, edoAux)) return true;
      }
    }
    return false;
  }

  int _buscarEstado(int etiqueta) {
    for (var i = 0; i < _estados.length; i++) {
      if (_estados[i].etiqueta == etiqueta) return i;
    }
    return -1;
  }

  void _validarAutomata() {
    bool valido = false;
    for (var estado in _estados) {
      for (var trancision in estado.tranciones) {
        if (_edosFinal.contains(trancision.fin)) {
          valido = true;
          break;
        }
      }
      if (valido) break;
    }
    if (!valido)
      throw Exception(
          'Autómata no valido. No hay transición hacia el estado final');

    valido = false;
    for (var estado in _estados) {
      for (var trancision in estado.tranciones) {
        if (_edoInicial == trancision._inicio) {
          valido = true;
          break;
        }
      }
      if (valido) break;
    }
    if (!valido)
      throw Exception(
          'Autómata no valido.EL estado inicial no tiene transiciones hacia otros estados');
    try {
      generar_cadena();
    } catch (e) {
      throw Exception(
          'El Autómata no puede llegar al estado final desde el estado inicial');
    }
  }

  @override
  String toString() {
    _validarAutomata();
    List<String> contenido = List();
    contenido.add('inicial:$_edoInicial');
    contenido.add('finales:' + _edosFinal.join(','));
    List<Transicion> auxTran = List();
    for (var estado in _estados) {
      for (var transicion in estado.tranciones) {
        auxTran.add(transicion);
      }
    }
    auxTran.sort((a, b) {
      int inicial = a._inicio.compareTo(b._inicio);
      if (inicial == 0) {
        int fin = a._fin.compareTo(b._fin);
        if (fin == 0) {
          return a._simbolo.compareTo(b._simbolo);
        } else
          return fin;
      } else
        return inicial;
    });
    for (var s in auxTran) {
      contenido.add(s.toString());
    }
    return contenido.join('\n');
  }
}

class AFD extends _AF {}

class AFN extends _AF {}
