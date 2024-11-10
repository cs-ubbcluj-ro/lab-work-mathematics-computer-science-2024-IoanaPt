%option debug

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *token;
    int position;
} PIFEntry;

typedef struct {
    char *symbol;
    int position;
} SymbolTableEntry;

FILE *pif_file, *st_file, *error_file;
int line_number = 1;

int lookup_symbol_table(char *symbol);
void insert_into_symbol_table(char *symbol);
void add_to_pif(char *token, int position);

int symbol_table_position = 0;
%}

DIGIT            [0-9]
LETTER           [a-zA-Z]
IDENTIFIER       {LETTER}({LETTER}|{DIGIT})*
NUMBER           {DIGIT}+(\.{DIGIT}+)?  
STRING_LITERAL   \"([^\"\n]*)\"       

%%

[ \t\r\n]+  

\n               { line_number++; }

"START"          { add_to_pif("START", -1); }
"STOP"           { add_to_pif("STOP", -1); }
"DECLARE"        { add_to_pif("DECLARE", -1); }
"INPUT"          { add_to_pif("INPUT", -1); }
"OUTPUT"         { add_to_pif("OUTPUT", -1); }
"IF"             { add_to_pif("IF", -1); }
"THEN"           { add_to_pif("THEN", -1); }
"ENDIF"          { add_to_pif("ENDIF", -1); }
"ELSE"           { add_to_pif("ELSE", -1); }
"FOR"            { add_to_pif("FOR", -1); }
"TO"             { add_to_pif("TO", -1); }
"DO"             { add_to_pif("DO", -1); }
"ENDFOR"         { add_to_pif("ENDFOR", -1); }
"const"          { add_to_pif("const", -1); }
"struct"         { add_to_pif("struct", -1); }

"+"              { add_to_pif("+", -1); }
"-"              { add_to_pif("-", -1); }
"*"              { add_to_pif("*", -1); }
"/"              { add_to_pif("/", -1); }
"="              { add_to_pif("=", -1); }
">"              { add_to_pif(">", -1); }
"<"              { add_to_pif("<", -1); }
">="             { add_to_pif(">=", -1); }
"<="             { add_to_pif("<=", -1); }
"=="             { add_to_pif("==", -1); }
"!="             { add_to_pif("!=", -1); }
"AND"            { add_to_pif("AND", -1); }
"OR"             { add_to_pif("OR", -1); }
","              { add_to_pif(",", -1); }
";"              { add_to_pif(";", -1); }
"%"              { add_to_pif("%", -1); } 
"{"              { add_to_pif("{", -1); }
"#"              { add_to_pif("#", -1); }
"}"              { add_to_pif("}", -1); }
"_"              { add_to_pif("_", -1); }
"("              { add_to_pif("(", -1); }
")"              { add_to_pif(")", -1); }
"["              { add_to_pif("[", -1); }
"]"              { add_to_pif("]", -1); }
"\\"             { add_to_pif("\\", -1); }
"?"              { add_to_pif("?", -1); }
"!"              { add_to_pif("!", -1); }
"\""            { add_to_pif("\"", -1); }
"|"              { add_to_pif("|", -1); }
"."              { add_to_pif(".", -1); }



{IDENTIFIER}     {
                    int pos = lookup_symbol_table(yytext);
                    if (pos == -1) {
                        insert_into_symbol_table(yytext);
                        pos = symbol_table_position++;
                    }
                    add_to_pif("ID", pos);
                }

{NUMBER}         {
                    int pos = lookup_symbol_table(yytext);
                    if (pos == -1) {
                        insert_into_symbol_table(yytext);
                        pos = symbol_table_position++;
                    }
                    add_to_pif("CONST", pos);
                }

{STRING_LITERAL} {
                    int pos = lookup_symbol_table(yytext);
                    if (pos == -1) {
                        insert_into_symbol_table(yytext);
                        pos = symbol_table_position++;
                    }
                    add_to_pif("STRING_LITERAL", pos);
                }

.               { fprintf(error_file, "Le error at line %d: Unknown token %s\n", line_number, yytext); }

%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <source_file>\n", argv[0]);
        exit(1);
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: Could not open file %s\n", argv[1]);
        exit(1);
    }

    pif_file = fopen("PIF.txt", "w");
    st_file = fopen("SymbolTable.txt", "w");
    error_file = fopen("LexicalErrors.txt", "w");

    yylex();

    fclose(yyin);
    fclose(pif_file);
    fclose(st_file);
    fclose(error_file);

    return 0;
}

int lookup_symbol_table(char *symbol) {
    return -1;
}

void insert_into_symbol_table(char *symbol) {
    fprintf(st_file, "%s %d\n", symbol, symbol_table_position);
}

void add_to_pif(char *token, int position) {
    fprintf(pif_file, "%s %d\n", token, position);
}
