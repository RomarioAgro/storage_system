unit ProgressDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfmProgressDlg = class; // forward declaration

  TExecuteWPCallback = reference to procedure(ADlg: TfmProgressDlg);

  TfmProgressDlg = class(TForm)
    labDescription: TLabel;
    ProgressBar1: TProgressBar;
    btnCancel: TButton;
    edtLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    m_pCallback     : TExecuteWPCallback;

    procedure UmExecute(var AMsg: TMessage); message WM_USER;

  public
    { Public declarations }
    m_fCancelled    : Boolean; // True нажали кнопку "Отмена"
    m_fCloseAfter   : Boolean; // True закрыть после выполнения

    procedure SetProgress(ACurrent, ATotal: Integer);
    procedure AddLog(Const AStr: string);
    procedure SetErrorMode;
  end;

var
  fmProgressDlg: TfmProgressDlg;

function ExecuteWithProgress(const ADescription: string;
  ACallback: TExecuteWPCallback; AParent: TCustomForm = nil): Boolean;

implementation

{$R *.dfm}

{ TfmProgressDlg }

procedure TfmProgressDlg.AddLog(const AStr: string);
begin
  edtLog.Lines.Add(AStr);
  if not edtLog.Visible then
  begin
    edtLog.Visible := True;
    Height := 232;
  end;
  Application.ProcessMessages();
end;

procedure TfmProgressDlg.btnCancelClick(Sender: TObject);
begin
  m_fCancelled := True;
end;

procedure TfmProgressDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_fCancelled := True;
end;

procedure TfmProgressDlg.FormCreate(Sender: TObject);
begin
  m_fCloseAfter := True;
  ClientHeight := ProgressBar1.Top + ProgressBar1.Height +
        8 + btnCancel.Height + 8;
end;

procedure TfmProgressDlg.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_USER, 0, 0);
end;

procedure TfmProgressDlg.SetErrorMode;
begin
  m_fCloseAfter := False;
  ProgressBar1.State := pbsError;
end;

procedure TfmProgressDlg.SetProgress(ACurrent, ATotal: Integer);
begin
  if ATotal = 0 then
    ProgressBar1.Style := pbstMarquee
  else
  begin
    ProgressBar1.Style := pbstNormal;
    if ProgressBar1.Max >= ACurrent then
    begin
      ProgressBar1.Position := ACurrent;
      ProgressBar1.Max := ATotal;
    end
    else
    begin
      ProgressBar1.Max := ATotal;
      ProgressBar1.Position := ACurrent;
    end;
  end;
end;

procedure TfmProgressDlg.UmExecute(var AMsg: TMessage);
begin
  Assert(Assigned(m_pCallback));

  try
    m_pCallback(Self);
  except
    on e: Exception do
    begin
      labDescription.Caption := e.Message;
      SetErrorMode;
    end;
  end;

  if m_fCloseAfter then
    Close
  else
    btnCancel.Enabled := False;
end;

function ExecuteWithProgress(const ADescription: string;
  ACallback: TExecuteWPCallback; AParent: TCustomForm {= nil}): Boolean;
var
  oDlg: TfmProgressDlg;
begin
  oDlg := TfmProgressDlg.Create(Application);
  try
    if AParent <> nil then
      oDlg.PopupParent := AParent;
    oDlg.labDescription.Caption := ADescription;
    oDlg.m_pCallback := ACallback;
    Result := (oDlg.ShowModal = mrOk);
  finally
    oDlg.Free;
  end;
end;

end.
