object fmTemicDlg: TfmTemicDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Temic'
  ClientHeight = 736
  ClientWidth = 587
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
    587
    736)
  PixelsPerInch = 96
  TextHeight = 13
  object gridBytes: TStringGrid
    Left = 0
    Top = 3
    Width = 406
    Height = 295
    DefaultDrawing = False
    RowCount = 11
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goFixedColClick]
    ParentFont = False
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
    Left = 412
    Top = 122
    Width = 167
    Height = 82
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
    Left = 412
    Top = 8
    Width = 167
    Height = 108
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object shLegSn: TShape
      Left = 8
      Top = 8
      Width = 17
      Height = 17
      Brush.Color = clSkyBlue
    end
    object labLegSn: TLabel
      Left = 31
      Top = 10
      Width = 66
      Height = 13
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object shLegPassw: TShape
      Left = 8
      Top = 31
      Width = 17
      Height = 18
      Brush.Color = 2124031
    end
    object labLegPassw: TLabel
      Left = 31
      Top = 33
      Width = 46
      Height = 13
      Caption = #1055#1072#1088#1086#1083#1100
    end
    object shLegData: TShape
      Left = 8
      Top = 54
      Width = 17
      Height = 18
      Brush.Color = 11137449
    end
    object labLegData: TLabel
      Left = 32
      Top = 56
      Width = 48
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    end
    object shLegConfig: TShape
      Left = 8
      Top = 77
      Width = 17
      Height = 18
      Brush.Color = 10027007
    end
    object labLegConfig: TLabel
      Left = 31
      Top = 79
      Width = 65
      Height = 13
      Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103
    end
  end
  object grPassword: TGroupBox
    Left = 412
    Top = 216
    Width = 167
    Height = 57
    TabOrder = 3
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
  object btnWrite: TButton
    Left = 8
    Top = 703
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1087#1080#1089#1072#1090#1100
    TabOrder = 6
    OnClick = btnWriteClick
  end
  object btnRead: TButton
    Left = 102
    Top = 703
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100
    TabOrder = 7
    OnClick = btnReadClick
  end
  object grConfig: TGroupBox
    Left = 0
    Top = 304
    Width = 579
    Height = 169
    Anchors = [akLeft, akTop, akRight]
    Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103
    TabOrder = 4
    object labMode: TLabel
      Left = 58
      Top = 26
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = #1056#1077#1078#1080#1084':'
    end
    object labDataRate: TLabel
      Left = 20
      Top = 53
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = 'Data Bit Rate:'
    end
    object labModulation: TLabel
      Left = 32
      Top = 80
      Width = 56
      Height = 13
      Alignment = taRightJustify
      Caption = 'Modulation:'
    end
    object labPSK_CF: TLabel
      Left = 48
      Top = 107
      Width = 39
      Height = 13
      Alignment = taRightJustify
      Caption = 'PSK-CF:'
    end
    object labMaxBlock: TLabel
      Left = 37
      Top = 134
      Width = 51
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max Block:'
    end
    object cbMode: TComboBox
      Left = 94
      Top = 23
      Width = 195
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'e5550 compatibility'
      OnChange = cbModeChange
      Items.Strings = (
        'e5550 compatibility'
        'X-Mode')
    end
    object cbDataBitRate: TComboBox
      Left = 94
      Top = 50
      Width = 195
      Height = 22
      CharCase = ecUpperCase
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = cbDataBitRateChange
      Items.Strings = (
        'RF/8'
        'RF/16'
        'RF/32'
        'RF/40'
        'RF/50'
        'RF/64'
        'RF/100'
        'RF/128')
    end
    object cbModulation: TComboBox
      Left = 94
      Top = 77
      Width = 195
      Height = 22
      Style = csDropDownList
      DropDownCount = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnChange = cbModulationChange
      Items.Strings = (
        'Direct'
        'PSK1'
        'PSK2'
        'PSK3'
        'FSK1'
        'FSK2'
        'FSK1a'
        'FSK2a'
        'Manchester'
        'Biphase('#39'50)'
        'Biphase('#39'57)')
    end
    object cbPSK_CF: TComboBox
      Left = 94
      Top = 104
      Width = 195
      Height = 21
      Style = csDropDownList
      TabOrder = 3
      OnChange = cbPSK_CFChange
      Items.Strings = (
        'RF/2'
        'RF/4'
        'RF/8'
        'Res')
    end
    object cbMaxBlock: TComboBox
      Left = 94
      Top = 131
      Width = 195
      Height = 21
      Style = csDropDownList
      TabOrder = 4
      OnChange = cbMaxBlockChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7')
    end
    object chkAOR: TCheckBox
      Left = 309
      Top = 50
      Width = 185
      Height = 17
      Caption = 'Answer-On-Request (AOR) Mode'
      TabOrder = 6
      OnClick = chkAORClick
    end
    object chkOTP: TCheckBox
      Left = 309
      Top = 106
      Width = 49
      Height = 17
      Caption = 'OTP'
      TabOrder = 10
      OnClick = chkOTPClick
    end
    object chkST_seq_ter: TCheckBox
      Left = 309
      Top = 64
      Width = 145
      Height = 17
      Caption = 'ST-sequence Terminator'
      TabOrder = 7
      OnClick = chkST_seq_terClick
    end
    object chkSST_seq_sm: TCheckBox
      Left = 378
      Top = 69
      Width = 161
      Height = 17
      Caption = 'SST-Sequence StartMarker'
      TabOrder = 8
      OnClick = chkSST_seq_smClick
    end
    object chkFastWrite: TCheckBox
      Left = 309
      Top = 123
      Width = 97
      Height = 17
      Caption = 'Fast write'
      TabOrder = 11
      OnClick = chkFastWriteClick
    end
    object chkInverseData: TCheckBox
      Left = 309
      Top = 140
      Width = 97
      Height = 17
      Caption = 'Inverse data'
      TabOrder = 12
      OnClick = chkInverseDataClick
    end
    object chkPOR_delay: TCheckBox
      Left = 309
      Top = 87
      Width = 73
      Height = 17
      Caption = 'POR delay'
      TabOrder = 9
      OnClick = chkPOR_delayClick
    end
    object chkTestMode: TCheckBox
      Left = 309
      Top = 27
      Width = 241
      Height = 17
      Caption = 'Test mode'
      TabOrder = 5
      OnClick = chkTestModeClick
    end
  end
  object grEmulation: TGroupBox
    Left = 0
    Top = 479
    Width = 579
    Height = 218
    Anchors = [akLeft, akTop, akRight]
    Caption = #1069#1084#1091#1083#1103#1094#1080#1103
    TabOrder = 5
    DesignSize = (
      579
      218)
    object labEmulated: TLabel
      Left = 48
      Top = 24
      Width = 48
      Height = 13
      Alignment = taRightJustify
      Caption = #1069#1084#1091#1083#1080#1088#1091#1077#1090':'
    end
    object grEmuNew: TGroupBox
      Left = 8
      Top = 51
      Width = 561
      Height = 158
      Caption = #1053#1086#1074#1072#1103
      TabOrder = 1
      object pcCreateCard: TPageControl
        Left = 118
        Top = 23
        Width = 435
        Height = 90
        ActivePage = TabSheet2
        MultiLine = True
        TabHeight = 12
        TabOrder = 1
        TabPosition = tpRight
        object TabSheet1: TTabSheet
          Caption = 'Em-Marine'
          object labEmNumber: TLabel
            Left = 248
            Top = 5
            Width = 123
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1053#1086#1084#1077#1088
          end
          object labEmGroup: TLabel
            Left = 140
            Top = 5
            Width = 83
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1057#1077#1088#1080#1103
          end
          object labEmFacility: TLabel
            Left = 9
            Top = 5
            Width = 104
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1050#1086#1076' '#1087#1088#1086#1080#1079#1074#1086#1076#1080#1090#1077#1083#1103
          end
          object edtEmNumber: TSpinEdit
            Left = 248
            Top = 27
            Width = 123
            Height = 46
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxValue = 65535
            MinValue = 0
            ParentFont = False
            TabOrder = 2
            Value = 65535
            OnChange = edtEmNumberChange
          end
          object edtEmGroup: TSpinEdit
            Left = 140
            Top = 27
            Width = 83
            Height = 46
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxValue = 255
            MinValue = 0
            ParentFont = False
            TabOrder = 1
            Value = 0
            OnChange = edtEmGroupChange
          end
          object edtEmFacility: TMaskEdit
            Left = 9
            Top = 27
            Width = 94
            Height = 44
            Alignment = taCenter
            EditMask = 'AAAA;1;_'
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxLength = 4
            ParentFont = False
            TabOrder = 0
            Text = 'FFFF'
            OnChange = edtEmFacilityChange
          end
        end
        object TabSheet2: TTabSheet
          Caption = 'Hid'
          ImageIndex = 1
          object labHidWiegand: TLabel
            Left = 2
            Top = 3
            Width = 63
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1042#1080#1075#1072#1085#1076
          end
          object labHidFacility: TLabel
            Left = 168
            Top = 5
            Width = 134
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1050#1086#1076' '#1087#1088#1086#1080#1079#1074#1086#1076#1080#1090#1077#1083#1103
          end
          object labHidNumber: TLabel
            Left = 293
            Top = 3
            Width = 123
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = #1053#1086#1084#1077#1088
          end
          object edtHidWiegand: TSpinEdit
            Left = 2
            Top = 25
            Width = 63
            Height = 46
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxValue = 37
            MinValue = 10
            ParentFont = False
            TabOrder = 0
            Value = 26
            OnChange = edtHidWiegandChange
          end
          object rgHidFormat: TRadioGroup
            Left = 71
            Top = 3
            Width = 74
            Height = 66
            Caption = #1060#1086#1088#1084#1072#1090
            ItemIndex = 0
            Items.Strings = (
              #1044#1077#1089#1103#1090#1080#1095#1085#1099#1081
              #1064#1077#1089#1090#1085#1072#1076#1094#1072#1090#1077#1088#1080#1095#1085#1099#1081)
            TabOrder = 1
            OnClick = rgHidFormatClick
          end
          object edtHidNumber: TSpinEdit
            Left = 293
            Top = 25
            Width = 123
            Height = 46
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxValue = 65535
            MinValue = 0
            ParentFont = False
            TabOrder = 4
            Value = 65535
            OnChange = edtHidNumberChange
          end
          object edtHidFacility2: TSpinEdit
            Left = 159
            Top = 25
            Width = 128
            Height = 46
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxValue = 16777215
            MinValue = 0
            ParentFont = False
            TabOrder = 3
            Value = 65535
            Visible = False
            OnChange = edtHidFacility2Change
          end
          object edtHidFacility: TMaskEdit
            Left = 168
            Top = 25
            Width = 128
            Height = 44
            Alignment = taCenter
            EditMask = 'AAAAAA;1;_'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -29
            Font.Name = 'Impact'
            Font.Style = []
            MaxLength = 6
            ParentFont = False
            TabOrder = 2
            Text = '000000'
            OnChange = edtHidFacilityChange
          end
        end
      end
      object rgCardType: TRadioGroup
        Left = 12
        Top = 17
        Width = 104
        Height = 88
        Caption = #1058#1080#1087
        ItemIndex = 0
        Items.Strings = (
          'Em-Marine'
          'HID')
        TabOrder = 0
        OnClick = rgCardTypeClick
      end
      object btnEmuGet: TButton
        Left = 301
        Top = 119
        Width = 159
        Height = 25
        Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1101#1084#1091#1083#1080#1088#1091#1077#1084#1099#1081
        TabOrder = 2
        OnClick = btnEmuGetClick
      end
      object btnEmuApply: TButton
        Left = 466
        Top = 119
        Width = 88
        Height = 25
        Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
        TabOrder = 3
        OnClick = btnEmuApplyClick
      end
    end
    object edtEmulated: TEdit
      Left = 102
      Top = 21
      Width = 467
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 0
    end
  end
end
