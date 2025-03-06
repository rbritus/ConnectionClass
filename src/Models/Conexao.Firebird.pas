unit Conexao.Firebird;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase, Datasnap.DBClient, Datasnap.Provider, FireDAC.DApt,
  inifiles, Interfaces.Conexao, Conexao.Padrao;

{DriverID = FB}
type
  TConexaoFirebird = class(TConexaoPadrao)
  protected
    DriverLink: TFDPhysFBDriverLink;
    procedure SetDriverLink; override;
  public
    class function New: IConexao;
    function GetSqlNextId: string; override;
    function GetSqlRecuperaId: string; override;
  end;

implementation



{ TConexaoFirebird }

procedure TConexaoFirebird.SetDriverLink;
begin
  DriverLink := TFDPhysFBDriverLink.Create(nil);
  DriverLink.VendorLib := FLib;
end;

function TConexaoFirebird.GetSqlNextId: string;
begin
  Result := 'SELECT COALESCE(MAX(%s), 0) + 1 AS "MAX" FROM %s';
end;

function TConexaoFirebird.GetSqlRecuperaId: string;
begin
  Result := 'RETURNING ID;';
end;

class function TConexaoFirebird.New: IConexao;
begin
  Result := TConexaoFirebird.Create();
end;

end.
