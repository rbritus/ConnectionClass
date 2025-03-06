## ⚙️ Installation
A instalação é feita usando o commando [`boss install`](https://github.com/HashLoad/boss):
``` sh
boss install https://github.com/rbritus/ConnectionClass
```

# ConnectionClass
Componente de conexão multibanco

De início é necessário configura o arquivo App.ini existente no diretório "ConnectionClass\src\" do projeto.
Este arquivo define os parâmetros de conexão ao banco, exemplo do arquivo:

```
[Conexao]
driver=SQLITE
database=..\BANCO.FDB
username=SYSDBA
password=masterkey
server=127.0.0.1
port=3050
lib=C:\Program Files (x86)\Firebird\Firebird_3_0\fbclient.dll
```

Para utilizar a classe de conexão ao banco TConexao é necessário declarar a unit "Conexao.unConnection" no seu Uses.
Em aplicações desktop pode-se utilizar o método TConexao.New, isto retornará os métodos da conexão atual utilizando o padrão singleton.

Ex:
```delphi
uses
  Conexao.unConnection;

procedure TForm.Inserir;
begin
  try
    TConexao.New.EnviarComando('insert into tab_teste values (1,''NOME'')');
    TConexao.New.Commit;
  except
    TConexao.New.Rollback;
  end;
end;
```

Nos usos onde é necessário abrir e fechar uma conxão ao banco (casos como api's em Horse) pode-se utilizar os seguintes métodos:
-  class procedure ConexaoSolitaria(AProc: TProc<TConexao>);
-  class procedure ConexaoSolitariaDePersistencia(AProc: TProc<TConexao>);
-  
A partir destes dois métodos os comandos da classe de conexão passam a ser visíveis.
  
Ex:

```delphi
uses
  Conexao.unConnection;

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
  THorse.Listen(9000);
end.
```
