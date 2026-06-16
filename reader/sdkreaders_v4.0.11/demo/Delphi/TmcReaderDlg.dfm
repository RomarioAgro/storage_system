object fmTmcReaderDlg: TfmTmcReaderDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Temic card reader'
  ClientHeight = 253
  ClientWidth = 462
  Color = clBtnFace
  Constraints.MinHeight = 220
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
    462
    253)
  PixelsPerInch = 96
  TextHeight = 13
  object grConnectionStatus: TGroupBox
    Left = 0
    Top = 0
    Width = 462
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Connection status'
    TabOrder = 0
    DesignSize = (
      462
      65)
    object labConnectionStatus: TLabel
      Left = 24
      Top = 24
      Width = 20
      Height = 13
      Caption = '-----'
    end
    object btnConnect: TButton
      Left = 274
      Top = 24
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 366
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
    Width = 462
    Height = 58
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Current card'
    TabOrder = 1
    DesignSize = (
      462
      58)
    object btnRefresh: TButton
      Left = 274
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object btnOpen: TButton
      Left = 366
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Open...'
      TabOrder = 1
      OnClick = btnOpenClick
    end
    object edtCurrentCard: TEdit
      Left = 16
      Top = 21
      Width = 252
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 2
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 135
    Width = 462
    Height = 114
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Temic Card Search Options'
    TabOrder = 2
    DesignSize = (
      462
      114)
    object labScanParam: TLabel
      Left = 18
      Top = 24
      Width = 71
      Height = 13
      Caption = 'Type && Speed:'
    end
    object cbScanParam: TComboBox
      Left = 18
      Top = 43
      Width = 71
      Height = 21
      TabOrder = 0
      OnChange = cbScanParamChange
      OnSelect = cbScanParamSelect
      Items.Strings = (
        'Auto'
        '2 0 Em-Marine'
        '1 1'
        '2 1'
        '1 0'
        '3 0 HID'
        '4 0')
    end
    object grPassword: TGroupBox
      Left = 107
      Top = 24
      Width = 167
      Height = 57
      TabOrder = 1
      DesignSize = (
        167
        57)
      object chkPassword: TCheckBox
        Left = 3
        Top = 0
        Width = 72
        Height = 17
        Caption = 'Password'
        TabOrder = 0
        OnClick = chkPasswordClick
      end
      object cbPassword: TComboBox
        Left = 11
        Top = 23
        Width = 126
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        TabOrder = 1
        OnSelect = cbPasswordSelect
      end
      object btnPswList: TButton
        Left = 137
        Top = 22
        Width = 23
        Height = 23
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 2
        OnClick = btnPswListClick
      end
    end
    object btnScanTemic: TButton
      Left = 308
      Top = 16
      Width = 146
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Scan'
      TabOrder = 2
      OnClick = btnScanTemicClick
    end
    object btnInitTemic: TButton
      Left = 308
      Top = 47
      Width = 146
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Initialize Temic'
      TabOrder = 3
      OnClick = btnInitTemicClick
    end
    object chkAutoScanTemic: TCheckBox
      Left = 18
      Top = 87
      Width = 436
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Automatically scan Temic cards'
      TabOrder = 4
      OnClick = chkAutoScanTemicClick
    end
  end
end
