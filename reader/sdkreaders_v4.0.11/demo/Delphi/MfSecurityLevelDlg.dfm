object fmMfSecurityLevelDlg: TfmMfSecurityLevelDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare Plus card security level'
  ClientHeight = 389
  ClientWidth = 577
  Color = clBtnFace
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
    577
    389)
  PixelsPerInch = 96
  TextHeight = 13
  object grSwitchSL1: TGroupBox
    Left = 8
    Top = 63
    Width = 561
    Height = 225
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Switch SL0 -> SL1'
    TabOrder = 0
    DesignSize = (
      561
      225)
    object labMasterKey: TLabel
      Left = 16
      Top = 24
      Width = 58
      Height = 13
      Caption = 'Master Key:'
    end
    object labConfigKey: TLabel
      Left = 16
      Top = 71
      Width = 90
      Height = 13
      Caption = 'Configuration Key:'
    end
    object labL2SwitchKey: TLabel
      Left = 16
      Top = 118
      Width = 93
      Height = 13
      Caption = 'Level 2 Switch Key:'
    end
    object labL3SwitchKey: TLabel
      Left = 16
      Top = 166
      Width = 93
      Height = 13
      Caption = 'Level 3 Switch Key:'
    end
    object edtMasterKey: TMaskEdit
      Left = 16
      Top = 43
      Width = 284
      Height = 22
      EditMask = '\0xAAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 37
      ParentFont = False
      TabOrder = 0
      Text = ''
    end
    object edtConfigKey: TMaskEdit
      Left = 16
      Top = 90
      Width = 284
      Height = 22
      EditMask = '\0xAAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 37
      ParentFont = False
      TabOrder = 1
      Text = ''
    end
    object edtL2SwitchKey: TMaskEdit
      Left = 16
      Top = 137
      Width = 284
      Height = 22
      EditMask = '\0xAAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 37
      ParentFont = False
      TabOrder = 2
      Text = ''
    end
    object edtL3SwitchKey: TMaskEdit
      Left = 16
      Top = 185
      Width = 284
      Height = 22
      EditMask = '\0xAAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 37
      ParentFont = False
      TabOrder = 3
      Text = ''
    end
    object btnSwitchToSL1: TButton
      Left = 392
      Top = 183
      Width = 152
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Switch to SL1'
      TabOrder = 4
      OnClick = btnSwitchToSL1Click
    end
    object btnMasterKey: TButton
      Left = 303
      Top = 43
      Width = 23
      Height = 21
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = ImageList1
      TabOrder = 5
      OnClick = btnMasterKeyClick
    end
    object btnMasterKeys: TButton
      Left = 327
      Top = 43
      Width = 23
      Height = 21
      Caption = '...'
      TabOrder = 6
      OnClick = btnMasterKeysClick
    end
    object btnConfigKeys: TButton
      Left = 327
      Top = 90
      Width = 23
      Height = 21
      Caption = '...'
      TabOrder = 7
      OnClick = btnConfigKeysClick
    end
    object btnConfigKey: TButton
      Left = 303
      Top = 90
      Width = 23
      Height = 21
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = ImageList1
      TabOrder = 8
      OnClick = btnConfigKeyClick
    end
    object btnSL2SwitchKeys: TButton
      Left = 327
      Top = 137
      Width = 23
      Height = 21
      Caption = '...'
      TabOrder = 9
      OnClick = btnSL2SwitchKeysClick
    end
    object btnSL2SwitchKey: TButton
      Left = 303
      Top = 137
      Width = 23
      Height = 21
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = ImageList1
      TabOrder = 10
      OnClick = btnSL2SwitchKeyClick
    end
    object btnSL3SwitchKeys: TButton
      Left = 327
      Top = 185
      Width = 23
      Height = 21
      Caption = '...'
      TabOrder = 11
      OnClick = btnSL3SwitchKeysClick
    end
    object btnSL3SwitchKey: TButton
      Left = 303
      Top = 185
      Width = 23
      Height = 21
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = ImageList1
      TabOrder = 12
      OnClick = btnSL3SwitchKeyClick
    end
  end
  object grSwitchSL3: TGroupBox
    Left = 8
    Top = 294
    Width = 561
    Height = 90
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Switch SL1 -> SL3'
    TabOrder = 1
    DesignSize = (
      561
      90)
    object labSL3SwitchKey2: TLabel
      Left = 16
      Top = 28
      Width = 93
      Height = 13
      Caption = 'Level 3 Switch Key:'
    end
    object edtAuthL3SwitchKey: TMaskEdit
      Left = 16
      Top = 47
      Width = 284
      Height = 22
      EditMask = '\0xAAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 37
      ParentFont = False
      TabOrder = 0
      Text = ''
    end
    object btnSwitchToSL3: TButton
      Left = 392
      Top = 49
      Width = 152
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Switch to SL3'
      TabOrder = 1
      OnClick = btnSwitchToSL3Click
    end
    object btnAuthL3SwitchKeys: TButton
      Left = 327
      Top = 47
      Width = 23
      Height = 21
      Caption = '...'
      TabOrder = 2
      OnClick = btnAuthL3SwitchKeysClick
    end
    object btnAuthL3SwitchKey: TButton
      Left = 303
      Top = 47
      Width = 23
      Height = 21
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = ImageList1
      TabOrder = 3
      OnClick = btnAuthL3SwitchKeyClick
    end
  end
  object grCurrentCard: TGroupBox
    Left = 8
    Top = 1
    Width = 561
    Height = 56
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Current card'
    TabOrder = 2
    DesignSize = (
      561
      56)
    object labCurrentCard: TLabel
      Left = 16
      Top = 24
      Width = 30
      Height = 13
      Caption = '-- -- --'
    end
    object btnCSRefresh: TButton
      Left = 456
      Top = 19
      Width = 88
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnCSRefreshClick
    end
  end
  object ImageList1: TImageList
    Left = 365
    Top = 55
  end
  object menuKeys: TPopupMenu
    Left = 387
    Top = 115
  end
end
