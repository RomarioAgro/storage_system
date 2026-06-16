object fmMfReaderDlg: TfmMfReaderDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare reader'
  ClientHeight = 197
  ClientWidth = 500
  Color = clBtnFace
  Constraints.MinHeight = 235
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
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    500
    197)
  PixelsPerInch = 96
  TextHeight = 13
  object grConnectionStatus: TGroupBox
    Left = 0
    Top = 0
    Width = 500
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Connection status'
    TabOrder = 0
    DesignSize = (
      500
      65)
    object labConnectionStatus: TLabel
      Left = 24
      Top = 24
      Width = 20
      Height = 13
      Caption = '-----'
    end
    object btnConnect: TButton
      Left = 312
      Top = 24
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 404
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
    Width = 500
    Height = 90
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Current card'
    TabOrder = 1
    DesignSize = (
      500
      90)
    object btnRefresh: TButton
      Left = 310
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 1
      OnClick = btnRefreshClick
    end
    object btnOpen: TButton
      Left = 404
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Open...'
      TabOrder = 2
      OnClick = btnOpenClick
    end
    object btnChangeSL: TButton
      Left = 310
      Top = 50
      Width = 182
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Change security level...'
      Enabled = False
      TabOrder = 3
      OnClick = btnChangeSLClick
    end
    object edtCurrentCard: TEdit
      Left = 16
      Top = 21
      Width = 288
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 0
    end
  end
  object btnClassicKeys: TButton
    Left = 8
    Top = 167
    Width = 100
    Height = 25
    Caption = 'Keys Classic...'
    TabOrder = 2
    OnClick = btnClassicKeysClick
  end
  object btnPlusKeys: TButton
    Left = 114
    Top = 167
    Width = 100
    Height = 25
    Caption = 'Keys Plus...'
    TabOrder = 3
    OnClick = btnPlusKeysClick
  end
end
