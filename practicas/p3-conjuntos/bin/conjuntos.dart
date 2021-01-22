import 'dart:collection';
import 'package:conjuntos/conjuntos.dart';
import 'package:conjuntos/thomson.dart';

void main(List<String> arguments) {
  Thomson a = Thomson();
  AFN b = AFN();
  b = a.convertir('aba*|b(ab)*');
  print(b.toString());
  AFD res = subconjuntos(b);
  print(res.toString());
}

/**
 * Transforma un autómata finito no determinista a un autómata finito determinista 
 */
AFD subconjuntos(AFN afn_entrada) {
  AFD afd_resultado = AFD();
  List<Estado> estados = cargar_estados(afn_entrada);
  List<String> simbolos = cargar_simbolos(estados);
  Estado estado_inicial = estados
      .firstWhere((estado) => estado.etiqueta == afn_entrada.obtener_inicial());
  List<Estado> inicial = e_cerradura_T([estado_inicial], estados);
  SubconjuntoEstados inicio =
      SubconjuntoEstados(inicial, inicial: true, etiqueta: 1);
  List<SubconjuntoEstados> destados = [inicio];
  afd_resultado.establecer_inicial(1);
  List<Transicion> dtran = List(); //trancisiones del autómata final

  while (!destados.every((subconjunto) => subconjunto.marcar == true)) {
    SubconjuntoEstados t =
        destados.firstWhere((subconjunto) => subconjunto.marcar == false);
    t.marcar = true;
    for (String simbolo in simbolos) {
      List<Estado> mover_edos = mover(t.estados, simbolo, estados);
      if (mover_edos.length > 0) {
        //si la tansicion no lleva al estado vacio (pozo)
        SubconjuntoEstados u =
            SubconjuntoEstados(e_cerradura_T(mover_edos, estados));
        bool contiene = false;
        for (SubconjuntoEstados subconjunto in destados) {
          //revisa si el nuevo subcojunto u ya esta en destados
          if (subcojuntos_edos_equals(subconjunto, u)) {
            u.etiqueta = subconjunto.etiqueta;
            contiene = true;
            break;
          }
        }
        if (!contiene) {
          //si el nuevo subcojunto u no esta en destados entoces se le define una etiquete si se revisa si es final
          u.etiqueta = destados.length + 1;
          for (int estado_etiqueta in u.estadosList) {
            if (afn_entrada.obtener_finales().contains(estado_etiqueta)) {
              u.fin = true;
              break;
            }
          }
          destados.add(u);
        }
        Transicion agregar_trensicion =
            Transicion(t.etiqueta, u.etiqueta, simbolo);
        dtran.add(agregar_trensicion);
      }
    }
  }

  for (Transicion transicion in dtran) {
    afd_resultado.agregar_transicion(
        transicion.inicio, transicion.fin, transicion.simbolo);
  }
  for (SubconjuntoEstados subconjunto in destados) {
    if (subconjunto.fin) afd_resultado.establecer_final(subconjunto.etiqueta);
  }
  return afd_resultado;
}

/**
 * Regresa `true` si dos subcojutos tienen los mismos estados
 * 
 * Esta operacion revisa unicamente los estados
 */
bool subcojuntos_edos_equals(SubconjuntoEstados a, SubconjuntoEstados b) {
  return (a.toString() != b.toString()) ? false : true;
}

/**
 * Regresa una lista de simbolos que utilizan los estados para
 * hacer una transición 
 */
List<String> cargar_simbolos(List<Estado> estados) {
  List<String> simbolos = List();
  for (Estado estado in estados) {
    for (Transicion transicion in estado.tranciones) {
      if (!simbolos.contains(transicion.simbolo) && transicion.simbolo != 'E')
        simbolos.add(transicion.simbolo);
    }
  }
  return simbolos;
}

/**
 * Regresa una lista de Estado que tiene un autómata
 */
List<Estado> cargar_estados(AFN afn) {
  List<String> contenido = afn.toString().split('\n');
  List<Estado> estados = List();
  for (var i = 2; i < contenido.length; i++) {
    String linea = contenido[i];
    int estado_inicial = int.parse(linea.substring(0, linea.indexOf('->')));
    int estado_final =
        int.parse(linea.substring(linea.indexOf('->') + 2, linea.indexOf(',')));
    String simbolo = linea.substring(linea.indexOf(',') + 1);
    int index_inicial = buscarEstado(estados, estado_inicial);
    int index_final = buscarEstado(estados, estado_final);
    if (index_final == -1) estados.add(Estado(estado_final));
    Estado agregar;
    if (index_inicial == -1)
      agregar = Estado(estado_inicial);
    else
      agregar = estados[index_inicial];
    agregar.agregar_Transicion(estado_final, simbolo);
    estados.add(agregar);
  }
  return estados;
}

/**
 * Regresa el indice del estado 
 * 
 * Esta operacion busca un estado apartir de su etiqueta dentro de una lista de estados
 * 
 * Regresa -1 si el Estado no se encontro
 */
int buscarEstado(List<Estado> estados, int etiqueta) =>
    estados.lastIndexWhere((estado) => estado.etiqueta == etiqueta);

/**
*Regresa una lista de estados a los que se puede llegar desde cierto
*conjunto de estdos T,sólo en las transiciones e
*/
List<Estado> e_cerradura_T(List<Estado> t, List<Estado> afn_edos) {
  ListQueue<Estado> pila = ListQueue();
  List<Estado> cerradura = List();
  pila.addAll(t);
  while (pila.isNotEmpty) {
    Estado top = pila.removeLast();
    cerradura.add(top);
    for (Transicion transicion in top.tranciones) {
      if (transicion.simbolo == 'E') {
        Estado agregar_pila = afn_edos[buscarEstado(afn_edos, transicion.fin)];
        if (!cerradura.contains(agregar_pila)) pila.addLast(agregar_pila);
      }
    }
  }
  return cerradura;
}

/**
 *Regresa una lista de estados para los cuales hay una transición sobre el
símbolo de entrada a, a partir de cierto estado s en T.
 */
List<Estado> mover(List<Estado> t, String a, List<Estado> afn_edos) {
  List<Estado> estados_mover = List();
  for (Estado estado in t) {
    for (var i = 0; i < estado.tranciones.length; i++) {
      if (estado.tranciones[i].simbolo == a) {
        int estado_agregar_etiqueta = estado.tranciones[i].fin;
        Estado estado_agregar = afn_edos
            .firstWhere((estado) => estado.etiqueta == estado_agregar_etiqueta);
        if (!estados_mover.contains(estado_agregar))
          estados_mover.add(estado_agregar);
        break;
      }
    }
  }
  return estados_mover;
}

/**
 * Define un subcojuto de estados 
 * */
class SubconjuntoEstados {
  int etiqueta;
  List<Estado> estados;
  bool marcar = false;
  bool inicial;
  bool fin;
  SubconjuntoEstados(List<Estado> estados,
      {this.inicial = false, this.fin = false, this.etiqueta}) {
    estados.sort((a, b) => a.etiqueta.compareTo(b.etiqueta));
    this.estados = estados;
  }
  List<int> get estadosList {
    List<int> edos = List();
    for (var edo in estados) {
      edos.add(edo.etiqueta);
    }
    return edos;
  }

  @override
  String toString() {
    String res = '{${estados[0].etiqueta}';
    for (var i = 1; i < estados.length; i++) {
      res += ',${estados[i].etiqueta}';
    }
    return res += '}';
  }
}
