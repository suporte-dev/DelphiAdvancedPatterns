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

  // Classe que encapsula detalhes mais espec�ficos sobre um erro
  TErrResult = class
  private
    FCode: Integer;
    FDescription: string;
  public
    constructor Create(ACode: Integer; ADescription: string);
    property Code: Integer read FCode;
    property Description: string read FDescription;
  end;

  // Record gen�rico para armazenar o resultado do Match
  TMatchResult<U> = record
    IsOk: Boolean;
    Value: U;
  end;

  // Record gen�rico que representa uma opera��o que pode ser bem-sucedida ou falhar
  TResultOptions<T> = record
  private
    FValue: T;
    FError: TErrResult;
    FIsOk: Boolean;
    procedure InitOk(AValue: T);
    procedure InitErr(AError: TErrResult);
  public
    // Operadores impl�citos para facilitar a cria��o de TResultOptions
    class operator Implicit(AValue: T): TResultOptions<T>;
    class operator Implicit(AError: TErrResult): TResultOptions<T>;

    // M�todos para verificar o estado da opera��o
    function IsOk: Boolean;
    function IsErr: Boolean;

    // M�todos para acessar o valor ou o erro
    function Value: T;
    function Error: TErrResult;

    // M�todo Match para implementar o Pattern Matching
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
    raise Exception.Create('Nenhum valor dispon�vel. A opera��o resultou em erro.');
  Result := FValue;
end;

function TResultOptions<T>.Error: TErrResult;
begin
  if FIsOk then
    raise Exception.Create('Nenhum erro. A opera��o foi bem-sucedida.');
  Result := FError;
end;

function TResultOptions<T>.Match<U>(OnOk: TFunc<T, U>; OnErr: TFunc<TErrResult, U>): TMatchResult<U>;
var
  matchResult: TMatchResult<U>;
begin
  matchResult.IsOk := FIsOk;

  if FIsOk then
    matchResult.Value := OnOk(FValue)  // Passamos FValue para a fun��o OnOk
  else
    matchResult.Value := OnErr(FError); // Passamos FError para a fun��o OnErr

  Result := matchResult;
end;

end.

