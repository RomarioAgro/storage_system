object fmMfClassicDlg: TfmMfClassicDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare Classic'
  ClientHeight = 932
  ClientWidth = 878
  Color = clBtnFace
  Constraints.MinHeight = 840
  Constraints.MinWidth = 820
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
    878
    932)
  PixelsPerInch = 96
  TextHeight = 13
  object lbGroups: TListBox
    Left = 0
    Top = 95
    Width = 80
    Height = 798
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'Sector 0'
      'Sector 1'
      'Sector 2'
      'Sector 3'
      'Sector 4'
      'Sector 5'
      'Sector 6'
      'Sector 7'
      'Sector 8'
      'Sector 9'
      'Sector 10'
      'Sector 11'
      'Sector 12'
      'Sector 13'
      'Sector 14'
      'Sector 15'
      'Small (up to 31)'
      'Large (from 32)'
      'All')
    TabOrder = 2
    OnClick = lbGroupsClick
  end
  object gridBytes: TStringGrid
    Left = 80
    Top = 95
    Width = 592
    Height = 427
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 18
    DefaultColWidth = 26
    DefaultDrawing = False
    FixedCols = 2
    RowCount = 17
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goThumbTracking]
    ParentFont = False
    PopupMenu = menuGrid
    TabOrder = 3
    OnClick = gridBytesClick
    OnDblClick = gridBytesDblClick
    OnDrawCell = gridBytesDrawCell
    OnKeyDown = gridBytesKeyDown
    OnKeyPress = gridBytesKeyPress
    OnSelectCell = gridBytesSelectCell
  end
  object grAuthorization: TGroupBox
    Left = 0
    Top = 0
    Width = 878
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103
    TabOrder = 0
    DesignSize = (
      878
      89)
    object pcAuth: TPageControl
      Left = 224
      Top = 24
      Width = 643
      Height = 55
      ActivePage = tabAuthKeyVal
      Anchors = [akLeft, akTop, akRight]
      MultiLine = True
      TabOrder = 1
      TabPosition = tpRight
      object tabAuthKeyVal: TTabSheet
        Caption = #1071#1074#1085#1099#1081' '#1082#1083#1102#1095
        object edtAuthKey: TMaskEdit
          Left = 3
          Top = 10
          Width = 120
          Height = 22
          EditMask = '\0xAAAAAAAAAAAA;0;_'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          MaxLength = 14
          ParentFont = False
          TabOrder = 0
          Text = ''
        end
        object btnAuthKeys: TButton
          Left = 154
          Top = 10
          Width = 23
          Height = 21
          Caption = '...'
          TabOrder = 2
          OnClick = btnAuthKeysClick
        end
        object btnAuthKey: TButton
          Left = 128
          Top = 10
          Width = 23
          Height = 21
          ImageAlignment = iaCenter
          ImageIndex = 0
          Images = ImageList1
          TabOrder = 1
          OnClick = btnAuthKeyClick
        end
      end
      object tabAuthRdKeys: TTabSheet
        Caption = #1050#1083#1102#1095#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object btnRdKeys: TButton
          Left = 552
          Top = 14
          Width = 23
          Height = 21
          Caption = '...'
          TabOrder = 0
          OnClick = btnRdKeysClick
        end
        object lbAuthRdKeys: TCheckListBox
          Left = 3
          Top = 17
          Width = 525
          Height = 17
          OnClickCheck = lbAuthRdKeysClickCheck
          Columns = 16
          ItemHeight = 13
          Items.Strings = (
            '0'
            '1'
            '2'
            '3'
            '4'
            '5'
            '6'
            '7'
            '8'
            '9'
            '10'
            '11'
            '12'
            '13'
            '14'
            '15')
          PopupMenu = menuAuthRdKeys
          TabOrder = 1
        end
        object btnAuthRdKeys: TButton
          Left = 528
          Top = 14
          Width = 23
          Height = 21
          ImageAlignment = iaCenter
          ImageIndex = 0
          Images = ImageList1
          TabOrder = 2
          OnClick = btnAuthRdKeysClick
        end
      end
    end
    object rgAuthKeyMode: TRadioGroup
      Left = 151
      Top = 18
      Width = 71
      Height = 64
      Caption = #1058#1080#1087' '#1082#1083#1102#1095#1072
      ItemIndex = 0
      Items.Strings = (
        #1050#1083#1102#1095' '#1040
        #1050#1083#1102#1095' '#1041)
      TabOrder = 0
      OnClick = rgAuthKeyModeClick
    end
    object rgAuthKeySource: TRadioGroup
      Left = 8
      Top = 18
      Width = 137
      Height = 64
      Caption = #1048#1089#1090#1086#1095#1085#1080#1082' '#1082#1083#1102#1095#1077#1081
      ItemIndex = 0
      Items.Strings = (
        #1071#1074#1085#1099#1081' '#1082#1083#1102#1095
        #1050#1083#1102#1095#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103)
      TabOrder = 2
      OnClick = rgAuthKeySourceClick
    end
  end
  object rgDataFormat: TRadioGroup
    Left = 678
    Top = 386
    Width = 200
    Height = 82
    Anchors = [akTop, akRight]
    Caption = #1060#1086#1088#1084#1072#1090' '#1076#1072#1085#1085#1099#1093
    ItemIndex = 2
    Items.Strings = (
      #1044#1074#1086#1080#1095#1085#1099#1081
      #1044#1077#1089#1103#1090#1080#1095#1085#1099#1081
      #1064#1077#1089#1090#1085#1072#1076#1094#1072#1090#1077#1088#1080#1095#1085#1099#1081)
    TabOrder = 7
    OnClick = rgDataFormatClick
  end
  object grTrailLegend: TGroupBox
    Left = 678
    Top = 262
    Width = 200
    Height = 118
    Anchors = [akTop, akRight]
    Caption = #1051#1077#1075#1077#1085#1076#1072' '#1076#1083#1103' '#1087#1088#1080#1094#1077#1087#1072
    TabOrder = 6
    object shLegAccess: TShape
      Left = 8
      Top = 24
      Width = 17
      Height = 17
      Brush.Color = 10027007
    end
    object labLegAccess: TLabel
      Left = 31
      Top = 26
      Width = 53
      Height = 13
      Caption = #1041#1080#1090#1099' '#1076#1086#1089#1090#1091#1087#1072
    end
    object shLegAccessRO: TShape
      Left = 8
      Top = 46
      Width = 17
      Height = 17
      Brush.Color = 12443101
    end
    object labLegAccessRO: TLabel
      Left = 31
      Top = 47
      Width = 109
      Height = 13
      Caption = #1041#1080#1090#1099' '#1076#1086#1089#1090#1091#1087#1072' ('#1090#1086#1083#1100#1082#1086' '#1095#1090#1077#1085#1080#1077')'
    end
    object shLegKeyWO: TShape
      Left = 8
      Top = 67
      Width = 17
      Height = 17
      Brush.Color = 16750805
    end
    object labLegKeyWO: TLabel
      Left = 31
      Top = 69
      Width = 76
      Height = 13
      Caption = #1050#1083#1102#1095' ('#1090#1086#1083#1100#1082#1086' '#1079#1072#1087#1080#1089#1100')'
    end
    object shLegKeyNRW: TShape
      Left = 8
      Top = 90
      Width = 17
      Height = 17
      Brush.Color = clSilver
    end
    object labLegKeyNRW: TLabel
      Left = 31
      Top = 91
      Width = 94
      Height = 13
      Caption = #1050#1083#1102#1095' ('#1085#1077#1083#1100#1079#1103' '#1095#1080#1090#1072#1090#1100'/'#1087#1080#1089#1072#1090#1100')'
    end
  end
  object grDataLegend: TGroupBox
    Left = 678
    Top = 95
    Width = 200
    Height = 161
    Anchors = [akTop, akRight]
    Caption = #1051#1077#1075#1077#1085#1076#1072' '#1076#1083#1103' '#1076#1072#1085#1085#1099#1093
    TabOrder = 5
    object shLegSN: TShape
      Left = 8
      Top = 24
      Width = 17
      Height = 17
      Brush.Color = clSkyBlue
    end
    object labLegSN: TLabel
      Left = 31
      Top = 26
      Width = 66
      Height = 13
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object shLegData: TShape
      Left = 8
      Top = 46
      Width = 17
      Height = 17
      Brush.Color = 11137449
    end
    object labLegData: TLabel
      Left = 31
      Top = 48
      Width = 48
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    end
    object shLegDataRO: TShape
      Left = 8
      Top = 68
      Width = 17
      Height = 17
      Brush.Color = 12442813
    end
    object labLegDataRO: TLabel
      Left = 31
      Top = 70
      Width = 104
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' ('#1090#1086#1083#1100#1082#1086' '#1095#1090#1077#1085#1080#1077')'
    end
    object shLegDataNRW: TShape
      Left = 8
      Top = 134
      Width = 17
      Height = 17
      Brush.Color = clSilver
    end
    object labLegDataNRW: TLabel
      Left = 31
      Top = 136
      Width = 123
      Height = 13
      Caption = #1044#1072#1085#1085#1099#1077' ('#1085#1077#1083#1100#1079#1103' '#1095#1080#1090#1072#1090#1100'/'#1087#1080#1089#1072#1090#1100')'
    end
    object labLegValue: TLabel
      Left = 31
      Top = 91
      Width = 53
      Height = 13
      Caption = #1041#1083#1086#1082'-'#1079#1085#1072#1095#1077#1085#1080#1077
    end
    object shLegValue: TShape
      Left = 8
      Top = 90
      Width = 17
      Height = 17
      Brush.Color = 16777115
    end
    object labLegValueDO: TLabel
      Left = 31
      Top = 113
      Width = 115
      Height = 13
      Caption = #1041#1083#1086#1082'-'#1079#1085#1072#1095#1077#1085#1080#1077' ('#1090#1086#1083#1100#1082#1086' D/T/R)'
    end
    object shLegValueDO: TShape
      Left = 8
      Top = 112
      Width = 17
      Height = 17
      Brush.Color = 14408635
    end
  end
  object grSectorCfg: TGroupBox
    Left = 81
    Top = 599
    Width = 789
    Height = 294
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1089#1077#1082#1090#1086#1088#1072
    TabOrder = 4
    DesignSize = (
      789
      294)
    object labCfgSect: TLabel
      Left = 248
      Top = 0
      Width = 59
      Height = 13
      Caption = 'Sector # 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object grCfgTrailAcc: TGroupBox
      Left = 8
      Top = 96
      Width = 773
      Height = 72
      Anchors = [akLeft, akTop, akRight]
      Caption = #1044#1086#1089#1090#1091#1087' '#1082' '#1087#1088#1080#1094#1077#1087#1091
      TabOrder = 1
      DesignSize = (
        773
        72)
      object pbCfgTrailAcc: TPaintBox
        Left = 8
        Top = 16
        Width = 757
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnPaint = pbCfgTrailAccPaint
        ExplicitWidth = 534
      end
      object cbCfgTrailAcc: TComboBox
        Left = 8
        Top = 41
        Width = 757
        Height = 22
        Hint = 
          #1057#1077#1088#1099#1084' '#1086#1090#1084#1077#1095#1077#1085#1099' '#1091#1089#1083#1086#1074#1080#1103' '#1076#1086#1089#1090#1091#1087#1072' '#1082#1086#1075#1076#1072' '#1082#1083#1102#1095' '#1041' '#1084#1086#1078#1077#1090' '#1073#1099#1090#1100' '#1087#1088#1086#1095#1080#1090#1072#1085' ' +
          #1080' '#1080#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103' '#1082#1072#1082' '#1076#1072#1085#1085#1099#1077
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnDrawItem = cbCfgTrailAccDrawItem
        OnSelect = cbCfgTrailAccSelect
        Items.Strings = (
          
            '0 0 0;'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1041' '#1084#1086#1078#1077#1090' '#1073 +
            #1099#1090#1100' '#1087#1088#1086#1095#1080#1090#1072#1085
          
            '0 1 0;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1041' '#1084#1086#1078#1077#1090 +
            ' '#1073#1099#1090#1100' '#1087#1088#1086#1095#1080#1090#1072#1085
          '1 0 0;'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1041
          '1 1 0;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072
          
            '0 0 1;'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1040';'#1050#1083#1102#1095' '#1041' '#1084#1086#1078#1077#1090' '#1073#1099 +
            #1090#1100' '#1087#1088#1086#1095#1080#1090#1072#1085', '#1090#1088#1072#1085#1089#1087#1086#1088#1090#1085#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103
          '0 1 1;'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1041
          '1 0 1;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072
          '1 1 1;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072)
      end
    end
    object grCfgAuthKeys: TGroupBox
      Left = 8
      Top = 16
      Width = 773
      Height = 80
      Anchors = [akLeft, akTop, akRight]
      Caption = #1050#1083#1102#1095#1080' '#1072#1074#1090#1086#1088#1080#1079#1072#1094#1080#1080
      TabOrder = 0
      DesignSize = (
        773
        80)
      object Label2: TLabel
        Left = 33
        Top = 24
        Width = 32
        Height = 13
        Alignment = taRightJustify
        Caption = #1050#1083#1102#1095' '#1040':'
      end
      object Label4: TLabel
        Left = 34
        Top = 51
        Width = 31
        Height = 13
        Alignment = taRightJustify
        Caption = #1050#1083#1102#1095' '#1041':'
      end
      object labCfgKeyBWarning: TLabel
        Left = 388
        Top = 45
        Width = 373
        Height = 32
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = #1050#1083#1102#1095' '#1041' '#1084#1086#1078#1077#1090' '#1073#1099#1090#1100' '#1087#1088#1086#1095#1080#1090#1072#1085', '#1086#1085' '#1085#1077' '#1084#1086#1078#1077#1090' '#1089#1083#1091#1078#1080#1090#1100' '#1076#1083#1103' '#1072#1074#1090#1086#1088#1080#1079#1072#1094#1080#1080'.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Visible = False
        WordWrap = True
      end
      object edtCfgKeyA: TMaskEdit
        Left = 71
        Top = 21
        Width = 120
        Height = 22
        EditMask = '\0xAAAAAAAAAAAA;0;_'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        MaxLength = 14
        ParentFont = False
        TabOrder = 0
        Text = ''
        OnChange = edtCfgKeyAChange
      end
      object btnCfgRdKeyA: TButton
        Left = 222
        Top = 21
        Width = 160
        Height = 22
        Hint = #1050#1083#1102#1095#1080' '#1080#1079' '#1087#1072#1084#1103#1090#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
        Caption = #1050#1083#1102#1095#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
        ImageAlignment = iaRight
        ImageIndex = 0
        Images = ImageList1
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnCfgRdKeyAClick
      end
      object edtCfgKeyB: TMaskEdit
        Left = 72
        Top = 48
        Width = 119
        Height = 22
        EditMask = '\0xAAAAAAAAAAAA;0;_'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        MaxLength = 14
        ParentFont = False
        TabOrder = 2
        Text = ''
        OnChange = edtCfgKeyBChange
      end
      object btnCfgRdKeyB: TButton
        Left = 222
        Top = 47
        Width = 160
        Height = 22
        Hint = #1050#1083#1102#1095#1080' '#1080#1079' '#1087#1072#1084#1103#1090#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
        Caption = #1050#1083#1102#1095#1080' '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
        ImageAlignment = iaRight
        ImageIndex = 0
        Images = ImageList1
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = btnCfgRdKeyBClick
      end
      object btnCfgKeyA: TButton
        Left = 191
        Top = 21
        Width = 23
        Height = 21
        ImageAlignment = iaCenter
        ImageIndex = 0
        Images = ImageList1
        TabOrder = 4
        OnClick = btnCfgKeyAClick
      end
      object btnCfgKeyB: TButton
        Left = 191
        Top = 48
        Width = 23
        Height = 21
        ImageAlignment = iaCenter
        ImageIndex = 0
        Images = ImageList1
        TabOrder = 5
        OnClick = btnCfgKeyBClick
      end
    end
    object grCfgDataAcc: TGroupBox
      Left = 8
      Top = 168
      Width = 773
      Height = 118
      Anchors = [akLeft, akTop, akRight]
      Caption = #1044#1086#1089#1090#1091#1087' '#1082' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1080#1084' '#1076#1072#1085#1085#1099#1084
      TabOrder = 2
      DesignSize = (
        773
        118)
      object pbCfgDataAcc: TPaintBox
        Left = 71
        Top = 16
        Width = 694
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnPaint = pbCfgDataAccPaint
        ExplicitWidth = 471
      end
      object labCfgArea2: TLabel
        Left = 6
        Top = 44
        Width = 59
        Height = 13
        Alignment = taRightJustify
        Caption = #1041#1083#1086#1082' 10-14:'
      end
      object labCfgArea1: TLabel
        Left = 18
        Top = 69
        Width = 47
        Height = 13
        Alignment = taRightJustify
        Caption = #1041#1083#1086#1082' 5-9:'
      end
      object labCfgArea0: TLabel
        Left = 18
        Top = 94
        Width = 47
        Height = 13
        Alignment = taRightJustify
        Caption = #1041#1083#1086#1082' 0-4:'
      end
      object cbCfgArea2: TComboBox
        Left = 71
        Top = 41
        Width = 694
        Height = 22
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnDrawItem = cbCfgArea2DrawItem
        OnSelect = cbCfgArea2Select
        Items.Strings = (
          
            '0 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1090#1088#1072#1085#1089#1087#1086#1088#1090#1085#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072 +
            #1094#1080#1103
          '0 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 0 1;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 1 1;'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 1;'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 1;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080)
      end
      object cbCfgArea1: TComboBox
        Left = 71
        Top = 66
        Width = 694
        Height = 22
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        OnDrawItem = cbCfgArea1DrawItem
        OnSelect = cbCfgArea1Select
        Items.Strings = (
          
            '0 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1090#1088#1072#1085#1089#1087#1086#1088#1090#1085#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072 +
            #1094#1080#1103
          '0 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 0 1;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 1 1;'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 1;'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 1;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080)
      end
      object cbCfgArea0: TComboBox
        Left = 71
        Top = 91
        Width = 694
        Height = 22
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnDrawItem = cbCfgArea0DrawItem
        OnSelect = cbCfgArea0Select
        Items.Strings = (
          
            '0 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1090#1088#1072#1085#1089#1087#1086#1088#1090#1085#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072 +
            #1094#1080#1103
          '0 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 0;'#1050#1083#1102#1095' '#1040'|'#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 0 1;'#1050#1083#1102#1095' '#1040'|'#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1050#1083#1102#1095' '#1040'|'#1041';'#1073#1083#1086#1082' '#1079#1085#1072#1095#1077#1085#1080#1077
          '0 1 1;'#1050#1083#1102#1095' '#1041';'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 0 1;'#1050#1083#1102#1095' '#1041';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080
          '1 1 1;'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1085#1080#1082#1086#1075#1076#1072';'#1073#1083#1086#1082' '#1076#1083#1103' '#1095#1090#1077#1085#1080#1103'-'#1079#1072#1087#1080#1089#1080)
      end
    end
  end
  object btnRead: TButton
    Left = 89
    Top = 899
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&'#1055#1088#1086#1095#1080#1090#1072#1090#1100
    TabOrder = 9
    OnClick = btnReadClick
  end
  object btnWrite: TButton
    Left = 8
    Top = 899
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&'#1047#1072#1087#1080#1089#1072#1090#1100
    TabOrder = 8
    OnClick = btnWriteClick
  end
  object lbRdKeys: TCheckListBox
    Left = 174
    Top = 73
    Width = 174
    Height = 230
    OnClickCheck = lbRdKeysClickCheck
    Columns = 1
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    Items.Strings = (
      ' 0 - 0xFFFFFFFFFFFF'
      ' 1'
      ' 2'
      ' 3'
      ' 4'
      ' 5'
      ' 6'
      ' 7'
      ' 8'
      ' 9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15')
    ParentFont = False
    PopupMenu = menuAuthRdKeys
    TabOrder = 1
    Visible = False
    OnExit = lbRdKeysExit
    OnKeyDown = lbRdKeysKeyDown
  end
  object grValueBlock: TGroupBox
    Left = 86
    Top = 528
    Width = 587
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Value block'
    TabOrder = 10
    object btnMfIncrement: TButton
      Left = 142
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Increment'
      TabOrder = 0
      OnClick = btnMfIncrementClick
    end
    object btnMfDecrement: TButton
      Left = 223
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Decrement'
      TabOrder = 1
      OnClick = btnMfDecrementClick
    end
    object btnMfTransfer: TButton
      Left = 340
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Transfer'
      TabOrder = 2
      OnClick = btnMfTransferClick
    end
    object btnMfRestore: TButton
      Left = 421
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Restore'
      TabOrder = 3
      OnClick = btnMfRestoreClick
    end
    object edtMfValue: TSpinEdit64
      Left = 15
      Top = 27
      Width = 121
      Height = 22
      Increment = 1
      MaxValue = 4294967295
      MinValue = 0
      TabOrder = 4
      Value = 1
    end
  end
  object ImageList1: TImageList
    Left = 536
    Top = 16
  end
  object menuKeys: TPopupMenu
    Left = 403
    Top = 68
  end
  object menuRdKeys: TPopupMenu
    Left = 433
    Top = 464
  end
  object menuGrid: TPopupMenu
    Left = 456
    Top = 240
    object miReadSector: TMenuItem
      Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1089#1077#1082#1090#1086#1088
      OnClick = miReadSectorClick
    end
    object miReadGroup: TMenuItem
      Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1075#1088#1091#1087#1087#1091
      OnClick = miReadGroupClick
    end
    object miReadAll: TMenuItem
      Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1074#1089#1105
      OnClick = miReadAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miWriteSector: TMenuItem
      Caption = #1047#1072#1087#1080#1089#1072#1090#1100' '#1089#1077#1082#1090#1086#1088
      OnClick = miWriteSectorClick
    end
    object miWriteGroup: TMenuItem
      Caption = #1047#1072#1087#1080#1089#1072#1090#1100' '#1075#1088#1091#1087#1087#1091
      OnClick = miWriteGroupClick
    end
    object miWriteAll: TMenuItem
      Caption = #1047#1072#1087#1080#1089#1072#1090#1100' '#1074#1089#1105
      OnClick = miWriteAllClick
    end
  end
  object menuAuthRdKeys: TPopupMenu
    Left = 512
    Top = 64
    object miAuthRdKeysCheckAll: TMenuItem
      Caption = #1054#1090#1084#1077#1090#1080#1090#1100' '#1074#1089#1105
      OnClick = miAuthRdKeysCheckAllClick
    end
    object miAuthRdKeysUncheckAll: TMenuItem
      Caption = #1057#1085#1103#1090#1100' '#1074#1089#1105
      OnClick = miAuthRdKeysUncheckAllClick
    end
  end
end
