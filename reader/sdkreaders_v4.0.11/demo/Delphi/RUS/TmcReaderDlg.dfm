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
    Caption = #1057#1086#1089#1090#1086#1103#1085#1080#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
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
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      Left = 366
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
    Width = 462
    Height = 58
    Anchors = [akLeft, akTop, akRight]
    Caption = #1058#1077#1082#1091#1097#1072#1103' '#1082#1072#1088#1090#1072
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
      Caption = #1054#1090#1082#1088#1099#1090#1100'...'
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
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1080#1089#1082#1072' '#1082#1072#1088#1090#1099' Temic'
    TabOrder = 2
    DesignSize = (
      462
      114)
    object labScanParam: TLabel
      Left = 18
      Top = 24
      Width = 71
      Height = 13
      Caption = #1058#1080#1087' '#1080' '#1089#1082#1086#1088#1086#1089#1090#1100':'
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
        #1040#1074#1090#1086
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
        Caption = #1055#1072#1088#1086#1083#1100
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
      Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
      OnClick = btnScanTemicClick
    end
    object btnInitTemic: TButton
      Left = 308
      Top = 47
      Width = 146
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1048#1085#1080#1094#1080#1072#1083#1080#1079#1080#1088#1086#1074#1072#1090#1100' Temic'
      TabOrder = 3
      OnClick = btnInitTemicClick
    end
    object chkAutoScanTemic: TCheckBox
      Left = 18
      Top = 87
      Width = 436
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100' '#1082#1072#1088#1090#1099' Temic'
      TabOrder = 4
      OnClick = chkAutoScanTemicClick
    end
  end
end
