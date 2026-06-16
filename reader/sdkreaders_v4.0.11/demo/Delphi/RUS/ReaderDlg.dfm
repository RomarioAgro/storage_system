object fmReaderDlg: TfmReaderDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1057#1095#1080#1090#1099#1074#1072#1090#1077#1083#1100
  ClientHeight = 132
  ClientWidth = 434
  Color = clBtnFace
  Constraints.MinHeight = 170
  Constraints.MinWidth = 400
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
    434
    132)
  PixelsPerInch = 96
  TextHeight = 13
  object grConnectionStatus: TGroupBox
    Left = 0
    Top = 0
    Width = 434
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
    TabOrder = 0
    DesignSize = (
      434
      65)
    object labConnectionStatus: TLabel
      Left = 24
      Top = 24
      Width = 20
      Height = 13
      Caption = '-----'
    end
    object btnConnect: TButton
      Left = 246
      Top = 24
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 338
      Top = 24
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100#1089#1103
      TabOrder = 1
      OnClick = btnDisconnectClick
    end
  end
  object grCurrentCard: TGroupBox
    Left = 0
    Top = 71
    Width = 434
    Height = 58
    Anchors = [akLeft, akTop, akRight]
    Caption = #1058#1077#1082#1091#1097#1072#1103' '#1082#1072#1088#1090#1072
    TabOrder = 1
    DesignSize = (
      434
      58)
    object btnRefresh: TButton
      Left = 338
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object edtCurrentCard: TEdit
      Left = 16
      Top = 21
      Width = 316
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
    end
  end
end
