# Unit de Teste: `TestResultMatching`

Documentando a utilização do framework **DUnit** para testar a unit `ResultMatching`. 
A unit verifica o comportamento correto dos métodos e operadores implícitos, além de testar o sistema de Pattern Matching implementado.

# Sumário

- [Unit de Teste: `TestResultMatching`](#unit-de-teste-testresultmatching)
- [Estrutura da Unit](#estrutura-da-unit)
  - [Interface](#interface)
- [Implementação dos Testes](#implementação-dos-testes)
  - [Teste `TestImplicitOk`](#teste-testimplicitok)
  - [Teste `TestImplicitErr`](#teste-testimpliciterr)
  - [Teste `TestIsOk`](#teste-testisok)
  - [Teste `TestIsErr`](#teste-testiserr)
  - [Teste `TestValueSuccess`](#teste-testvaluesuccess)
  - [Teste `TestErrorFailure`](#teste-testerrorfailure)
  - [Teste `TestMatchSuccess`](#teste-testmatchsuccess)
  - [Teste `TestMatchError`](#teste-testmatcherror)
  - [Teste `TestMatchProceduresSuccess`](#teste-testmatchproceduressuccess)
  - [Teste `TestMatchProceduresError`](#teste-testmatchprocedureserror)
- [Registro dos Testes](#registro-dos-testes)
- [Conclusão](#conclusão)
- [Como configurar o Test Runner para ser executado em um projeto VCL automaticamente](#como-configurar-o-test-runner-para-ser-executado-em-um-projeto-vcl-automaticamente)
  - [Exemplo](#exemplo)


## Estrutura da Unit

### Interface

OBS: A interface da unit de teste inclui a importação das units `TestFramework`, `ResultMatching`, e `SysUtils`. 
A classe de teste `TestTResultOptions` contém os métodos de teste para verificar os diferentes comportamentos da unit `ResultMatching`.

```delphi
unit TestResultMatching;

interface

uses
  TestFramework,
  ResultMatching,
  SysUtils;

type
  // Teste unitário para a unit ResultMatching
  TestTResultOptions = class(TTestCase)
  published
    procedure TestImplicitOk;
    procedure TestImplicitErr;
    procedure TestIsOk;
    procedure TestIsErr;
    procedure TestValueSuccess;
    procedure TestErrorFailure;
    procedure TestMatchSuccess;
    procedure TestMatchError;
    procedure TestMatchProceduresSuccess;
    procedure TestMatchProceduresError;
  end;
```
### Implementação dos Testes

#### Teste `TestImplicitOk`

Verifica se o operador implícito para um valor de sucesso (`TResultOptions`) funciona corretamente.

```delphi
procedure TestTResultOptions.TestImplicitOk;
var
  Result: TResultOptions<Integer>;
begin
  Result := 10; // Implicitamente cria um TResultOptions com sucesso
  CheckTrue(Result.IsOk, 'O resultado deveria ser Ok.');
  CheckEquals(10, Result.Value, 'O valor esperado é 10.');
end;
```
#### Teste `TestImplicitErr`

Verifica se o operador implícito para um erro (`TResultOptions`) funciona corretamente.

```delphi
procedure TestTResultOptions.TestImplicitErr;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
begin
  Error := TErrResult.Create(404, 'Not Found');
  Result := Error; // Implicitamente cria um TResultOptions com erro
  CheckTrue(Result.IsErr, 'O resultado deveria ser Err.');
  CheckEquals(404, Result.Error.Code, 'O código de erro esperado é 404.');
  CheckEquals('Not Found', Result.Error.Description, 'A descrição do erro deveria ser "Not Found".');
end;
```

#### Teste `TestIsOk`

Verifica se o método `IsOk` retorna verdadeiro quando a operação foi bem-sucedida.

```delphi
procedure TestTResultOptions.TestIsOk;
var
  Result: TResultOptions<Integer>;
begin
  Result := 10;
  CheckTrue(Result.IsOk, 'O resultado deveria ser Ok.');
end;
```

#### Teste `TestIsErr`

Verifica se o método `IsErr` retorna verdadeiro quando a operação resulta em erro.

```delphi
procedure TestTResultOptions.TestIsErr;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
begin
  Error := TErrResult.Create(500, 'Internal Error');
  Result := Error;
  CheckTrue(Result.IsErr, 'O resultado deveria ser Err.');
end;
```

#### Teste `TestValueSuccess`

Verifica se o valor de sucesso é retornado corretamente.

```delphi
procedure TestTResultOptions.TestValueSuccess;
var
  Result: TResultOptions<Integer>;
begin
  Result := 42;
  CheckEquals(42, Result.Value, 'O valor esperado é 42.');
end;
```

#### Teste `TestErrorFailure`

Verifica se as informações de erro são retornadas corretamente.

```delphi
procedure TestTResultOptions.TestErrorFailure;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
begin
  Error := TErrResult.Create(400, 'Bad Request');
  Result := Error;
  CheckEquals(400, Result.Error.Code, 'O código de erro esperado é 400.');
  CheckEquals('Bad Request', Result.Error.Description, 'A descrição do erro deveria ser "Bad Request".');
end;
```

#### Teste `TestMatchSuccess`

Verifica o funcionamento do `Match` em casos de sucesso.

```delphi
procedure TestTResultOptions.TestMatchSuccess;
var
  Result: TResultOptions<Integer>;
  MatchResult: TMatchResult<string>;
begin
  Result := 10;

  // Testando o Match para um valor de sucesso
  MatchResult := Result.Match<string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code);
    end
  );

  CheckTrue(MatchResult.IsOk, 'O resultado do Match deveria ser Ok.');
  CheckEquals('Sucesso: 10', MatchResult.Value, 'A mensagem de sucesso deveria ser "Sucesso: 10".');
end;
```

#### Teste `TestMatchError`

Verifica o funcionamento do `Match` em casos de erro.

```delphi
procedure TestTResultOptions.TestMatchError;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
  MatchResult: TMatchResult<string>;
begin
  Error := TErrResult.Create(500, 'Erro Interno');
  Result := Error;

  // Testando o Match para um erro
  MatchResult := Result.Match<string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code) + ' - ' + Err.Description;
    end
  );

  CheckFalse(MatchResult.IsOk, 'O resultado do Match deveria ser Err.');
  CheckEquals('Erro: 500 - Erro Interno', MatchResult.Value, 'A mensagem de erro deveria ser "Erro: 500 - Erro Interno".');
end;
```

#### Teste `TestMatchProceduresSuccess`

Verifica o funcionamento do `MatchProcedures` em casos de sucesso.

```delphi
procedure TestTResultOptions.TestMatchProceduresSuccess;
var
  Result: TResultOptions<Integer>;
  SuccessMessage: string;
begin
  Result := 10;
  
  // Utilizando o MatchProcedures para testar o sucesso
  Result.MatchProcedures(
    procedure(Value: Integer)
    begin
      SuccessMessage := 'Sucesso: ' + IntToStr(Value);
    end,
    procedure(Err: TErrResult)
    begin
      SuccessMessage := 'Erro inesperado';
    end
  );

  CheckEquals('Sucesso: 10', SuccessMessage, 'A mensagem de sucesso deveria ser "Sucesso: 10".');
end;
```

#### Teste `TestMatchProceduresError`

Verifica o funcionamento do `MatchProcedures` em casos de erro.

```delphi
procedure TestTResultOptions.TestMatchProceduresError;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
  ErrorMessage: string;
begin
  Error := TErrResult.Create(404, 'Recurso não encontrado');
  Result := Error;

  // Utilizando o MatchProcedures para testar o erro
  Result.MatchProcedures(
    procedure(Value: Integer)
    begin
      ErrorMessage := 'Sucesso inesperado';
    end,
    procedure(Err: TErrResult)
    begin
      ErrorMessage := 'Erro: ' + IntToStr(Err.Code) + ' - ' + Err.Description;
    end
  );

  CheckEquals('Erro: 404 - Recurso não encontrado', ErrorMessage, 'A mensagem de erro deveria ser "Erro: 404 - Recurso não encontrado".');
end;
```

### Registro dos Testes

Os testes são registrados no bloco `initialization`, o que garante que eles sejam executados pelo **DUnit Test Runner**.

```delphi
initialization
  // Registro da suite de testes
  RegisterTest(TestTResultOptions.Suite);
```

### Conclusão

Esta unit de teste cobre os principais comportamentos esperados da unit `ResultMatching`.
Ela verifica o funcionamento dos operadores implícitos, os métodos `IsOk` e `IsErr`,
bem como o sistema de **Pattern Matching** implementado no método `Match` e nas **procedures anônimas** no `MatchProcedures`.

### Como configurar o Test Runner para ser executado em um projeto VCL automaticamente
sem a criação de um DUnit Project:

Para configurar o **Test Runner** e executar os testes automaticamente em um projeto VCL, siga os seguintes passos:

1. **Adicione a unit de teste (`TestResultMatching`) ao seu projeto VCL**.
   
2. **No uses da unit principal**, adicione as seguintes units:
   - `GUITestRunner` (fornecerá a interface gráfica para rodar os testes).
   - `TestResultMatching` (a unit de teste dos métodos, operadores implícitos etc.).

3. **Chame o `GUITestRunner` para iniciar a execução dos testes**. Isso será feito no bloco `begin-end` no source do projeto principal.

#### Exemplo

Abaixo está um exemplo simples adicionando a unit de teste no **source** de um projeto VCL de teste:

```delphi
uses
  Vcl.Forms,
  GUITestRunner, // Test Runner para DUnit
  TestResultMatching in 'TestResultMatching.pas'; // Adicione a unit de teste

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests; // Inicializa o Test Runner do DUnit
  Application.Run;
end.
```
