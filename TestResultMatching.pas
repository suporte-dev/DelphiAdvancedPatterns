unit TestResultMatching;

interface

uses
  TestFramework, // DUnit framework
  ResultMatching, // A unit que estamos testando
  SysUtils;

type
  // Classe de teste para TResultOptions
  TestTResultOptions = class(TTestCase)
  published
    // Testes usando functions (com retorno de valor)
    procedure TestMatchWithFunctionsSuccess;
    procedure TestMatchWithFunctionsError;

    // Testes usando procedures anônimas (sem retorno de valor)
    procedure TestMatchWithProceduresSuccess;
    procedure TestMatchWithProceduresError;
  end;

implementation

{ TestTResultOptions }

// Teste para um caso de sucesso usando functions
procedure TestTResultOptions.TestMatchWithFunctionsSuccess;
var
  LResult: TResultOptions<Integer>;
  MatchResult: TMatchResult<string, string>;
begin
  LResult := 10;

  MatchResult := LResult.Match<string, string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  CheckTrue(MatchResult.IsOk, 'O resultado do Match deveria ser Ok.');
  CheckEquals('Sucesso: 10', MatchResult.OkValue, 'A mensagem de sucesso deveria ser "Sucesso: 10".');
end;

// Teste para um caso de erro usando functions
procedure TestTResultOptions.TestMatchWithFunctionsError;
var
  Error: TErrResult;
  LResult: TResultOptions<Integer>;
  MatchResult: TMatchResult<string, string>;
begin
  Error := TErrResult.Create(500, 'Erro Interno');
  LResult := Error;

  MatchResult := LResult.Match<string, string>(
    function(Value: Integer): string
    begin
      Result := 'Sucesso: ' + IntToStr(Value);
    end,
    function(Err: TErrResult): string
    begin
      Result := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  CheckFalse(MatchResult.IsOk, 'O resultado do Match deveria ser Err.');
  CheckEquals('Erro: 500: Erro Interno', MatchResult.ErrValue, 'A mensagem de erro deveria ser "Erro: 500: Erro Interno".');
end;

// Teste para um caso de sucesso usando procedures anônimas
procedure TestTResultOptions.TestMatchWithProceduresSuccess;
var
  LResult: TResultOptions<Integer>;
  SuccessMessage: string;
begin
  LResult := 10;

  LResult.MatchProcedures(
    procedure(Value: Integer)
    begin
      SuccessMessage := 'Sucesso: ' + IntToStr(Value);
    end,
    procedure(Err: TErrResult)
    begin
      SuccessMessage := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  CheckEquals('Sucesso: 10', SuccessMessage, 'A mensagem de sucesso deveria ser "Sucesso: 10".');
end;

// Teste para um caso de erro usando procedures anônimas
procedure TestTResultOptions.TestMatchWithProceduresError;
var
  Error: TErrResult;
  LResult: TResultOptions<Integer>;
  ErrorMessage: string;
begin
  Error := TErrResult.Create(404, 'Recurso não encontrado');
  LResult := Error;

  LResult.MatchProcedures(
    procedure(Value: Integer)
    begin
      ErrorMessage := 'Sucesso: ' + IntToStr(Value);
    end,
    procedure(Err: TErrResult)
    begin
      ErrorMessage := 'Erro: ' + IntToStr(Err.Code) + ': ' + Err.Description;
    end
  );

  CheckEquals('Erro: 404: Recurso não encontrado', ErrorMessage, 'A mensagem de erro deveria ser "Erro: 404: Recurso não encontrado".');
end;

initialization
  // Registro da suite de testes
  RegisterTest(TestTResultOptions.Suite);

end.
