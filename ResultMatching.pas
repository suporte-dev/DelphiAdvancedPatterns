unit ResultMatching;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  // Record que encapsula detalhes mais específicos sobre um erro
  TErrResult = record
  private
    FCode: Integer;
    FDescription: string;
  public
    // Construtor para inicializar o record
    constructor Create(ACode: Integer; ADescription: string);

    // Operador implicit para facilitar a criação de erros
    class operator Implicit(AError: string): TErrResult;
    class operator Implicit(ACode: Integer): TErrResult;

    property Code: Integer read FCode;
    property Description: string read FDescription;
  end;

  // Record genérico para armazenar o resultado do Match
  TMatchResult<U, E> = record
    IsOk: Boolean;
    OkValue: U;
    ErrValue: E;
  end;

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

    // Método Match para functions (Pattern Matching com retorno)
    function Match<U, E>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, E>): TMatchResult<U, E>;

    // Método Match para procedures anônimas (Pattern Matching sem retorno)
    procedure MatchProcedures(OnOk: TProc<T>; OnErr: TProc<TErrResult>);
  end;

implementation

{ TErrResult }

// Construtor para inicializar o record
constructor TErrResult.Create(ACode: Integer; ADescription: string);
begin
  FCode := ACode;
  FDescription := ADescription;
end;

// Operador implicit para converter uma string em TErrResult
class operator TErrResult.Implicit(AError: string): TErrResult;
begin
  Result := TErrResult.Create(0, AError);  // Erro genérico com código 0
end;

// Operador implicit para converter um integer em TErrResult
class operator TErrResult.Implicit(ACode: Integer): TErrResult;
begin
  Result := TErrResult.Create(ACode, 'Erro desconhecido');
end;

{ TResultOptions<T> }

// Inicializa com sucesso
procedure TResultOptions<T>.InitOk(AValue: T);
begin
  FValue := AValue;
  FIsOk := True;
  FError := '';  // Sem erro
end;

// Inicializa com erro
procedure TResultOptions<T>.InitErr(AError: TErrResult);
begin
  FIsOk := False;
  FError := AError;
end;

// Operador implicit para converter um valor genérico em TResultOptions
class operator TResultOptions<T>.Implicit(AValue: T): TResultOptions<T>;
begin
  Result.InitOk(AValue);
end;

// Operador implicit para converter TErrResult em TResultOptions
class operator TResultOptions<T>.Implicit(AError: TErrResult): TResultOptions<T>;
begin
  Result.InitErr(AError);
end;

// Verifica se o resultado foi um sucesso
function TResultOptions<T>.IsOk: Boolean;
begin
  Result := FIsOk;
end;

// Verifica se o resultado foi um erro
function TResultOptions<T>.IsErr: Boolean;
begin
  Result := not FIsOk;
end;

// Retorna o valor em caso de sucesso, ou levanta uma exceção se houver erro
function TResultOptions<T>.Value: T;
begin
  if not FIsOk then
    raise Exception.Create('Nenhum valor disponível. A operação resultou em erro.');
  Result := FValue;
end;

// Retorna o erro em caso de falha, ou levanta uma exceção se houve sucesso
function TResultOptions<T>.Error: TErrResult;
begin
  if FIsOk then
    raise Exception.Create('Nenhum erro. A operação foi bem-sucedida.');
  Result := FError;
end;

// Método Match com functions (Pattern Matching com retorno de valor)
function TResultOptions<T>.Match<U, E>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, E>): TMatchResult<U, E>;
var
  matchResult: TMatchResult<U, E>;
begin
  matchResult.IsOk := FIsOk;

  if FIsOk then
    matchResult.OkValue := OnOk(FValue)  // Executa OnOk e atribui o retorno a OkValue
  else
    matchResult.ErrValue := OnErr(FError); // Executa OnErr e atribui o retorno a ErrValue

  Result := matchResult;
end;

// Método Match com procedures anônimas (Pattern Matching sem retorno de valor)
procedure TResultOptions<T>.MatchProcedures(OnOk: TProc<T>; OnErr: TProc<TErrResult>);
begin
  if FIsOk then
    OnOk(FValue)  // Executa a procedure para o caso de sucesso
  else
    OnErr(FError); // Executa a procedure para o caso de erro
end;

end.
