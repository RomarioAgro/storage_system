object fmProgressDlg: TfmProgressDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1055#1088#1086#1075#1088#1077#1089#1089
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
    Caption = #1042#1099#1087#1086#1083#1085#1077#1085#1080#1077'...'
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
    Caption = #1054#1090#1084#1077#1085#1072
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
