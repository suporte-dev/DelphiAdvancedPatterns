# DelphiAdvancedPatterns

## Visão Geral

**DelphiAdvancedPatterns** é um repositório que fornece uma coleção de units para Delphi, introduzindo padrões avançados e abordagens inovadoras para facilitar o desenvolvimento de aplicações robustas e escaláveis. Atualmente inclui a unit `ResultMatching`, que implementa um sistema de pattern matching para o tratamento eficiente de resultados de operações.

## Features

- **ResultMatching**: Implementação genérica para gerenciamento de resultados com pattern matching.
- **TErrResult**: Classe para encapsular detalhes de erros.
- **TMatchResult**: Estrutura para armazenar resultados de operações.
- **TResultOptions**: Record para representar operações que podem ter sucesso ou falhar.

## Como Utilizar

### Exemplo de Uso da Unit `ResultMatching`

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
  resultSuccess := 10;

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
  resultError := error;

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
```

Veja o código completo na unit ResultMatching.pas



