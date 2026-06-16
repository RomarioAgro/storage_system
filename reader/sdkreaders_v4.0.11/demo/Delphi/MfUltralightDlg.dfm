object fmMfUltralightDlg: TfmMfUltralightDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare Ultralight'
  ClientHeight = 474
  ClientWidth = 562
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
    562
    474)
  PixelsPerInch = 96
  TextHeight = 13
  object gridBytes: TStringGrid
    Left = 0
    Top = -1
    Width = 352
    Height = 431
    Anchors = [akLeft, akTop, akRight, akBottom]
    DefaultColWidth = 70
    DefaultDrawing = False
    RowCount = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goFixedColClick]
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
    Left = 358
    Top = 135
    Width = 204
    Height = 82
    Anchors = [akTop, akRight]
    Caption = 'Data format'
    ItemIndex = 2
    Items.Strings = (
      'Binary'
      'Decimal'
      'Hexadecimal')
    TabOrder = 2
    OnClick = rgDataFormatClick
  end
  object panLegend: TPanel
    Left = 358
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
      Caption = 'Serial Number'
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
      Caption = 'User Data'
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
      Caption = 'User Data (read only)'
    end
    object labLegConfigRO: TLabel
      Left = 31
      Top = 54
      Width = 107
      Height = 13
      Caption = 'Lock / OTP (read only)'
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
    Top = 441
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Write'
    TabOrder = 3
    OnClick = btnWriteClick
  end
  object btnRead: TButton
    Left = 102
    Top = 441
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Read'
    TabOrder = 4
    OnClick = btnReadClick
  end
end
