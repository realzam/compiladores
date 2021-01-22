import 'dart:collection';
import 'AF.dart';

class Thomson {
  final RegExp _regexSimbolo = RegExp(r'^([a-z]|E)$');
  final List<String> _opeadoresList = ['(', ')', '*', '+', '|'];

  AFN convertir(String regex) {
    if (!_validarRegex(regex))
      throw Exception('La expresion regular básica:$regex no es válida');
    String regex_concat = _agregarConcatenacion(regex);
    String postfijo = _postfijo(regex_concat);
    ListQueue<AFN> pilaResultado = ListQueue();
    for (var i = 0; i < postfijo.length; i++) {
      String caracter = postfijo[i];
      if (_regexSimbolo.hasMatch(caracter))
        pilaResultado.addLast(_plantilla_base(caracter));
      else {
        switch (caracter) {
          case '.':
            try {
              AFN izq = pilaResultado.removeLast();
              AFN der = pilaResultado.removeLast();
              pilaResultado.addLast(_plantilla_concatenar(der, izq));
            } catch (e) {
              throw Exception(
                  'La expresion regular básica:$regex no es válida');
            }
            break;
          case '*':
            try {
              AFN s = pilaResultado.removeLast();
              pilaResultado.addLast(_plantilla_estrella(s));
            } catch (e) {
              throw Exception(
                  'La expresion regular básica:$regex no es válida');
            }
            break;
          case '|':
            try {
              AFN izq = pilaResultado.removeLast();
              AFN der = pilaResultado.removeLast();
              pilaResultado.addLast(_plantilla_or(der, izq));
            } catch (e) {
              throw Exception(
                  'La expresion regular básica:$regex no es válida');
            }
            break;
          case '+':
            try {
              AFN s = pilaResultado.removeLast();
              AFN estrella = _plantilla_estrella(s);
              pilaResultado.addLast(_plantilla_concatenar(s, estrella));
            } catch (e) {
              throw Exception(
                  'La expresion regular básica:$regex no es válida');
            }
            break;
        }
      }
    }
    return _renombrarEstadosOrdenado(pilaResultado.last);
  }

  bool _validarRegex(String regex) {
    if (regex.length <= 1001) {
      int parentesis = 0;
      for (var i = 0; i < regex.length; i++) {
        String caracter = regex[i];
        if (caracter == '(')
          parentesis++;
        else if (caracter == ')') parentesis--;
        if (parentesis < 0) return false;
        if (!_regexSimbolo.hasMatch(caracter) &&
            caracter != 'E' &&
            !_opeadoresList.contains(caracter)) return false;
      }
      if (parentesis != 0) return false;
      return true;
    }
    return false;
  }

  String _agregarConcatenacion(String regex) {
    String res = "";
    String lastcaracter = "";
    for (var i = 0; i < regex.length; i++) {
      String caracter = regex[i];
      if (_regexSimbolo.hasMatch(caracter) &&
          (_regexSimbolo.hasMatch(lastcaracter) ||
              lastcaracter == '*' ||
              lastcaracter == '+' ||
              lastcaracter == ')')) {
        res += '.';
        lastcaracter = '.';
        i--;
      } else if (caracter == '(' &&
          (_regexSimbolo.hasMatch(lastcaracter) ||
              lastcaracter == '*' ||
              lastcaracter == '+' ||
              lastcaracter == ')')) {
        res += '.';
        lastcaracter = '.';
        i--;
      } else {
        res += caracter;
        lastcaracter = caracter;
      }
    }
    return res;
  }

  String _postfijo(String infijo) {
    ListQueue<String> pilaOperadores = ListQueue();
    Map<String, int> precedencia = {
      '(': 0,
      ")": 0,
      "|": 1,
      ".": 2,
      "*": 3,
      "+": 3
    };
    infijo = _agregarConcatenacion(infijo);
    String res = "";
    for (var i = 0; i < infijo.length; i++) {
      String caracter = infijo[i];
      if (_regexSimbolo.hasMatch(caracter)) {
        res += caracter;
      } else {
        if (pilaOperadores.isEmpty)
          pilaOperadores.addLast(caracter);
        else {
          if (caracter == '(') {
            pilaOperadores.addLast(caracter);
            continue;
          }
          if (caracter == ')') {
            String caracterTope = pilaOperadores.last;
            while (caracterTope != '(' && !pilaOperadores.isEmpty) {
              res += pilaOperadores.removeLast();
              if (!pilaOperadores.isEmpty) caracterTope = pilaOperadores.last;
            }
            pilaOperadores.removeLast();
            continue;
          }
          int topePresedincia = precedencia[pilaOperadores.last];
          int caracterPresedincia = precedencia[caracter];
          if (topePresedincia < caracterPresedincia)
            pilaOperadores.addLast(caracter);
          else {
            do {
              res += pilaOperadores.removeLast();
              if (!pilaOperadores.isEmpty)
                topePresedincia = precedencia[pilaOperadores.last];
            } while (topePresedincia >= caracterPresedincia &&
                !pilaOperadores.isEmpty);
            pilaOperadores.addLast(caracter);
          }
        }
      }
    }
    while (!pilaOperadores.isEmpty) {
      res += pilaOperadores.removeLast();
    }
    return res;
  }

