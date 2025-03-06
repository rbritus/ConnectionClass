unit Interfaces.Conexao;

interface

uses
  FireDAC.Comp.Client;

type

  IConexao = interface
    ['{A2E39FF7-6DBA-4BE6-85BE-E432BD1837D6}']
    function GetSqlNextId: string;
    function GetSqlRecuperaId: string;
    procedure CommitRetaining;
    procedure RollbackRetaining;
    procedure Close;
    function InTransaction: Boolean;
    procedure StartTransaction;
    function Connection: TFDConnection;
  end;

implementation

end.
