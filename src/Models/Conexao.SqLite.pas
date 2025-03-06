unit Conexao.SqLite;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, System.IOUtils, inifiles,
  Interfaces.Conexao, Conexao.Padrao;

{DriverID = SQLITE}
type
  TConexaoSqLite = class(TConexaoPadrao)
  protected
    DriverLink: TFDPhysSQLiteDriverLink;
    procedure SetDriverLink; override;
    procedure GetConexao; override;
  public
    class function New: IConexao;
    function GetSqlNextId: string; override;
    function GetSqlRecuperaId: string; override;
  end;

implementation


{ TConexaoSqLite }

procedure TConexaoSqLite.SetDriverLink;
begin
  DriverLink := TFDPhysSQLiteDriverLink.Create(nil);
end;

function TConexaoSqLite.GetSqlNextId: string;
begin
  Result := 'SELECT IfNull(MAX(ID), 0) + 1 AS MAX FROM %s';
end;

function TConexaoSqLite.GetSqlRecuperaId: string;
begin
  Result := 'SELECT last_insert_rowid() ID;'
end;

class function TConexaoSqLite.New: IConexao;
begin
  Result := TConexaoSqLite.Create;
end;

procedure TConexaoSqLite.GetConexao;
begin
  FConnection := TFDConnection.Create(nil);
  GetDatabaseNameFromIni();
  SetDriverLink;
  Transaction := TFDTransaction.Create(nil);
  FConnection.TxOptions.AutoCommit := False;
  Transaction.Connection := FConnection;
  FConnection.Params.Values['DriverID'] := 'SQLite';
  FConnection.Params.Values['Database'] := IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir) + 'banco.db';
  FConnection.Connected := True;
end;

end.
