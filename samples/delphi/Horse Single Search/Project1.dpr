program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  Conexao.unConection in '..\..\..\src\Connection\Conexao.unConection.pas',
  Interfaces.Conexao in '..\..\..\src\Interfaces\Interfaces.Conexao.pas',
  Conexao.Firebird in '..\..\..\src\Models\Conexao.Firebird.pas',
  Conexao.MySql in '..\..\..\src\Models\Conexao.MySql.pas',
  Conexao.Padrao in '..\..\..\src\Models\Conexao.Padrao.pas',
  Conexao.SqLite in '..\..\..\src\Models\Conexao.SqLite.pas',
  Data.DB;

begin

  THorse.Get('/hello',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      var retorno := '';
       TConexao.ConexaoSolitaria(
          procedure (AConexao: TConexao)
          var
            qry: TDataSet;
          begin
            qry := AConexao.GetQueryConsulta('SELECT * FROM CLIENTE');
            try
              while not qry.Eof do
              begin
                retorno := retorno + qry.FieldByName('NOME').AsString;
                qry.Next;
              end;
            finally
              qry.close;
              qry.Free;
            end;
          end
       );
      Res.Send(retorno);
    end
  );

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor rodando na porta: ' + THorse.Port.ToString);
    end
  );

end.
