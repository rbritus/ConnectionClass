unit Conexao.MySql;

interface

uses
  System.SysUtils,  System.Classes,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf,
  DB, Datasnap.DBClient, Datasnap.Provider, FireDAC.DApt, inifiles,
  Interfaces.Conexao, Conexao.Padrao;

{DriverID = MySQL}
type
  TConexaoMySql = class(TConexaoPadrao)
  protected
    DriverLink: TFDPhysMySQLDriverLink;
    procedure SetDriverLink; override;
  public
    class function New: IConexao;
    function GetSqlNextId: string; override;
    function GetSqlRecuperaId: string; override;
  end;

implementation



{ TConexaoMySql }

function TConexaoMySql.GetSqlNextId: string;
begin
  Result := 'SELECT IfNull(MAX(%s), 0) + 1 AS MAX FROM %s';
end;

function TConexaoMySql.GetSqlRecuperaId: string;
begin
  Result := 'SELECT last_insert_id() ID;';
end;

class function TConexaoMySql.New: IConexao;
begin
  Result := TConexaoMySql.Create;
end;

procedure TConexaoMySql.SetDriverLink;
begin
  inherited;
  DriverLink := TFDPhysMySQLDriverLink.Create(nil);
  DriverLink.VendorLib := FLib;
end;

end.
