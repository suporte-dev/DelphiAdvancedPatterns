unit ResultMatching;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils;

type
  // Classe que encapsula uma mensagem de erro simples
  TError = class
  private
    FMessage: string;
  public
    constructor Create(AMessage: string);
    property Message: string read FMessage;
  end;

  // Classe que encapsula detalhes mais específicos sobre um erro
  TErrResult = class
  private
    FCode: Integer;
    FDescription: string;
  public
    constructor Create(ACode: Integer; ADescription: string);
    property Code: Integer read FCode;
    property Description: string read FDescription;
  end;

  // Record genérico para armazenar o resultado do Match
  TMatchResult<U> = record
    IsOk: Boolean;
    Value: U;
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

    // Método Match para implementar o Pattern Matching
    function Match<U>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, U>): TMatchResult<U>;
  end;

implementation

{ TError }

constructor TError.Create(AMessage: string);
begin
  FMessage := AMessage;
end;

{ TErrResult }

constructor TErrResult.Create(ACode: Integer; ADescription: string);
begin
  FCode := ACode;
  FDescription := ADescription;
end;

{ TResultOptions<T> }

procedure TResultOptions<T>.InitOk(AValue: T);
begin
  FValue := AValue;
  FIsOk := True;
  FError := nil;
end;

procedure TResultOptions<T>.InitErr(AError: TErrResult);
begin
  FIsOk := False;
  FError := AError;
end;

class operator TResultOptions<T>.Implicit(AValue: T): TResultOptions<T>;
begin
  Result.InitOk(AValue);
end;

class operator TResultOptions<T>.Implicit(AError: TErrResult): TResultOptions<T>;
begin
  Result.InitErr(AError);
end;

function TResultOptions<T>.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TResultOptions<T>.IsErr: Boolean;
begin
  Result := not FIsOk;
end;

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

function TResultOptions<T>.Match<U>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, U>): TMatchResult<U>;
var
  matchResult: TMatchResult<U>;
begin
  matchResult.IsOk := FIsOk;

  if FIsOk then
    matchResult.Value := OnOk(FValue)  // Passamos FValue para a função OnOk
  else
    matchResult.Value := OnErr(FError); // Passamos FError para a função OnErr

  Result := matchResult;
end;

end.

