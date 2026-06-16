object fmAsyncProgressDlg: TfmAsyncProgressDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Progress'
  ClientHeight = 101
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poOwnerFormCenter
  DesignSize = (
    441
    101)
  PixelsPerInch = 96
  TextHeight = 13
  object labDescription: TLabel
    Left = 8
    Top = 8
    Width = 63
    Height = 13
    Caption = 'Processing...'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 27
    Width = 425
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 176
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 120
    Top = 8
  end
end
