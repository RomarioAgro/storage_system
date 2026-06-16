object fmMfUltralightDlg: TfmMfUltralightDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Mifare Ultralight'
  ClientHeight = 472
  ClientWidth = 544
  Color = clBtnFace
  Constraints.MinHeight = 100
  Constraints.MinWidth = 100
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    544
    472)
  PixelsPerInch = 96
  TextHeight = 13
  object gridBytes: TStringGrid
    Left = 0
    Top = -1
    Width = 334
    Height = 429
    Anchors = [akLeft, akTop, akRight, akBottom]
    DefaultDrawing = False
    RowCount = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goFixedColClick]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnClick = gridBytesClick
    OnDblClick = gridBytesDblClick
    OnDrawCell = gridBytesDrawCell
    OnFixedCellClick = gridBytesFixedCellClick
    OnKeyDown = gridBytesKeyDown
    OnKeyPress = gridBytesKeyPress
    OnSelectCell = gridBytesSelectCell
  end
  object rgDataFormat: TRadioGroup
    Left = 340
    Top = 135
    Width = 204
    Height = 82
    Anchors = [akTop, akRight]
    Caption = #1060#1086#1088#1084#1072#1090' '#1076#1072#1085#1085#1099#1093
    ItemIndex = 2
    Items.Strings = (
      #1044#1074#1086#1080#1095#1085#1099#1081
      #1044#1077#1089#1103#1090#1080#1095#1085#1099#1081
      #1064#1077#1089#1090#1085#1072#1076#1094#1072#1090#1077#1088#1080#1095#1085#1099#1081)
    TabOrder = 2
    OnClick = rgDataFormatClick
  end
  object panLegend: TPanel
    Left = 340
    Top = 3
    Width = 204
    Height = 126
    Anchors = [akTop, akRight]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object shLegSN: TShape
      Left = 8
      Top = 8
      Width = 17
      Height = 17
      Brush.Color = clSkyBlue
    end
    object labLegSN: TLabel
      Left = 31
      Top = 10
      Width = 66
      Height = 13
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object shLegConfig: TShape
      Left = 8
      Top = 33
      Width = 17
      Height = 17
      Brush.Color = 10027007
    end
    object labLegConfig: TLabel
      Left = 31
      Top = 35
      Width = 51
      Height = 13
      Caption = 'Lock / OTP'
    end
    object shLegData: TShape
      Left = 8
      Top = 77
      Width = 17
      Height = 17
      Brush.Color = 11137449
    end
    object labLegData: TLabel
      Left = 31
      Top = 79
      Width = 48
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    end
    object shLegDataRO: TShape
      Left = 8
      Top = 96
      Width = 17
      Height = 17
      Brush.Color = 12442813
    end
    object labLegDataRO: TLabel
      Left = 31
      Top = 98
      Width = 104
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' ('#1090#1086#1083#1100#1082#1086' '#1095#1090#1077#1085#1080#1077')'
    end
    object labLegConfigRO: TLabel
      Left = 31
      Top = 54
      Width = 107
      Height = 13
      Caption = 'Lock / OTP ('#1090#1086#1083#1100#1082#1086' '#1095#1090#1077#1085#1080#1077')'
    end
    object shLegConfigRO: TShape
      Left = 8
      Top = 52
      Width = 17
      Height = 17
      Brush.Color = 12443101
    end
  end
  object btnWrite: TButton
    Left = 8
    Top = 439
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1087#1080#1089#1072#1090#1100
    TabOrder = 3
    OnClick = btnWriteClick
  end
  object btnRead: TButton
    Left = 102
    Top = 439
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100
    TabOrder = 4
    OnClick = btnReadClick
  end
end
