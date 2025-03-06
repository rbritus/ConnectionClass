unit Conexao.Padrao;

interface

uses
  System.SysUtils,  System.Classes,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Comp.Client,  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf,
  DB, Datasnap.DBClient, Datasnap.Provider, FireDAC.DApt, inifiles,
  Interfaces.Conexao,  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  TConexaoPadrao = class(TInterfacedObject, IConexao)
  protected
    FConnection: TFDConnection;
    Transaction: TFDTransaction;
    FDriver: string;
    FDataBase: string;
    FUserName: string;
    FPassword: string;
    FServer: string;
    FPort: string;
    FLib: string;
    procedure GetConexao(); virtual;
    procedure SetDriverLink; virtual; abstract;
    constructor Create;
    function GetDatabaseNameFromIni(): string;
  public
    function GetSqlNextId: string; virtual; abstract;
    function GetSqlRecuperaId: string; virtual; abstract;
    procedure CommitRetaining;
    procedure RollbackRetaining;
    procedure Close;
    function InTransaction: Boolean;
    procedure StartTransaction;
    function Connection: TFDConnection;
  end;

implementation

{ TConexaoPadrao }

procedure TConexaoPadrao.Close;
begin
  FConnection.Close;
end;

procedure TConexaoPadrao.CommitRetaining;
begin
  FConnection.CommitRetaining;
end;

function TConexaoPadrao.Connection: TFDConnection;
begin
  Result := FConnection;
end;

constructor TConexaoPadrao.Create;
begin
  GetConexao();
end;

procedure TConexaoPadrao.GetConexao;
begin
  FConnection := TFDConnection.Create(nil);
  Transaction := TFDTransaction.Create(nil);
  Transaction.Connection := FConnection;
  GetDatabaseNameFromIni();
  SetDriverLink;
  FConnection.TxOptions.AutoCommit := False;
  FConnection.Params.Values['DriverID'] := FDriver;
  FConnection.Params.Values['Database'] := FDataBase;
  FConnection.Params.Values['User_Name'] := FUserName;
  FConnection.Params.Values['Password'] := FPassword;
  FConnection.Params.Values['Server'] := FServer;
  FConnection.Params.Values['Port'] := FPort;
  FConnection.Connected := True;
end;

function TConexaoPadrao.GetDatabaseNameFromIni: string;
begin
  var appINI: TMemIniFile;
  var Diretorio := IncludeTrailingPathDelimiter(System.SysUtils.GetCurrentDir);
  appINI := TMemIniFile.Create(Diretorio + 'app.ini',TEncoding.UTF8);
  FDriver := appINI.ReadString('Conexao', 'driver', EmptyStr);
  FDataBase := appINI.ReadString('Conexao', 'database', EmptyStr);
  FUserName := appINI.ReadString('Conexao', 'username', EmptyStr);
  FPassword := appINI.ReadString('Conexao', 'password', EmptyStr);
  FServer := appINI.ReadString('Conexao', 'server', EmptyStr);
  FPort := appINI.ReadString('Conexao', 'port', EmptyStr);
  FLib := appINI.ReadString('Conexao', 'lib', EmptyStr);
  appINI.Free;
end;

function TConexaoPadrao.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

procedure TConexaoPadrao.RollbackRetaining;
begin
  FConnection.RollbackRetaining;
end;

procedure TConexaoPadrao.StartTransaction;
begin
  FConnection.StartTransaction;
end;

end.
