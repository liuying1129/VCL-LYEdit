{**********************************************************}
{                                                          }
{  TLYEdit Component Version 06.09.30                      }
{  ���ߣ���ӥ                                              }
{                                                          }
{  �¹��ܣ�                                                }
{  1.20230224,֧��MySQL��Oracle���ݿ�����.����UniDAC���   }
{                                                          }
{                                                          }
{                                                          }
{                                                          }
{                                                          }
{  ����һ��������,������޸�����,ϣ���������ҿ�����Ľ���}
{                                                          }
{  �ҵ� Email: Liuying1129@163.com                         }
{                                                          }
{  ��Ȩ����,��������ҵ��;,��������ϵ!!!                   }
{                                                          }
{                                                          }
{  �¹��ܣ�                                                }
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
  MySQLUniProvider{Provider��ʾMySQL},OracleUniProvider{Provider��ʾOracle};

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
    property Filter:string read fFilter write fsetFilter;//��:*.bak|*.bak|�����ļ�|*.*
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
  if fEditType=etDBConn then//���ݿ������ַ���
  begin
    tmpADOConnection:=TADOConnection.Create(self);
    tmpADOConnection.ConnectionString:=Text;
    if EditConnectionString(tmpADOConnection) then
      Text:=tmpADOConnection.ConnectionString;
    tmpADOConnection.Close;
    tmpADOConnection.Free;
  end;
  if fEditType=etUniConn then//UniDAC���ݿ������ַ���
  begin
    UniConnection1:=TUniConnection.Create(self);
    UniConnectDialog1:=TUniConnectDialog.Create(self);
    UniConnection1.ConnectDialog:=UniConnectDialog1;
    UniConnection1.Connect;
    if UniConnection1.Connected then
      Text:='ProviderName:'+UniConnection1.ProviderName+';Server:'+UniConnection1.Server+';Port:'+IntToStr(UniConnection1.Port)+';Username:'+UniConnection1.Username+';Password:'+UniConnection1.Password+';Database:'+UniConnection1.Database;
    UniConnection1.Close;
    UniConnectDialog1.Free;
    UniConnection1.Free;
  end;
  if fEditType=etDir then//Ŀ¼
  begin
    if SelectDirectory('','',Dir) then
      Text:=Dir;
  end;
  if fEditType=etFile then//�ļ�
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
