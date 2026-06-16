object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = #1044#1077#1084#1086' (SDK Readers)'
  ClientHeight = 212
  ClientWidth = 504
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 504
    Height = 152
    Align = alClient
    Columns = <
      item
        Caption = #1055#1086#1088#1090
        Width = 100
      end
      item
        Caption = #1052#1086#1076#1077#1083#1100
        Width = 100
      end
      item
        Caption = #1057'/'#1085
      end
      item
        Caption = #1042#1077#1088#1089#1080#1103' '#1087#1088#1086#1096#1080#1074#1082#1080
        Width = 70
      end
      item
        Caption = #1057#1073#1086#1088#1082#1072' '#1087#1088#1086#1096#1080#1074#1082#1080
        Width = 120
      end>
    HideSelection = False
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
    OnDataHint = ListView1DataHint
    OnDblClick = ListView1DblClick
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 152
    Width = 504
    Height = 41
    Align = alBottom
    Caption = 'Panel'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      504
      41)
    object btnRescan: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
      OnClick = btnRescanClick
    end
    object btnOpen: TButton
      Left = 423
      Top = 6
      Width = 75
      Height = 25
      Action = actOpen
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 1
    end
    object edtPort: TEdit
      Left = 107
      Top = 8
      Width = 184
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 2
      TextHint = #1048#1084#1103' '#1087#1086#1088#1090#1072
    end
    object cbConnectModel: TComboBox
      Left = 293
      Top = 8
      Width = 124
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 0
      TabOrder = 3
      Text = 'Auto'
      Items.Strings = (
        #1040#1074#1090#1086)
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 193
    Width = 504
    Height = 19
    Panels = <>
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 32
    Top = 40
    object miLanguage: TMenuItem
      Caption = #1071#1079#1099#1082
      OnClick = miLanguageClick
      object miEnglish: TMenuItem
        Caption = 'English ('#1074#1089#1090#1088#1086#1077#1085#1085#1099#1081'l)'
        Checked = True
        RadioItem = True
        OnClick = miEnglishClick
      end
    end
    object miReaderTypes: TMenuItem
      Caption = #1058#1080#1087#1099' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1077#1081
      object miILUsbReaders: TMenuItem
        Caption = 'USB '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1080' IronLogic'
        OnClick = miILUsbReadersClick
      end
      object miTPUsbReaders: TMenuItem
        Caption = 'USB '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1080' '#1089#1090#1086#1088#1086#1085#1085#1080#1093' '#1087#1088#1086#1080#1079#1074#1086#1076#1080#1090#1077#1083#1077#1081
        OnClick = miTPUsbReadersClick
      end
      object miCcidReaders: TMenuItem
        Caption = 'CCID '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1080
        OnClick = miCcidReadersClick
      end
      object miServerReaders: TMenuItem
        Caption = 'IP converters in "Server" mode'
        OnClick = miServerReadersClick
      end
      object miClientReaders: TMenuItem
        Caption = 'IP converters in "Client" mode'
        OnClick = miClientReadersClick
      end
    end
    object miShowUnidentified: TMenuItem
      Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1085#1077#1086#1087#1086#1079#1085#1072#1085#1085#1099#1077' '#1082#1086#1085#1074#1077#1088#1090#1077#1088#1099
      Checked = True
      OnClick = miShowUnidentifiedClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Debugloglevel1: TMenuItem
      Caption = #1059#1088#1086#1074#1077#1085#1100' '#1083#1086#1075#1072' '#1086#1090#1083#1072#1076#1082#1080
      object miDLogLevelAssert: TMenuItem
        Caption = #1050#1088#1080#1090#1080#1095#1077#1089#1082#1072#1103' '#1086#1096#1080#1073#1082#1072
        RadioItem = True
        OnClick = miDLogLevelAssertClick
      end
      object miDLogLevelError: TMenuItem
        Caption = #1054#1096#1080#1073#1082#1072
        RadioItem = True
        OnClick = miDLogLevelErrorClick
      end
      object miDLogLevelWarning: TMenuItem
        Caption = #1055#1088#1077#1076#1091#1087#1088#1077#1078#1076#1077#1085#1080#1077
        RadioItem = True
        OnClick = miDLogLevelWarningClick
      end
      object miDLogLevelInfo: TMenuItem
        Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103
        RadioItem = True
        OnClick = miDLogLevelInfoClick
      end
      object miDLogLevelDebug: TMenuItem
        Caption = #1054#1090#1083#1072#1076#1082#1072
        RadioItem = True
        OnClick = miDLogLevelDebugClick
      end
      object miDLogLevelVerbose: TMenuItem
        Caption = #1055#1086#1076#1088#1086#1073#1085#1086
        RadioItem = True
        OnClick = miDLogLevelVerboseClick
      end
    end
    object miWriteDebugLog: TMenuItem
      Caption = #1055#1080#1089#1072#1090#1100' '#1083#1086#1075' '#1086#1090#1083#1072#1076#1082#1080
      Checked = True
      OnClick = miWriteDebugLogClick
    end
  end
  object ActionList1: TActionList
    Left = 120
    Top = 40
    object actOpen: TAction
      Caption = #1054#1090#1082#1088#1099#1090#1100'...'
      OnExecute = actOpenExecute
      OnUpdate = actOpenUpdate
    end
  end
end
