describe "language-jison", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage "language-jison"

  describe "Jison grammar", ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName "source.jison"

    it "is defined", ->
      expect(grammar.scopeName).toBe "source.jison"

    it "tokenizes section separators", ->
      lines = grammar.tokenizeLines """
        %%
        %%
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.separator.section.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.separator.section.jison"]

    it "tokenizes embedded lexers", ->
      lines = grammar.tokenizeLines """
        %lex

        %%
        /lex
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%lex", scopes: ["source.jison", "meta.section.declarations.jison", "entity.name.tag.lexer.begin.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.definitions.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.section.declarations.jison", "meta.separator.section.jisonlex"]
      tokens = lines[3]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "/lex", scopes: ["source.jison", "meta.section.declarations.jison", "entity.name.tag.lexer.end.jison"]
      lines = grammar.tokenizeLines """
        %lex

        %%

        %%
        /lex
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%lex", scopes: ["source.jison", "meta.section.declarations.jison", "entity.name.tag.lexer.begin.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.definitions.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.section.declarations.jison", "meta.separator.section.jisonlex"]
      tokens = lines[3]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.rules.jisonlex"]
      tokens = lines[4]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.section.declarations.jison", "meta.separator.section.jisonlex"]
      tokens = lines[5]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "/lex", scopes: ["source.jison", "meta.section.declarations.jison", "entity.name.tag.lexer.end.jison"]

    it "tokenizes prologues", ->
      lines = grammar.tokenizeLines """
        %{

        %}%start start // comment
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%{", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.prologue.jison", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.prologue.jison", "meta.user-code-block.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 5
      expect(tokens[0]).toEqual value: "%}", scopes: ["source.jison", "meta.section.declarations.jison", "meta.section.prologue.jison", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]
      expect(tokens[1]).toEqual value: "%start", scopes: ["source.jison", "meta.section.declarations.jison", "keyword.other.declaration.start.jison"]
      expect(tokens[2]).toEqual value: " start ", scopes: ["source.jison", "meta.section.declarations.jison"]
      expect(tokens[3]).toEqual value: "//", scopes: ["source.jison", "meta.section.declarations.jison", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[4]).toEqual value: " comment", scopes: ["source.jison", "meta.section.declarations.jison", "comment.line.double-slash.jison"]

    it "tokenizes %code declarations", ->
      lines = grammar.tokenizeLines """
        %code/**/init %include 'include.js'//comment
        %code required %include "include.js"
        %code 'init' {{}}
        %code "required" -> return;//comment
        %code requires %include include.js
      """
      tokens = lines[0]
      expect(tokens.length).toBe 12
      expect(tokens[0]).toEqual value: "%code", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.declaration.code.jison"]
      expect(tokens[1]).toEqual value: "/*", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "comment.block.jison", "punctuation.definition.comment.begin.jison"]
      expect(tokens[2]).toEqual value: "*/", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "comment.block.jison", "punctuation.definition.comment.end.jison"]
      expect(tokens[3]).toEqual value: "init", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.code-qualifier.init.jison"]
      expect(tokens[4]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[5]).toEqual value: "%include", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[6]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison"]
      expect(tokens[7]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.single.jison"]
      expect(tokens[8]).toEqual value: "include.js", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.single.jison"]
      expect(tokens[9]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.single.jison"]
      expect(tokens[10]).toEqual value: "//", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[11]).toEqual value: "comment", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "comment.line.double-slash.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 9
      expect(tokens[0]).toEqual value: "%code", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.declaration.code.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[2]).toEqual value: "required", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.code-qualifier.required.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[4]).toEqual value: "%include", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison"]
      expect(tokens[6]).toEqual value: '"', scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.double.jison"]
      expect(tokens[7]).toEqual value: "include.js", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.double.jison"]
      expect(tokens[8]).toEqual value: '"', scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.quoted.double.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 8
      expect(tokens[0]).toEqual value: "%code", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.declaration.code.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[2]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.single.jison"]
      expect(tokens[3]).toEqual value: "init", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.single.jison"]
      expect(tokens[4]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.single.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[6]).toEqual value: "{{", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison", "punctuation.definition.action.begin.jison"]
      expect(tokens[7]).toEqual value: "}}", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison", "punctuation.definition.action.end.jison"]
      tokens = lines[3]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: "%code", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.declaration.code.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[2]).toEqual value: '"', scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.double.jison"]
      expect(tokens[3]).toEqual value: "required", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.double.jison"]
      expect(tokens[4]).toEqual value: '"', scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.quoted.double.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[6]).toEqual value: "->", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison", "punctuation.definition.action.arrow.jison"]
      expect(tokens[7]).toEqual value: " return;", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison"]
      expect(tokens[8]).toEqual value: "//", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison", "comment.line.double-slash.js", "punctuation.definition.comment.js"]
      expect(tokens[9]).toEqual value: "comment", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.action.jison", "comment.line.double-slash.js"]
      tokens = lines[4]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "%code", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "keyword.other.declaration.code.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[2]).toEqual value: "requires", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "string.unquoted.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison"]
      expect(tokens[4]).toEqual value: "%include", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison"]
      expect(tokens[6]).toEqual value: "include.js", scopes: ["source.jison", "meta.section.declarations.jison", "meta.code.jison", "meta.include.jison", "string.unquoted.jison"]

    it "tokenizes %options declarations", ->
      lines = grammar.tokenizeLines """
        %options foo={x}// not-a-comment
        %options no-default-action //comment
      """
      tokens = lines[0]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "%options", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "keyword.other.options.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison"]
      expect(tokens[2]).toEqual value: "foo", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "entity.name.constant.jison"]
      expect(tokens[3]).toEqual value: "=", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "keyword.operator.option.assignment.jison"]
      expect(tokens[4]).toEqual value: "{x}//", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "string.unquoted.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison"]
      expect(tokens[6]).toEqual value: "not-a-comment", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "entity.name.constant.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 6
      expect(tokens[0]).toEqual value: "%options", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "keyword.other.options.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison"]
      expect(tokens[2]).toEqual value: "no-default-action", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "entity.name.constant.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison"]
      expect(tokens[4]).toEqual value: "//", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[5]).toEqual value: "comment", scopes: ["source.jison", "meta.section.declarations.jison", "meta.options.jison", "comment.line.double-slash.jison"]

    it "tokenizes %token declarations", ->
      lines = grammar.tokenizeLines """
        %token TOKEN1 //comment
        %token <type> TOKEN2 %%
        %token TOKEN3 0x0123456789ABCDEF 'description';
      """
      tokens = lines[0]
      expect(tokens.length).toBe 6
      expect(tokens[0]).toEqual value: "%token", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "keyword.other.declaration.token.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[2]).toEqual value: "TOKEN1", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "entity.other.token.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[4]).toEqual value: "//", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[5]).toEqual value: "comment", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "comment.line.double-slash.jison"]
      # The next two lines seem like they’re supposed to be valid Jison %token
      # declarations, but they don’t appear to work.
      tokens = lines[1]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "%token", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "keyword.other.declaration.token.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[2]).toEqual value: "<type>", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "invalid.unimplemented.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[4]).toEqual value: "TOKEN2", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "entity.other.token.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[6]).toEqual value: "%%", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "punctuation.terminator.declaration.token.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 11
      expect(tokens[0]).toEqual value: "%token", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "keyword.other.declaration.token.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[2]).toEqual value: "TOKEN3", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "entity.other.token.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[4]).toEqual value: "0x", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "storage.type.number.jison"]
      expect(tokens[5]).toEqual value: "0123456789ABCDEF", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "constant.numeric.integer.hexadecimal.jison"]
      expect(tokens[6]).toEqual value: " ", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison"]
      expect(tokens[7]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "string.quoted.single.jison"]
      expect(tokens[8]).toEqual value: "description", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "string.quoted.single.jison"]
      expect(tokens[9]).toEqual value: "'", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "string.quoted.single.jison"]
      expect(tokens[10]).toEqual value: ";", scopes: ["source.jison", "meta.section.declarations.jison", "meta.token.jison", "punctuation.terminator.declaration.token.jison"]

    it "tokenizes rules", ->
      lines = grammar.tokenizeLines """
        %%
        start: expression;
        expression
        : TOKEN EOF {$$ = [$1];}
        | expression '+'[add] expression %{ $$ = `${@add.first_line}`; %}
        | '-' expression %prec UMINUS { yysp; }
        | "(" expression ")" %include include.js //comment
        | error -> yyclearin;yyerrok;//comment
        | %empty → //comment
        ;
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.separator.section.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: "start", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "entity.name.constant.rule-result.jison"]
      expect(tokens[1]).toEqual value: ":", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.assignment.jison"]
      expect(tokens[2]).toEqual value: " expression", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[3]).toEqual value: ";", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "punctuation.terminator.rule.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "expression", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "entity.name.constant.rule-result.jison"]
      tokens = lines[3]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: ":", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.assignment.jison"]
      expect(tokens[1]).toEqual value: " TOKEN ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: "EOF", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.other.EOF.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[4]).toEqual value: "{", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.begin.jison"]
      expect(tokens[5]).toEqual value: "$$", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "variable.language.semantic-value.jison"]
      expect(tokens[6]).toEqual value: " = [", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[7]).toEqual value: "$1", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "support.variable.token-value.jison"]
      expect(tokens[8]).toEqual value: "];", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[9]).toEqual value: "}", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.end.jison"]
      tokens = lines[4]
      expect(tokens.length).toBe 16
      expect(tokens[0]).toEqual value: "|", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.separator.jison"]
      expect(tokens[1]).toEqual value: " expression ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: "'", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[3]).toEqual value: "+", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[4]).toEqual value: "'", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[5]).toEqual value: "[", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "punctuation.definition.named-reference.begin.jison"]
      expect(tokens[6]).toEqual value: "add", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "entity.name.other.reference.jison"]
      expect(tokens[7]).toEqual value: "]", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "punctuation.definition.named-reference.end.jison"]
      expect(tokens[8]).toEqual value: " expression ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[9]).toEqual value: "%{", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      expect(tokens[10]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison"]
      expect(tokens[11]).toEqual value: "$$", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison", "variable.language.semantic-value.jison"]
      expect(tokens[12]).toEqual value: " = `${", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison"]
      expect(tokens[13]).toEqual value: "@add", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison", "support.variable.token-location.jison"]
      expect(tokens[14]).toEqual value: ".first_line}`; ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison"]
      expect(tokens[15]).toEqual value: "%}", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]
      tokens = lines[5]
      expect(tokens.length).toBe 15
      expect(tokens[0]).toEqual value: "|", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.separator.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: "'", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[3]).toEqual value: "-", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[4]).toEqual value: "'", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.single.jison"]
      expect(tokens[5]).toEqual value: " expression ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[6]).toEqual value: "%prec", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.prec.jison", "keyword.other.prec.jison"]
      expect(tokens[7]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.prec.jison"]
      expect(tokens[8]).toEqual value: "UMINUS", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.prec.jison", "constant.other.token.jison"]
      expect(tokens[9]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[10]).toEqual value: "{", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.begin.jison"]
      expect(tokens[11]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[12]).toEqual value: "yysp", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "variable.language.stack-index-0.jison"]
      expect(tokens[13]).toEqual value: "; ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[14]).toEqual value: "}", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.end.jison"]
      tokens = lines[6]
      expect(tokens.length).toBe 16
      expect(tokens[0]).toEqual value: "|", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.separator.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: '"', scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[3]).toEqual value: "(", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[4]).toEqual value: '"', scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[5]).toEqual value: " expression ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[6]).toEqual value: '"', scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[7]).toEqual value: ")", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[8]).toEqual value: '"', scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "string.quoted.double.jison"]
      expect(tokens[9]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[10]).toEqual value: "%include", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[11]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.include.jison"]
      expect(tokens[12]).toEqual value: "include.js", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.include.jison", "string.unquoted.jison"]
      expect(tokens[13]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[14]).toEqual value: "//", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[15]).toEqual value: "comment", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "comment.line.double-slash.jison"]
      tokens = lines[7]
      expect(tokens.length).toBe 12
      expect(tokens[0]).toEqual value: "|", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.separator.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: "error", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.other.error.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[4]).toEqual value: "->", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.arrow.jison"]
      expect(tokens[5]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[6]).toEqual value: "yyclearin", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "keyword.other.jison"]
      expect(tokens[7]).toEqual value: ";", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[8]).toEqual value: "yyerrok", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "keyword.other.jison"]
      expect(tokens[9]).toEqual value: ";", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[10]).toEqual value: "//", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "comment.line.double-slash.js", "punctuation.definition.comment.js"]
      expect(tokens[11]).toEqual value: "comment", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "comment.line.double-slash.js"]
      tokens = lines[8]
      expect(tokens.length).toBe 8
      expect(tokens[0]).toEqual value: "|", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.separator.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[2]).toEqual value: "%empty", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.other.empty.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
      expect(tokens[4]).toEqual value: "→", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "punctuation.definition.action.arrow.jison"]
      expect(tokens[5]).toEqual value: ' ', scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison"]
      expect(tokens[6]).toEqual value: "//", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "comment.line.double-slash.js", "punctuation.definition.comment.js"]
      expect(tokens[7]).toEqual value: "comment", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "meta.action.jison", "comment.line.double-slash.js"]
      tokens = lines[9]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: ";", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "punctuation.terminator.rule.jison"]

    it "tokenizes empty rules", ->
      for token in ["%empty", "%epsilon", "\u0190", "\u025B", "\u03B5", "\u03F5"]
        {tokens} = grammar.tokenizeLine "%% rule: #{token};"
        expect(tokens.length).toBe 7
        expect(tokens[0]).toEqual value: "%%", scopes: ["source.jison", "meta.separator.section.jison"]
        expect(tokens[1]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison"]
        expect(tokens[2]).toEqual value: "rule", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "entity.name.constant.rule-result.jison"]
        expect(tokens[3]).toEqual value: ":", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.operator.rule-components.assignment.jison"]
        expect(tokens[4]).toEqual value: " ", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison"]
        expect(tokens[5]).toEqual value: token, scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "meta.rule-components.jison", "keyword.other.empty.jison"]
        expect(tokens[6]).toEqual value: ";", scopes: ["source.jison", "meta.section.rules.jison", "meta.rule.jison", "punctuation.terminator.rule.jison"]

  describe "Jison Lex grammar", ->
    grammar = undefined

    beforeEach ->
      grammar = atom.grammars.grammarForScopeName "source.jisonlex"

    it "is defined", ->
      expect(grammar.scopeName).toBe "source.jisonlex"

    it "tokenizes section separators", ->
      lines = grammar.tokenizeLines """
        %%
        %%
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]

    it "tokenizes comments", ->
      lines = grammar.tokenizeLines """
        /*
         * comment
         */
        // comment
        %%
        /*
         * comment
         */
        // comment
        %%
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "/*", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.block.jison", "punctuation.definition.comment.begin.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: " * comment", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.block.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.block.jison"]
      expect(tokens[1]).toEqual value: "*/", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.block.jison", "punctuation.definition.comment.end.jison"]
      tokens = lines[3]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "//", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[1]).toEqual value: " comment", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "comment.line.double-slash.jison"]
      tokens = lines[4]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[5]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "/*", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.block.jison", "punctuation.definition.comment.begin.jison"]
      tokens = lines[6]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: " * comment", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.block.jison"]
      tokens = lines[7]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.block.jison"]
      expect(tokens[1]).toEqual value: "*/", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.block.jison", "punctuation.definition.comment.end.jison"]
      tokens = lines[8]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "//", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[1]).toEqual value: " comment", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "comment.line.double-slash.jison"]
      tokens = lines[9]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]

    it "tokenizes name definitions", ->
      lines = grammar.tokenizeLines """
        name1 definition
        name2.
        name3 ./**///%%
        α-βγ.
      """
      tokens = lines[0]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "name1", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "entity.name.variable.jisonlex"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex"]
      expect(tokens[2]).toEqual value: "definition", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex"]
      tokens = lines[1]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "name2", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "entity.name.variable.jisonlex"]
      expect(tokens[1]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "name3", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "entity.name.variable.jisonlex"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex"]
      expect(tokens[2]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[3]).toEqual value: "/*", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "comment.block.jison", "punctuation.definition.comment.begin.jison"]
      expect(tokens[4]).toEqual value: "*/", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "comment.block.jison", "punctuation.definition.comment.end.jison"]
      expect(tokens[5]).toEqual value: "//", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "comment.line.double-slash.jison", "punctuation.definition.comment.jison"]
      expect(tokens[6]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "comment.line.double-slash.jison"]
      tokens = lines[3]
      expect(tokens.length).toBe 2
      expect(tokens[0]).toEqual value: "α-βγ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "entity.name.variable.jisonlex"]
      expect(tokens[1]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]

    it "tokenizes %{ %} blocks in definitions", ->
      lines = grammar.tokenizeLines """
        %{

        %} name.
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%{", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.user-code-block.jison"]
      tokens = lines[2]
      expect(tokens.length).toBe 4
      expect(tokens[0]).toEqual value: "%}", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex"]
      expect(tokens[2]).toEqual value: "name", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "entity.name.variable.jisonlex"]
      expect(tokens[3]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.definition.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]

    it "tokenizes rules without start conditions", ->
      lines = grammar.tokenizeLines """
        %%
        <<EOF>>
        %{
          return yytext;
        %}
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "<<EOF>>", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.eof.regexp.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%{", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      tokens = lines[3]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "  return ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison"]
      expect(tokens[1]).toEqual value: "yytext", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "variable.language.jisonlex"]
      expect(tokens[2]).toEqual value: ";", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison"]
      tokens = lines[4]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%}", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]

    it "tokenizes rules with start conditions", ->
      lines = grammar.tokenizeLines """
        %%
        <INITIAL>. // action
        <x,_α-βγ>. // action
        <*><<EOF>> // action
        <x,*>. // action
        <x, y>. // action
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[1]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[1]).toEqual value: "INITIAL", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "keyword.other.jisonlex"]
      expect(tokens[2]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 9
      expect(tokens[0]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[1]).toEqual value: "x", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "entity.name.function.jisonlex"]
      expect(tokens[2]).toEqual value: ",", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.separator.start-condition.jisonlex"]
      expect(tokens[3]).toEqual value: "_α-βγ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "entity.name.function.jisonlex"]
      expect(tokens[4]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]
      tokens = lines[3]
      expect(tokens.length).toBe 7
      expect(tokens[0]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[1]).toEqual value: "*", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "keyword.other.any-start-condition.jisonlex"]
      expect(tokens[2]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]
      expect(tokens[3]).toEqual value: "<<EOF>>", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.eof.regexp.jisonlex"]
      tokens = lines[4]
      expect(tokens.length).toBe 9
      expect(tokens[0]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[1]).toEqual value: "x", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "entity.name.function.jisonlex"]
      expect(tokens[2]).toEqual value: ",", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.separator.start-condition.jisonlex"]
      expect(tokens[3]).toEqual value: "*", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "invalid.illegal.jisonlex"]
      expect(tokens[4]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]
      tokens = lines[5]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[1]).toEqual value: "x", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "entity.name.function.jisonlex"]
      expect(tokens[2]).toEqual value: ",", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.separator.start-condition.jisonlex"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "invalid.illegal.jisonlex"]
      expect(tokens[4]).toEqual value: "y", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "entity.name.function.jisonlex"]
      expect(tokens[5]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]

    it "tokenizes rules after %{ %} blocks", ->
      lines = grammar.tokenizeLines """
        %%
        . %{ %}. code
        .%{%}<INITIAL>. code
      """
      tokens = lines[0]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[1]
      expect(tokens.length).toBe 8
      expect(tokens[0]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex"]
      expect(tokens[2]).toEqual value: "%{", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison"]
      expect(tokens[4]).toEqual value: "%}", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]
      expect(tokens[5]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[6]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex"]
      expect(tokens[7]).toEqual value: "code", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 9
      expect(tokens[0]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[1]).toEqual value: "%{", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.begin.jison"]
      expect(tokens[2]).toEqual value: "%}", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.user-code-block.jison", "punctuation.definition.user-code-block.end.jison"]
      expect(tokens[3]).toEqual value: "<", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.begin.jisonlex"]
      expect(tokens[4]).toEqual value: "INITIAL", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "keyword.other.jisonlex"]
      expect(tokens[5]).toEqual value: ">", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.start-conditions.jisonlex", "punctuation.definition.start-conditions.end.jisonlex"]
      expect(tokens[6]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[7]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex"]
      expect(tokens[8]).toEqual value: "code", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex"]

    it "tokenizes %include declarations", ->
      lines = grammar.tokenizeLines """
        %include file.js
        %%
        . %include "file.js" // comment
        %%
        %include 'file.js'
      """
      tokens = lines[0]
      expect(tokens.length).toBe 3
      expect(tokens[0]).toEqual value: "%include", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.include.jison"]
      expect(tokens[2]).toEqual value: "file.js", scopes: ["source.jisonlex", "meta.section.definitions.jisonlex", "meta.include.jison", "string.unquoted.jison"]
      tokens = lines[1]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[2]
      expect(tokens.length).toBe 10
      expect(tokens[0]).toEqual value: ".", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "string.regexp.jisonlex", "keyword.other.character-class.any.regexp.jisonlex"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex"]
      expect(tokens[2]).toEqual value: "%include", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[3]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.include.jison"]
      expect(tokens[4]).toEqual value: '"', scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.include.jison", "string.quoted.double.jison"]
      expect(tokens[5]).toEqual value: "file.js", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.include.jison", "string.quoted.double.jison"]
      expect(tokens[6]).toEqual value: '"', scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "meta.include.jison", "string.quoted.double.jison"]
      expect(tokens[7]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex"]
      expect(tokens[8]).toEqual value: "//", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "comment.line.double-slash.js", "punctuation.definition.comment.js"]
      expect(tokens[9]).toEqual value: " comment", scopes: ["source.jisonlex", "meta.section.rules.jisonlex", "meta.rule.action.jisonlex", "comment.line.double-slash.js"]
      tokens = lines[3]
      expect(tokens.length).toBe 1
      expect(tokens[0]).toEqual value: "%%", scopes: ["source.jisonlex", "meta.separator.section.jisonlex"]
      tokens = lines[4]
      expect(tokens.length).toBe 5
      expect(tokens[0]).toEqual value: "%include", scopes: ["source.jisonlex", "meta.section.user-code.jisonlex", "meta.include.jison", "keyword.other.declaration.include.jison"]
      expect(tokens[1]).toEqual value: " ", scopes: ["source.jisonlex", "meta.section.user-code.jisonlex", "meta.include.jison"]
      expect(tokens[2]).toEqual value: "'", scopes: ["source.jisonlex", "meta.section.user-code.jisonlex", "meta.include.jison", "string.quoted.single.jison"]
      expect(tokens[3]).toEqual value: "file.js", scopes: ["source.jisonlex", "meta.section.user-code.jisonlex", "meta.include.jison", "string.quoted.single.jison"]
      expect(tokens[4]).toEqual value: "'", scopes: ["source.jisonlex", "meta.section.user-code.jisonlex", "meta.include.jison", "string.quoted.single.jison"]
