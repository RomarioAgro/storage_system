object fmProgressDlg: TfmProgressDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Progress'
  ClientHeight = 204
  ClientWidth = 485
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    485
    204)
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
    Width = 469
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 208
    Top = 171
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object edtLog: TMemo
    Left = 8
    Top = 50
    Width = 469
    Height = 112
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
    Visible = False
  end
end
