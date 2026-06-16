object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Demo (SDK Readers)'
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
        Caption = 'Port'
        Width = 100
      end
      item
        Caption = 'Model'
        Width = 100
      end
      item
        Caption = 'S/n'
      end
      item
        Caption = 'FW Version'
        Width = 70
      end
      item
        Caption = 'FW Build'
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
    Caption = 'Panel1'
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
      Caption = 'Rescan'
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
      TextHint = 'Port name'
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
        'Auto')
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
      Caption = 'Language'
      OnClick = miLanguageClick
      object miEnglish: TMenuItem
        Caption = 'English (internal)'
        Checked = True
        RadioItem = True
        OnClick = miEnglishClick
      end
    end
    object miReaderTypes: TMenuItem
      Caption = 'Reader types'
      object miILUsbReaders: TMenuItem
        Caption = 'IronLogic USB readers'
        OnClick = miILUsbReadersClick
      end
      object miTPUsbReaders: TMenuItem
        Caption = 'Third party USB readers'
        OnClick = miTPUsbReadersClick
      end
      object miCcidReaders: TMenuItem
        Caption = 'CCID readers'
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
      Caption = 'Show unidentified converters'
      Checked = True
      OnClick = miShowUnidentifiedClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Debugloglevel1: TMenuItem
      Caption = 'Debug log level'
      object miDLogLevelAssert: TMenuItem
        Caption = 'Assert'
        RadioItem = True
        OnClick = miDLogLevelAssertClick
      end
      object miDLogLevelError: TMenuItem
        Caption = 'Error'
        RadioItem = True
        OnClick = miDLogLevelErrorClick
      end
      object miDLogLevelWarning: TMenuItem
        Caption = 'Warning'
        RadioItem = True
        OnClick = miDLogLevelWarningClick
      end
      object miDLogLevelInfo: TMenuItem
        Caption = 'Info'
        RadioItem = True
        OnClick = miDLogLevelInfoClick
      end
      object miDLogLevelDebug: TMenuItem
        Caption = 'Debug'
        RadioItem = True
        OnClick = miDLogLevelDebugClick
      end
      object miDLogLevelVerbose: TMenuItem
        Caption = 'Verbose'
        RadioItem = True
        OnClick = miDLogLevelVerboseClick
      end
    end
    object miWriteDebugLog: TMenuItem
      Caption = 'Write debug log'
      Checked = True
      OnClick = miWriteDebugLogClick
    end
  end
  object ActionList1: TActionList
    Left = 120
    Top = 40
    object actOpen: TAction
      Caption = 'Open...'
      OnExecute = actOpenExecute
      OnUpdate = actOpenUpdate
    end
  end
end
