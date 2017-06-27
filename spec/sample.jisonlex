/*
 * comment
 */
// comment

name1 ^[+*?/!/\]{/*not a comment*///not a comment][^set].$<<EOF>>
x     "y"
name2 [{x}]*/{x}?|/!{x}+|(?:\w)+(?=\d)*(?!\S)?(/!"x")|\n|.
name3 ./*comment/!/*/.//comment/!/%%
αβγ.

%{
  function(){return;};
%}// comment

%s start_condition x
%x _αβγ

%include include.js

%%

/*
 * comment
 */
// comment

<INITIAL>. return yytext; // comment
<x,_αβγ>. // comment
<*><<EOF>> %include "include.js" // comment
<<EOF>>
%{
  /* yyleng yylineno yylloc yytext */ // yyleng yylineno yylloc yytext
  "yytext"; 'yytext'; `yytext${yytext + "yytext"}`;
  /yytext/;
  return yytext;
%}

{name1} return 1;
{name2} return 2;
{name3} return 3;

%%

%include 'include.js'
console.log('hello, world');
