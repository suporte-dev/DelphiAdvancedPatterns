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
  end;

implementation

{ TestTResultOptions }

procedure TestTResultOptions.TestImplicitOk;
var
  Result: TResultOptions<Integer>;
begin
  Result := 10; // Implicitamente cria um TResultOptions com sucesso
  CheckTrue(Result.IsOk, 'O resultado deveria ser Ok.');
  CheckEquals(10, Result.Value, 'O valor esperado é 10.');
end;

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

procedure TestTResultOptions.TestIsOk;
var
  Result: TResultOptions<Integer>;
begin
  Result := 10;
  CheckTrue(Result.IsOk, 'O resultado deveria ser Ok.');
end;

procedure TestTResultOptions.TestIsErr;
var
  Error: TErrResult;
  Result: TResultOptions<Integer>;
begin
  Error := TErrResult.Create(500, 'Internal Error');
  Result := Error;
  CheckTrue(Result.IsErr, 'O resultado deveria ser Err.');
end;

procedure TestTResultOptions.TestValueSuccess;
var
  Result: TResultOptions<Integer>;
begin
  Result := 42;
  CheckEquals(42, Result.Value, 'O valor esperado é 42.');
end;

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

initialization
  // Registro da suite de testes
  RegisterTest(TestTResultOptions.Suite);

end.