  AFN _renombrarEstadosOrdenado(AFN s) {
    AFN r = AFN();
    List<String> s_contenido = s.toString().split('\n');
    List<int> estados = List();
    Map<int, int> estadosMap = Map();
    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      if (!estados.contains(estadoAux)) estados.add(estadoAux);
      if (!estados.contains(estadoAux2)) estados.add(estadoAux2);
    }
    estados.sort((a, b) => a.compareTo(b));
    for (var i = 0; i < estados.length; i++) {
      estadosMap[estados[i]] = i + 1;
    }

    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      r.agregar_transicion(
          estadosMap[estadoAux], estadosMap[estadoAux2], simboloAux);
    }
    r.establecer_inicial(estadosMap[s.obtener_inicial()]);
    r.establecer_final(estadosMap[s.obtener_finales()[0]]);
    return r;
  }

  AFN _renombrarEstadosDate(AFN s) {
    AFN r = AFN();
    List<String> s_contenido = s.toString().split('\n');
    Map<int, int> estadosMap = Map();
    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      if (!estadosMap.containsKey(estadoAux))
        estadosMap[estadoAux] = new DateTime.now().microsecondsSinceEpoch;
      if (!estadosMap.containsKey(estadoAux2))
        estadosMap[estadoAux2] = new DateTime.now().microsecondsSinceEpoch;

      r.agregar_transicion(
          estadosMap[estadoAux], estadosMap[estadoAux2], simboloAux);
    }
    r.establecer_inicial(estadosMap[s.obtener_inicial()]);
    r.establecer_final(estadosMap[s.obtener_finales()[0]]);
    return r;
  }

//====== platillas ======
  AFN _plantilla_base(String simbolo) {
    AFN resultado = AFN();
    int a = new DateTime.now().microsecondsSinceEpoch;
    int b = new DateTime.now().microsecondsSinceEpoch + 10;
    resultado.agregar_transicion(a, b, simbolo);
    resultado.establecer_inicial(a);
    resultado.establecer_final(b);
    return resultado;
  }

  AFN _plantilla_concatenar(AFN s, AFN t) {
    AFN r = AFN();
    s = _renombrarEstadosDate(s);
    t = _renombrarEstadosDate(t);
    List<String> t_contenido = t.toString().split('\n');
    List<String> s_contenido = s.toString().split('\n');

    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      r.agregar_transicion(estadoAux, estadoAux2, simboloAux);
    }
    int fintemp = s.obtener_finales()[0];

    for (var i = 2; i < t_contenido.length; i++) {
      String linea = t_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      if (t.obtener_inicial() == estadoAux) {
        r.agregar_transicion(fintemp, estadoAux2, simboloAux);
      } else {
        r.agregar_transicion(estadoAux, estadoAux2, simboloAux);
      }
      r.establecer_inicial(s.obtener_inicial());
      r.establecer_final(t.obtener_finales()[0]);
    }
    return r;
  }

  AFN _plantilla_or(AFN s, AFN t) {
    AFN r = AFN();
    r.establecer_inicial(new DateTime.now().microsecondsSinceEpoch);
    s = _renombrarEstadosDate(s);
    t = _renombrarEstadosDate(t);
    r.establecer_final(new DateTime.now().microsecondsSinceEpoch);
    r.agregar_transicion(r.obtener_inicial(), s.obtener_inicial(), 'E');
    r.agregar_transicion(r.obtener_inicial(), t.obtener_inicial(), 'E');
    List<String> t_contenido = t.toString().split('\n');
    List<String> s_contenido = s.toString().split('\n');
    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      r.agregar_transicion(estadoAux, estadoAux2, simboloAux);
    }

    for (var i = 2; i < t_contenido.length; i++) {
      String linea = t_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      r.agregar_transicion(estadoAux, estadoAux2, simboloAux);
    }

    r.agregar_transicion(s.obtener_finales()[0], r.obtener_finales()[0], 'E');
    r.agregar_transicion(t.obtener_finales()[0], r.obtener_finales()[0], 'E');
    return r;
  }

  AFN _plantilla_estrella(AFN s) {
    AFN r = AFN();
    r.establecer_inicial(new DateTime.now().microsecondsSinceEpoch);
    s = _renombrarEstadosDate(s);
    r.establecer_final(new DateTime.now().microsecondsSinceEpoch);
    r.agregar_transicion(r.obtener_inicial(), s.obtener_inicial(), 'E');
    r.agregar_transicion(r.obtener_inicial(), r.obtener_finales()[0], 'E');
    List<String> s_contenido = s.toString().split('\n');
    for (var i = 2; i < s_contenido.length; i++) {
      String linea = s_contenido[i];
      int estadoAux = int.parse(linea.substring(0, linea.indexOf('->')));
      int estadoAux2 = int.parse(
          linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
      String simboloAux = linea.substring(linea.indexOf(',') + 1);
      r.agregar_transicion(estadoAux, estadoAux2, simboloAux);
    }
    r.agregar_transicion(s.obtener_finales()[0], r.obtener_finales()[0], 'E');
    r.agregar_transicion(s.obtener_finales()[0], s.obtener_inicial(), 'E');
    return r;
  }
}
