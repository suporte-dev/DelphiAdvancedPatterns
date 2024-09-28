# ResultMatching

A unit `ResultMatching` fornece uma estrutura genérica para o tratamento de resultados de operações que podem ter sucesso ou falhar, encapsulando tanto o valor de sucesso quanto as informações de erro. Ela implementa um sistema de **Pattern Matching**, permitindo que você lide com diferentes resultados de maneira clara e organizada.

## Sumário

- [Visão Geral](#visão-geral)
- [Tipos e Classes](#tipos-e-classes)
  - [TErrResult](#terrresult)
  - [TMatchResult\<U, E\>](#tmatchresultu-e)
  - [TResultOptions\<T\>](#tresultoptionst)
- [Como Utilizar](#como-utilizar)
  - [Exemplo de Uso](#exemplo-de-uso)
- [Considerações Finais](#considerações-finais)

## Visão Geral

A unit `ResultMatching` foi projetada para facilitar o gerenciamento de resultados de operações que podem resultar em sucesso ou erro. Utilizando tipos genéricos, ela oferece flexibilidade para trabalhar com diferentes tipos de dados e erros, melhorando a legibilidade e a manutenção do código.

### Tipos e Classes

### TErrResult

O `TErrResult` encapsula detalhes mais específicos sobre um erro. Agora implementado como um **record** com operadores **implicit** para facilitar a criação e o uso de erros.

```delphi
type
  TErrResult = record
  private
    FCode: Integer;
    FDescription: string;
  public
    constructor Create(ACode: Integer; ADescription: string);
    class operator Implicit(AError: string): TErrResult;
    class operator Implicit(ACode: Integer): TErrResult;
    property Code: Integer read FCode;
    property Description: string read FDescription;
  end;
```

#### Construtor

O construtor da `TErrResult` inicializa o código de erro e a descrição.

```delphi
constructor TErrResult.Create(ACode: Integer; ADescription: string);
begin
  FCode := ACode;
  FDescription := ADescription;
end;
```

- **ACode**: Código numérico que identifica o tipo de erro.
- **ADescription**: Descrição detalhada do erro.

#### Operadores Implícitos

Permitem criar instâncias de `TErrResult` de maneira mais conveniente.

```delphi
class operator TErrResult.Implicit(AError: string): TErrResult;
begin
  Result := TErrResult.Create(0, AError);
end;

class operator TErrResult.Implicit(ACode: Integer): TErrResult;
begin
  Result := TErrResult.Create(ACode, 'Erro desconhecido');
end;
```

### TMatchResult\<U, E\>

O record `TMatchResult<U, E>` é utilizado para armazenar o resultado de uma operação, indicando se foi bem-sucedida e o valor resultante, seja um valor de sucesso ou uma mensagem de erro.

```delphi
type
  TMatchResult<U, E> = record
    IsOk: Boolean;
    OkValue: U;
    ErrValue: E;
  end;
```

- **IsOk**: Indicador booleano que representa se a operação foi bem-sucedida (`True`) ou resultou em erro (`False`).
- **OkValue**: Valor resultante da operação, do tipo genérico `U`.
- **ErrValue**: Valor do erro, do tipo genérico `E`.

### TResultOptions\<T\>

O record `TResultOptions<T>` representa uma operação que pode ser bem-sucedida ou falhar. Ele encapsula tanto o valor de sucesso quanto as informações de erro.

```delphi
type
  TResultOptions<T> = record
  private
    FValue: T;
    FError: TErrResult;
    FIsOk: Boolean;
    procedure InitOk(AValue: T);
    procedure InitErr(AError: TErrResult);
  public
    class operator Implicit(AValue: T): TResultOptions<T>;
    class operator Implicit(AError: TErrResult): TResultOptions<T>;

    function IsOk: Boolean;
    function IsErr: Boolean;

    function Value: T;
    function Error: TErrResult;

    function Match<U, E>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, E>): TMatchResult<U, E>;
    procedure MatchProcedures(OnOk: TProc<T>; OnErr: TProc<TErrResult>);
  end;
```

#### Operadores Implícitos

Facilitam a criação de `TResultOptions` diretamente a partir de um valor de sucesso ou um erro.

```delphi
class operator TResultOptions<T>.Implicit(AValue: T): TResultOptions<T>;
begin
  Result.InitOk(AValue);
end;

class operator TResultOptions<T>.Implicit(AError: TErrResult): TResultOptions<T>;
begin
  Result.InitErr(AError);
end;
```

- **Implicit(AValue: T)**: Cria um `TResultOptions` representando sucesso.
- **Implicit(AError: TErrResult)**: Cria um `TResultOptions` representando erro.

#### Métodos de Verificação

```delphi
function TResultOptions<T>.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TResultOptions<T>.IsErr: Boolean;
begin
  Result := not FIsOk;
end;
```

- **IsOk**: Retorna `True` se a operação foi bem-sucedida.
- **IsErr**: Retorna `True` se a operação resultou em erro.

#### Métodos de Acesso

```delphi
function TResultOptions<T>.Value: T;
begin
  if not FIsOk then
    raise Exception.Create('Nenhum valor disponível. A operação resultou em erro.');
  Result := FValue;
end;

function TResultOptions<T>.Error: TErrResult;
begin
  if FIsOk then
    raise Exception.Create('Nenhum erro. A operação foi bem-sucedida.');
  Result := FError;
end;
```

- **Value**: Retorna o valor de sucesso. Lança exceção se a operação resultou em erro.
- **Error**: Retorna o objeto `TErrResult` do erro. Lança exceção se a operação foi bem-sucedida.

#### Método Match

Implementa um sistema de **Pattern Matching**, permitindo definir como lidar com os casos de sucesso e erro de forma clara e concisa.

```delphi
function TResultOptions<T>.Match<U, E>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, E>): TMatchResult<U, E>;
var
  matchResult: TMatchResult<U, E>;
begin
  matchResult.IsOk := FIsOk;

  if FIsOk then
    matchResult.OkValue := OnOk(FValue)
  else
    matchResult.ErrValue := OnErr(FError);

  Result := matchResult;
end;
```

- **OnOk**: Função a ser executada se a operação for bem-sucedida. Recebe o valor de sucesso (`T`) e retorna um resultado (`U`).
- **OnErr**: Função a ser executada se a operação resultar em erro. Recebe o objeto `TErrResult` e retorna um resultado (`E`).
- **Retorno**: Um `TMatchResult<U, E>` contendo o resultado da função executada e um indicador de sucesso ou erro.

#### Método MatchProcedures

Permite executar ações sem retorno para sucesso ou erro.

```delphi
procedure TResultOptions<T>.MatchProcedures(OnOk: TProc<T>; OnErr: TProc<TErrResult>);
begin
  if FIsOk then
    OnOk(FValue)
  else
    OnErr(FError);
end;
```

### Como Utilizar

A seguir, um exemplo de como utilizar a unit `ResultMatching` para tratar resultados de operações.

### Exemplo de Uso com Funções

```delphi
uses
  ResultMatching, System.SysUtils, Vcl.Dialogs;

procedure TestPatternMatching;
var
  resultSuccess: TResultOptions<Integer>;
  resultError: TResultOptions<Integer>;
  matchResult: TMatchResult<string, string>;
  error: TErrResult;
begin
  // Simulando um sucesso
  resultSuccess := 10;

  // Utilizando o método Match para tratar o sucesso
  matchResult := resultSuccess.Match<string, string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  if matchResult.IsOk then
    ShowMessage(matchResult.OkValue)
  else
    ShowMessage(matchResult.ErrValue);

  // Simulando um erro
  error := TErrResult.Create(404, 'Recurso não encontrado');
  resultError := error;

  // Utilizando o método Match para tratar o erro
  matchResult := resultError.Match<string, string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  if matchResult.IsOk then
    ShowMessage(matchResult.OkValue)
  else
    ShowMessage(matchResult.ErrValue);
end;
```

### Exemplo de Uso com Procedures

```delphi
uses
  ResultMatching, System.SysUtils, Vcl.Dialogs;

procedure TestPatternMatchingWithProcedures;
var
  resultSuccess: TResultOptions<Integer>;
  resultError: TResultOptions<Integer>;
  error: TErrResult;
begin
  // Simulando um sucesso
  resultSuccess := 10;

  // Utilizando o método MatchProcedures para tratar o sucesso e erro
  resultSuccess.MatchProcedures(
    procedure(Value: Integer)
    begin
      ShowMessage('Sucesso: ' + IntToStr(Value));
    end,
    procedure(Err: TErrResult)
    begin
      ShowMessage('Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description);
    end
  );

  // Simulando um erro
  error := TErrResult.Create(404, 'Recurso não encontrado');
  resultError := error;

  // Utilizando o método MatchProcedures para tratar o erro
  resultError.MatchProcedures(
    procedure(Value: Integer)
    begin
      ShowMessage('Sucesso: ' + IntToStr(Value));
    end,
    procedure(Err: TErrResult)
    begin
      ShowMessage('Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description);
    end
  );
end;
```

### Passo a Passo do Exemplo

#### Simulando um Sucesso com Funções:

1. Atribuímos o valor `10` a `resultSuccess`, criando um `TResultOptions<Integer>`.
2. Utilizamos o método `Match<string, string>` passando duas funções anônimas:
   - **OnOk**: Retorna uma string com a mensagem de sucesso.
   - **OnErr**: Retorna uma string com a mensagem de erro.
3. Exibimos a mensagem de sucesso resultante.

#### Simulando um Sucesso com Procedures:

1. Atribuímos o valor `10` a `resultSuccess`, criando um `TResultOptions<Integer>`.
2. Utilizamos o método `MatchProcedures` passando dois **procedures** anônimos:
   - **OnOk**: Executa uma ação no caso de sucesso (mostra a mensagem).
   - **OnErr**: Executa uma ação no caso de erro (mostra a mensagem).

### Considerações Finais

- **Flexibilidade**: A estrutura genérica permite que `ResultMatching` seja reutilizável para diferentes tipos de operações e resultados.
  
- **Segurança**: Métodos de acesso garantem que o valor de sucesso ou erro sejam acessados corretamente.

- **Legibilidade**: O método `Match` melhora a clareza do código ao tratar diferentes cenários, e o `MatchProcedures` permite uma abordagem mais direta para executar ações.

- **Extensibilidade**: A estrutura pode ser estendida para suportar diferentes tipos de erros ou operações.

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE.md) para mais detalhes.
