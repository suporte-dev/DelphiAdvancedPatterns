# ResultMatching

A unit `ResultMatching` fornece uma estrutura genérica para o tratamento de resultados de operações que podem ter sucesso ou falhar, encapsulando tanto o valor de sucesso quanto as informações de erro. Ela implementa um sistema de **Pattern Matching**, permitindo que você lide com diferentes resultados de maneira clara e organizada.

## Sumário

- [Visão Geral](#visão-geral)
- [Tipos e Classes](#tipos-e-classes)
  - [TError](#terror)
  - [TErrResult](#terrresult)
  - [TMatchResult\<U\>](#tmatchresultu)
  - [TResultOptions\<T\>](#tresultoptionst)
- [Como Utilizar](#como-utilizar)
  - [Exemplo de Uso](#exemplo-de-uso)
- [Considerações Finais](#considerações-finais)
- [Licença](#licença)

## Visão Geral

A unit `ResultMatching` foi projetada para facilitar o gerenciamento de resultados de operações que podem resultar em sucesso ou erro. Utilizando tipos genéricos, ela oferece flexibilidade para trabalhar com diferentes tipos de dados e erros, melhorando a legibilidade e a manutenção do código.

## Tipos e Classes

### TError

A classe `TError` encapsula uma mensagem de erro simples. É utilizada para representar erros básicos que podem ocorrer durante a execução de uma operação.

```delphi
type
  // Classe que encapsula uma mensagem de erro simples
  TError = class
  private
    FMessage: string;
  public
    constructor Create(AMessage: string);
    property Message: string read FMessage;
  end;

#### Construtor

O construtor da classe `TError` inicializa a mensagem de erro.

```delphi
constructor TError.Create(AMessage: string);
begin
  FMessage := AMessage;
end;

- **ACode**: Código numérico que identifica o tipo de erro.
- **ADescription**: Descrição detalhada do erro.

### TMatchResult\<U\>

O record `TMatchResult<U>` é uma estrutura genérica utilizada para armazenar o resultado de uma operação, indicando se foi bem-sucedida e o valor resultante, que pode ser um valor de sucesso ou uma mensagem de erro.

```delphi
type
  // Record genérico para armazenar o resultado do Match
  TMatchResult<U> = record
    IsOk: Boolean;
    Value: U;
  end;

- **IsOk**: Indicador booleano que representa se a operação foi bem-sucedida (`True`) ou resultou em erro (`False`).
- **Value**: Valor resultante da operação, do tipo genérico `U`.

### TResultOptions\<T\>

O record `TResultOptions<T>` representa uma operação que pode ser bem-sucedida ou falhar. Ele encapsula tanto o valor de sucesso (`T`) quanto as informações de erro (`TErrResult`). Além disso, fornece métodos para verificar o estado da operação e acessar os resultados de forma segura.

```delphi
type
  // Record genérico que representa uma operação que pode ser bem-sucedida ou falhar
  TResultOptions<T> = record
  private
    FValue: T;
    FError: TErrResult;
    FIsOk: Boolean;
    procedure InitOk(AValue: T);
    procedure InitErr(AError: TErrResult);
  public
    // Operadores implícitos para facilitar a criação de TResultOptions
    class operator Implicit(AValue: T): TResultOptions<T>;
    class operator Implicit(AError: TErrResult): TResultOptions<T>;

    // Métodos para verificar o estado da operação
    function IsOk: Boolean;
    function IsErr: Boolean;

    // Métodos para acessar o valor ou o erro
    function Value: T;
    function Error: TErrResult;

    // Método Match para implementar o Pattern Matching
    function Match<U>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, U>): TMatchResult<U>;
  end;

#### Operadores Implícitos

Permitem criar instâncias de `TResultOptions` de forma simplificada, atribuindo diretamente um valor de sucesso ou um erro.

```delphi
class operator TResultOptions<T>.Implicit(AValue: T): TResultOptions<T>;
begin
  Result.InitOk(AValue);
end;

class operator TResultOptions<T>.Implicit(AError: TErrResult): TResultOptions<T>;
begin
  Result.InitErr(AError);
end;

- **Implicit(AValue: T)**: Cria um `TResultOptions` representando sucesso com o valor `AValue`.
- **Implicit(AError: TErrResult)**: Cria um `TResultOptions` representando erro com o objeto `AError`.

#### Métodos de Verificação

Permitem verificar o estado da operação.

```delphi
function TResultOptions<T>.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TResultOptions<T>.IsErr: Boolean;
begin
  Result := not FIsOk;
end;

- **IsOk**: Retorna `True` se a operação foi bem-sucedida.
- **IsErr**: Retorna `True` se a operação resultou em erro.

#### Métodos de Acesso

Permitem acessar o valor de sucesso ou o erro de forma segura, lançando exceções se forem acessados incorretamente.

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


- **Value**: Retorna o valor de sucesso. Lança exceção se a operação resultou em erro.
- **Error**: Retorna o objeto `TErrResult` do erro. Lança exceção se a operação foi bem-sucedida.

#### Método Match

Implementa um sistema de **Pattern Matching**, permitindo que você defina como lidar com os casos de sucesso e erro de forma clara e concisa.

```delphi
function TResultOptions<T>.Match<U>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, U>): TMatchResult<U>;
var
  matchResult: TMatchResult<U>;
begin
  matchResult.IsOk := FIsOk;

  if FIsOk then
    matchResult.Value := OnOk(FValue)  // Passa FValue para a função OnOk
  else
    matchResult.Value := OnErr(FError); // Passa FError para a função OnErr

  Result := matchResult;
end;


- **OnOk**: Função a ser executada se a operação for bem-sucedida. Recebe o valor de sucesso (`T`) e retorna um resultado (`U`).
- **OnErr**: Função a ser executada se a operação resultar em erro. Recebe o objeto `TErrResult` e retorna um resultado (`U`).
- **Retorno**: Um `TMatchResult<U>` contendo o resultado da função executada e um indicador se foi sucesso ou erro.


## Como Utilizar

A seguir, apresentamos um exemplo de como utilizar a unit `ResultMatching` para tratar resultados de operações que podem ter sucesso ou falhar.

### Exemplo de Uso

```delphi
uses
  ResultMatching, System.SysUtils, Vcl.Dialogs;

procedure TestPatternMatching;
var
  resultSuccess: TResultOptions<Integer>;
  resultError: TResultOptions<Integer>;
  matchResult: TMatchResult<string>;
  error: TErrResult;
begin
  // Simulando um sucesso
  resultSuccess := 10; // Utilizando o operador implícito

  // Utilizando o método Match para tratar o resultado
  matchResult := resultSuccess.Match<string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + Value.ToString;
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro ' + Err.Code.ToString + ': ' + Err.Description;
    end
  );

  // Exibindo o resultado
  if matchResult.IsOk then
    ShowMessage(matchResult.Value)
  else
    ShowMessage(matchResult.Value);

  // Simulando um erro
  error := TErrResult.Create(404, 'Recurso não encontrado');
  resultError := error; // Utilizando o operador implícito

  // Utilizando o método Match para tratar o erro
  matchResult := resultError.Match<string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + Value.ToString;
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro ' + Err.Code.ToString + ': ' + Err.Description;
    end
  );

  // Exibindo o erro
  if matchResult.IsOk then
    ShowMessage(matchResult.Value)
  else
    ShowMessage(matchResult.Value);
end;


### Passo a Passo do Exemplo

#### Simulando um Sucesso:

1. Atribuímos o valor `10` a `resultSuccess`, criando um `TResultOptions<Integer>` representando sucesso.
2. Utilizamos o método `Match<string>` passando duas funções anônimas:
   - **OnOk**: Recebe o valor de sucesso (`Integer`) e retorna uma string de sucesso.
   - **OnErr**: Recebe o objeto `TErrResult` e retorna uma string de erro.
3. Exibimos a mensagem de sucesso resultante.

#### Simulando um Erro:

1. Criamos uma instância de `TErrResult` com código `404` e descrição `'Recurso não encontrado'`.
2. Atribuímos o objeto `error` a `resultError`, criando um `TResultOptions<Integer>` representando erro.
3. Utilizamos novamente o método `Match<string>` com as mesmas funções anônimas.
4. Exibimos a mensagem de erro resultante.

## Considerações Finais

- **Flexibilidade**: A utilização de tipos genéricos permite que a estrutura `ResultMatching` seja reutilizável para diferentes tipos de operações e resultados, aumentando a flexibilidade do código.
  
- **Segurança**: Os métodos de acesso (`Value` e `Error`) garantem que o valor de sucesso ou o erro sejam acessados de forma segura, prevenindo acessos incorretos que podem levar a exceções não tratadas.

- **Legibilidade**: O método `Match` permite que o tratamento de resultados seja feito de forma clara e concisa, melhorando a legibilidade e a manutenção do código.

- **Extensibilidade**: A estrutura pode ser facilmente estendida para suportar diferentes tipos de erros ou resultados adicionais, conforme as necessidades do projeto.

Com esta unit, você pode implementar um sistema robusto de gerenciamento de resultados em suas aplicações Delphi, facilitando o tratamento de operações que podem falhar e melhorando a qualidade e a organização do seu código.

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
