/*
 * comment
 */
// comment

%lex
name .
%%
{name} return yytext;
%%
console.log('hello, world');
/lex

%{
  // prologue
  function(){return;}
%}%include include.js // comment

%include include.js

%code/**/init %include 'include.js'//comment
%code required %include "include.js"
%code 'init' {{ return; }}
%code 'required' { return; }
%code "init" %{ return; %}
%code "required" -> return;//comment
%code requires %include include.js

%token TOKEN //comment

%unrecognized

%start start

%%

%{ function(){return;} %}
{{ function(){return;} }}

%include include.js

start: expression;

expression
  : TOKEN { $$ = [$1]; }
  | expression '+'[add] expression %{ $$ = `${@add.first_line}`; %}
  | '-' expression %prec UMINUS { yysp; }
  | "(" expression ")" %include include.js //comment
  | error -> yyclearin;yyerrok;//comment
  ;

empty1: /* empty */ { $$ = []; } | %empty { $$ = []; } | %epsilon { $$ = []; };
empty2: ε { $$ = []; } | Ɛ { $$ = []; } | ɛ { $$ = []; } | ϵ { $$ = []; };

%%

%include 'include.js'
console.log('hello, world');