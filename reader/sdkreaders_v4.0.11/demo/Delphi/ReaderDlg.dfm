object fmReaderDlg: TfmReaderDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Reader'
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
    Caption = 'Connection status'
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
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 338
      Top = 24
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Disonnect'
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
    Caption = 'Current card'
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
