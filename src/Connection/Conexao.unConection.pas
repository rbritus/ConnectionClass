unit Conexao.unConection;

interface

uses
  {$REGION 'Units Delphi'}
  System.SysUtils, System.Classes,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Comp.Client,  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf,
  DB, Datasnap.DBClient, Datasnap.Provider, FireDAC.DApt, inifiles,
  System.StrUtils, System.Generics.Collections, FireDAC.Stan.Param,

  {$IFDEF MSWINDOWS}
    Windows, Vcl.Forms,
  {$ELSE}

  {$ENDIF}

  {$ENDREGION}
  {$REGION 'Units Projeto'}
  Interfaces.Conexao;
  {$ENDREGION}

type
  TQuery = class(TFDQuery);

  TConexao = class
  private
    class var FInstance: TConexao;
    class var FConection: IConexao;
    FConectionSolitaria: IConexao;
    function GetDriver: string;
    function GetSqlNextId: string;
    procedure PreencherQuery(AQuery: TQuery; const Params: TDictionary<String, Variant>);
    function GetConection: IConexao;
  public
    function Conection: IConexao;
    function GetQuery: TQuery;
    function GetNextId(TableName, CampoId: String): Integer;
    function GetQueryConsulta(ASql: String): TDataSet; overload;
    function GetQueryConsulta(ASql: String; const Params: TDictionary<String, Variant>): TDataSet; overload;
    function GetSqlRecuperaID: string;

    procedure Commit;
    procedure Rollback;
    procedure EnviarComando(ASql: String); overload;
    procedure EnviarComando(ASql: String; const Params: TDictionary<String, Variant>); overload;
    procedure FecharConexao();


    class procedure ConexaoSolitaria(AProc: TProc<TConexao>);
    class procedure ConexaoSolitariaDePersistencia(AProc: TProc<TConexao>);
    class function New: TConexao;
    constructor Create;
  end;

implementation

uses
  Conexao.MySql,
  Conexao.SqLite,
  Conexao.Firebird;

{ TConexao }

function TConexao.Conection: IConexao;
begin
  Result := FConection;
  if Assigned(FConectionSolitaria) then
    Result := FConectionSolitaria
end;

class procedure TConexao.ConexaoSolitaria(AProc: TProc<TConexao>);
var
  lInstance: TConexao;
  lConection: IConexao;
begin
  lInstance := TConexao(Inherited NewInstance);
  try
    lConection := FInstance.GetConection;
    try
      FConectionSolitaria := lConection;
      AProc(lInstance);
    except
      on E: Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    lInstance.Free;
  end;
end;

class procedure TConexao.ConexaoSolitariaDePersistencia(AProc: TProc<TConexao>);
var
  lInstance: TConexao;
  lConection: IConexao;
begin
  lInstance := TConexao(Inherited NewInstance);
  try
    lConection := FInstance.GetConection;
    try
      FConectionSolitaria := lConection;
      AProc(lInstance);
      lConection.CommitRetaining;
    except
      on E: Exception do
      begin
        raise Exception.Create(E.Message);
        lConection.RollbackRetaining;
      end;
    end;
  finally
    lInstance.Free;
  end;
end;

constructor TConexao.Create;
begin
  FConection := FInstance.GetConection;
  if not FConection.InTransaction then
    FConection.StartTransaction;
end;

procedure TConexao.Commit;
begin
  Self.Conection.CommitRetaining;
end;

procedure TConexao.EnviarComando(ASql: String; const Params: TDictionary<String, Variant>);
begin
  var MyDataSet := GetQuery;
  try
    MyDataSet.SQL.Add(ASql);
    PreencherQuery(MyDataSet,Params);
    try
      MyDataSet.ExecSQL;
    except
      on E: Exception do
      begin
        Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
    MyDataSet.Close;
  finally
    MyDataSet.Free;
  end;
end;

procedure TConexao.EnviarComando(ASql: String);
begin
  var MyDataSet := GetQuery;
  try
    try
      MyDataSet.ExecSQL(ASql);
    except
      on E: Exception do
      begin
        Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
    MyDataSet.Close;
  finally
    MyDataSet.Free;
  end;
end;

procedure TConexao.FecharConexao;
begin
  Self.Conection.Close;
end;

class function TConexao.New: TConexao;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TConexao(Inherited NewInstance);
    FInstance.Create;
    if not Assigned(FConection) then
      FConection := FInstance.GetConection;
  end;

  if not FConection.InTransaction then
    FConection.StartTransaction;

  Result := FInstance;
end;

procedure TConexao.Rollback;
begin
  Self.Conection.RollbackRetaining;
end;

function TConexao.GetConection: IConexao;
const
  CONEXOES : array of string = ['MYSQL', 'SQLITE','FB'];
begin
  case AnsiIndexStr(GetDriver.ToUpper, CONEXOES) of
    0 : Exit(TConexaoMySql.New);
    1 : Exit(TConexaoSqLite.New);
    2 : Exit(TConexaoFirebird.New);
  else
    Result := nil;
  end;
end;

function TConexao.GetDriver: string;
begin
  var appINI: TMemIniFile;
  {$IFDEF MSWINDOWS}
  var Diretorio := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName));
  {$ELSE}
  var Diretorio := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
  {$ENDIF}
  appINI := TMemIniFile.Create(Diretorio + 'app.ini',TEncoding.UTF8);
  Result := appINI.ReadString('Conexao', 'driver', 'SqLite');
  appINI.Free;
end;

function TConexao.GetNextId(TableName, CampoId: String): Integer;
begin
  var lSql := GetSqlNextId;
  var Query: TFDQuery := GetQuery;
  try
    Query.Open(Format(lSql,[CampoId,TableName]));
    Result := Query.FieldByName('MAX').AsInteger;
    Query.Close;
  finally
    Query.Free;
  end;
end;

function TConexao.GetSqlNextId: string;
begin
  Self.Conection.GetSqlNextId;
end;

function TConexao.GetSqlRecuperaID: string;
begin
  Self.Conection.GetSqlRecuperaId;
end;

function TConexao.GetQuery: TQuery;
begin
  var Query := TFDQuery.Create(nil);
  Query.Connection := Self.Conection.Connection;
  Result := TQuery(Query);
end;

Function TConexao.GetQueryConsulta(ASql: String): TDataSet;
Begin
  var MyDataSet := GetQuery;
  MyDataSet.Open(ASql);
  Result := MyDataSet;
End;

Function TConexao.GetQueryConsulta(ASql: String; const Params: TDictionary<String, Variant>): TDataSet;
Begin
  var MyDataSet := GetQuery;
  try
    MyDataSet.SQL.Add(ASql);
    PreencherQuery(MyDataSet,Params);
    MyDataSet.Open();
  finally
    Result := MyDataSet;
  end;
End;

procedure TConexao.PreencherQuery(AQuery: TQuery; const Params: TDictionary<String, Variant>);
begin
  for var I in Params.Keys do
    if not (AQuery.Params.FindParam(I) = nil) then
      AQuery.ParamByName(I).Value := Params.Items[I];
end;

end.
