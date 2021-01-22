%{
    #include "tabla.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    int h=0, v= 0;
    Color fondo=(Color){0,0,0};
    extern Lista lista;
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;
    //Se define los prototipo de funciones
    int yylex(void); 
    void yyerror(char *mensaje){
        printf("ERROR %s\n",mensaje);
        exit(0);
    }
    void errorNoDeclarado(char *mensaje);
    void agregarFigura(char *tipo,char* id,int* dim);
%}

%union{
    char id[100];
    char tipo[100];
    int num;
}
%start line 
%token print 
%token TOK_Lienzo
%token TOK_Fondo
%token exit_command
%token <id> identifier
%token <tipo> Fig_Cuadrado Fig_Rectangulo Fig_Triangulo Fig_Circulo Fig_Linea
%token <num> number
%token OP_posicion OP_contorno OP_rotacion OP_relleno OP_mover
%%

line: declaracion ';'      
    | operacion ';'
    | info      ';'       
    | linezo ';'  
    | line declaracion ';'      
    | line operacion ';'
    | line info ';'
    | line linezo ';'      
    ;

info:print identifier {
        Figura *f = buscar(&lista, $2);
        if(f!=NULL)
        {
            printf("Color contorno r:%d, g:%d, b:%d \n", f->contorno.r, f->contorno.g, f->contorno.b);
            printf("Figura:%s \n", f->tipo);
            printf("Figura:%s \n", f->nombre);
            printf("Posicion: x%d,y%d \n", f->posicion.x, f->posicion.y);
            printf("Color relleno r:%d, g:%d, b:%d \n", f->contorno.r, f->contorno.g, f->contorno.b);
            printf("es rellenado:%d\n", f->esRellenado);
            printf("rotacion:%d \n", f->rotacion);
            printf("dimensiones:%d,%d,%d,%d \n", f->dimensiones[0],f->dimensiones[1],f->dimensiones[2],f->dimensiones[3]);
        }
    }
    ;

linezo: TOK_Lienzo number number    {h=$2;v=$3;}
        | TOK_Lienzo TOK_Fondo number number number {fondo=(Color){$3,$4,$5};}
    ;


declaracion: Fig_Cuadrado identifier number {int dim[4]={$3,0,0,0};agregarFigura($1,$2,dim);}  
            | Fig_Rectangulo identifier number number number number  {int dim[4]={$3,$4,0,0};agregarFigura($1,$2,dim);} 
            | Fig_Triangulo identifier number  {int dim[4]={$3,0,0,0};agregarFigura($1,$2,dim);} 
            | Fig_Circulo identifier number   {int dim[4]={$3,0,0,0};agregarFigura($1,$2,dim);} 
            | Fig_Linea identifier number number number number  {int dim[4]={$3,$4,$5,$6};agregarFigura($1,$2,dim);} 
            ;

operacion: identifier OP_posicion number number { 
                                                    Figura *buscado = buscar(&lista, $1);
                                                    if(buscado==NULL)                                                    
                                                     errorNoDeclarado($1);
                                                    else
                                                        buscado->posicion=(Posicion){$3,$4};
                                                } 
         |identifier OP_contorno number number number{ 
                                                    Figura *buscado = buscar(&lista, $1);
                                                    if(buscado==NULL)                                                    
                                                     errorNoDeclarado($1);
                                                    else
                                                        buscado->contorno=(Color){$3,$4,$5};
         }
         |identifier OP_rotacion number { 
                                                    Figura *buscado = buscar(&lista, $1);
                                                    if(buscado==NULL)                                                    
                                                     errorNoDeclarado($1);
                                                    else
                                                        buscado->rotacion=$3;
        }
        |identifier OP_relleno number number number{ 
                                                    Figura *buscado = buscar(&lista, $1);
                                                    if(buscado==NULL)                                                    
                                                     errorNoDeclarado($1);
                                                    else
                                                    {
                                                        buscado->relleno=(Color){$3,$4,$5};
                                                        buscado->esRellenado=1;
                                                    }
        }
        |identifier OP_mover number number{ 
                                                    Figura *buscado = buscar(&lista, $1);
                                                    if(buscado==NULL)                                                    
                                                        errorNoDeclarado($1);
                                                    else
                                                    {
                                                        buscado->posicion.x+=$3;
                                                        buscado->posicion.y+=$4;
                                                    }
        } 
        ;
%%
void agregarFigura(char *tipo,char* id,int* dim){
    Figura *buscado=buscar(&lista,id);

    //si no se encuentra -> Null
    printf("tipo de figura :%s  ",tipo);
    if(buscado == NULL)
    {
        Figura figura;
        strcpy(figura.nombre,id);
        strcpy(figura.tipo, tipo);
        memcpy(figura.dimensiones,dim,sizeof(figura.dimensiones));
        figura.contorno = (Color){255, 255, 255};
        figura.posicion = (Posicion){0, 0};
        figura.relleno = (Color){255, 255, 255};
        figura.esRellenado = 0;
        figura.rotacion = 0;
        insertar(&lista,&figura);
    }
    printf("se declaro %s como %s\n",tipo,id);
                                    
}

void errorNoDeclarado(char *id)
 {
    char* name_with_extension;
    name_with_extension = malloc(strlen(id)+1+22); 
    strcpy(name_with_extension, id); 
    strcat(name_with_extension," no ha sido declarado\n");
    yyerror(name_with_extension);
 }

int main(int argc, char ** argv){
    FILE* input = fopen(argv[1], "r");
    if (!input)
    {
        printf("Bad input. Nonexistant file\n"); 
        return -1;
    } 
    yyin = input;
    int res=yyparse();
    //printf("lienzo %dx%d\nColor: r%d,g:%d,b:%d",h,v,fondo.r,fondo.g,fondo.b);
    //printf("resultado %d\n",res);
    //printf("lista: %d\n",lista.longitud);
    return 0;
}
