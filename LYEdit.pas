{**********************************************************}
{                                                          }
{  TLYEdit Component Version 06.09.30                      }
{  作者：刘鹰                                              }
{                                                          }
{  新功能：                                                }
{  1.20230224,支持MySQL、Oracle数据库连接.依赖UniDAC组件   }
{                                                          }
{                                                          }
{                                                          }
{                                                          }
{                                                          }
{  他是一个免费软件,如果你修改了他,希望我能有幸看到你的杰作}
{                                                          }
{  我的 Email: Liuying1129@163.com                         }
{                                                          }
{  版权所有,欲进行商业用途,请与我联系!!!                   }
{                                                          }
{                                                          }
{  新功能：                                                }
{                                                          }
{  BUG:1.                                                  }
{**********************************************************}

unit LYEdit;

interface

uses
  StdCtrls{TEdit},Buttons{TSpeedButton},FileCtrl{SelectDirectory},
  ExtCtrls{TCustomPanel},Controls{TCaption},Classes{tcomponent},
  ADODB{TADOConnection},AdoConEd{EditConnectionString},Windows{TRect},
  Messages{EM_SETRECTNP},Dialogs{TOpenDialog},SysUtils{IntToStr},
  Uni{TUniConnection},UniDacVcl{TUniConnectDialog},
  MySQLUniProvider{Provider显示MySQL},OracleUniProvider{Provider显示Oracle};

type
  TEditType=(etDir,etFile,etDBConn,etUniConn);

type
  TLYEdit = class(TCustomEdit)
  private
    { Private declarations }
    FSpeedButton:TSpeedButton;
    fEditType:TEditType;
    fFilter:string;
    procedure SetEditRect;
    procedure fsetEditType(v:TEditType);
    procedure fsetFilter(v:string);
    PROCEDURE SpeedButtonCLICK(SENDER:TOBJECT);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor create(AOwner:tcomponent);override;
    procedure createwnd;override;
    destructor destroy;override;
  published
    { Published declarations }
    property PasswordChar;//add by liuying 20081023
    property Text;
    property EditType:TEditType read fEditType write fsetEditType;
    property Filter:string read fFilter write fsetFilter;//如:*.bak|*.bak|所有文件|*.*
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Eagle_Ly', [TLYEdit]);
end;

{ TLYDirBtnEdit }

constructor TLYEdit.Create(AOwner: tcomponent);
begin
  inherited Create(AOwner);

  FSpeedButton:=TSpeedButton.Create(self);
  FSpeedButton.Parent:=self;
  FSpeedButton.Align:=alright;
  FSpeedButton.Caption:='...';
  FSpeedButton.OnClick:=SpeedButtonCLICK;
end;

procedure TLYEdit.createwnd;
begin
  inherited createwnd;
  SetEditRect;
end;

destructor TLYEdit.destroy;
begin
  FSpeedButton.Free;
  inherited;
end;

procedure TLYEdit.SpeedButtonCLICK(sender: tobject);
var
  Dir:string;
  tmpOpenDialog:TOpenDialog;
  tmpADOConnection:TADOConnection;
  UniConnection1: TUniConnection;
  UniConnectDialog1:TUniConnectDialog;
begin
  if fEditType=etDBConn then//数据库连接字符串
  begin
    tmpADOConnection:=TADOConnection.Create(self);
    tmpADOConnection.ConnectionString:=Text;
    if EditConnectionString(tmpADOConnection) then
      Text:=tmpADOConnection.ConnectionString;
    tmpADOConnection.Close;
    tmpADOConnection.Free;
  end;
  if fEditType=etUniConn then//UniDAC数据库连接字符串
  begin
    UniConnection1:=TUniConnection.Create(self);
    //ProviderName为Oracle,Direct默认值是False
    //故必须初始化ProviderName为Oracle及设置Direct为True
    //Bug:如果再来一种Direct默认值为False的数据库,要如何设置呢?
    UniConnection1.ProviderName:='Oracle';
    UniConnection1.SpecificOptions.Values['Direct']:='True';
    UniConnectDialog1:=TUniConnectDialog.Create(self);
    UniConnection1.ConnectDialog:=UniConnectDialog1;
    //Provider Name为Oracle时,Server属性格式:Host IP:Port:SID,如10.195.252.13:1521:kthis1
    //Oracle的默认Port为1521
    //查询Oracle SID:select instance_name from V$instance;
    UniConnection1.Connect;
    if UniConnection1.Connected then
      Text:=UniConnection1.ConnectString+';Login Prompt=False';
    UniConnection1.Close;
    UniConnectDialog1.Free;
    UniConnection1.Free;
  end;
  if fEditType=etDir then//目录
  begin
    if SelectDirectory('','',Dir) then
      Text:=Dir;
  end;
  if fEditType=etFile then//文件
  begin
    tmpOpenDialog:=TOpenDialog.Create(nil);
    tmpOpenDialog.Filter:=fFilter;
    tmpOpenDialog.InitialDir:=Text;
    if tmpOpenDialog.Execute then
      Text:=tmpOpenDialog.FileName;
    tmpOpenDialog.Free;
  end;
end;

procedure TLYEdit.fsetEditType(v: TEditType);
begin
  if v=fEditType then exit;
  fEditType:=v;
end;

procedure TLYEdit.fsetFilter(v: string);
begin
  if v=fFilter then exit;
  fFilter:=v;
end;

procedure TLYEdit.SetEditRect;
var
  Loc: TRect;
begin
  //SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FSpeedButton.Width - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  //SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;//}

procedure TLYEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE ;//or WS_CLIPCHILDREN;//
end;

end.
