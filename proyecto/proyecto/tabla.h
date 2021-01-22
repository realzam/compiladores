#include<stdlib.h>

typedef struct Color
{
    unsigned char r;
    unsigned char g;    
    unsigned char b;
}Color;

typedef struct Posicion
{
    int x;
    int y;    
}Posicion;


typedef struct Figura
{
    Color contorno;
    char tipo [50];
    char nombre [100];
    int dimensiones[4];
    Posicion posicion;
    Color relleno;
    int esRellenado;
    int rotacion;
}Figura;



typedef struct Nodo
{
    Figura figura;
    struct Nodo* siguiente;
    
}Nodo;

typedef struct Lista{
    Nodo *cabeza;
    int longitud;
}Lista;

Nodo *crearNodo(Figura *figura); 
void insertar(Lista *lista,Figura *figura);
Figura *buscar(Lista *lista, char *nombre);

