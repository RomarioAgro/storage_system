unit AsyncProgressDlg;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfmAsyncProgressDlg = class; // forward declaration

  TAsyncProgressCallback = reference to procedure(ADlg: TfmAsyncProgressDlg);

  TfmAsyncProgressDlg = class(TForm)
    labDescription: TLabel;
    ProgressBar1: TProgressBar;
    btnCancel: TButton;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FOnGetProgress: TAsyncProgressCallback;
    FOnCancel: TAsyncProgressCallback;
    procedure SetProgress(ACurrent, ATotal: Integer);
  end;

var
  fmAsyncProgressDlg: TfmAsyncProgressDlg;

implementation

{$R *.dfm}

{ TfmAsyncProgressDlg }

procedure TfmAsyncProgressDlg.btnCancelClick(Sender: TObject);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;

procedure TfmAsyncProgressDlg.SetProgress(ACurrent, ATotal: Integer);
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

procedure TfmAsyncProgressDlg.Timer1Timer(Sender: TObject);
begin
  if Assigned(FOnGetProgress) then
    FOnGetProgress(Self);
end;

end.
