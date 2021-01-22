#include "tabla.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

Nodo *crearNodo(Figura *figura)
{
    Nodo *nodo = (Nodo *)malloc(sizeof(Nodo));
    strcpy(nodo->figura.nombre, figura->nombre);
    strcpy(nodo->figura.tipo, figura->tipo);
    memcpy(nodo->figura.dimensiones, figura->dimensiones,sizeof(nodo->figura.dimensiones));
    nodo->figura.contorno = figura->contorno;
    nodo->figura.posicion = figura->posicion;
    nodo->figura.relleno = figura->relleno;
    nodo->figura.esRellenado = figura->esRellenado;
    nodo->figura.rotacion = figura->rotacion;
    nodo->siguiente = NULL;
    return nodo;
}

void insertar(Lista *lista, Figura *figura)
{
    Nodo *nodo = crearNodo(figura);
    nodo->siguiente = lista->cabeza;
    lista->cabeza = nodo;
    lista->longitud++;
}

Figura *buscar(Lista *lista, char *nombre)
{
    Nodo *aux = lista->cabeza;
    while (aux)
    {
        if (strcmp(aux->figura.nombre, nombre) == 0)
            return &aux->figura;
        aux = aux->siguiente;
    }
    return NULL;
}
