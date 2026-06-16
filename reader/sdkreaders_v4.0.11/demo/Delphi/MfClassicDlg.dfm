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
    Caption = 'Authorization'
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
        Caption = 'Explicit key'
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
        Caption = 'Reader keys'
        ImageIndex = 1
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
      Caption = 'Key type'
      ItemIndex = 0
      Items.Strings = (
        'Key A'
        'Key B')
      TabOrder = 0
      OnClick = rgAuthKeyModeClick
    end
    object rgAuthKeySource: TRadioGroup
      Left = 8
      Top = 18
      Width = 137
      Height = 64
      Caption = 'Key source'
      ItemIndex = 0
      Items.Strings = (
        'Explicit key'
        'Reader keys')
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
    Caption = 'Data format'
    ItemIndex = 2
    Items.Strings = (
      'Binary'
      'Decimal'
      'Hexadecimal')
    TabOrder = 7
    OnClick = rgDataFormatClick
  end
  object grTrailLegend: TGroupBox
    Left = 678
    Top = 262
    Width = 200
    Height = 118
    Anchors = [akTop, akRight]
    Caption = 'Legend for Trailer'
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
      Caption = 'Access bits'
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
      Caption = 'Access bits (read only)'
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
      Caption = 'Key (write only)'
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
      Caption = 'Key (no read/write)'
    end
  end
  object grDataLegend: TGroupBox
    Left = 678
    Top = 95
    Width = 200
    Height = 161
    Anchors = [akTop, akRight]
    Caption = 'Legend for Data'
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
      Caption = 'Serial Number'
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
      Caption = 'User Data'
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
      Caption = 'User Data (read only)'
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
      Caption = 'User data (no read/write)'
    end
    object labLegValue: TLabel
      Left = 31
      Top = 91
      Width = 53
      Height = 13
      Caption = 'Value block'
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
      Caption = 'Value block (D/T/R only)'
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
    Caption = 'Sector configuration'
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
      Caption = 'Trailer Access'
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
          'The gray marked lines are access conditions where Key B is reada' +
          'ble and may be used for data'
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnDrawItem = cbCfgTrailAccDrawItem
        OnSelect = cbCfgTrailAccSelect
        Items.Strings = (
          '0 0 0;never;Key A;Key A;never;Key A;Key A;Key B may be read'
          '0 1 0;never;never;Key A;never;Key A;never;Key B may be read'
          '1 0 0;never;Key B;Key A|B;never;never;Key B'
          '1 1 0;never;never;Key A|B;never;never;never'
          
            '0 0 1;never;Key A;Key A;Key A;Key A;Key A;Key B may be read, tra' +
            'nsport config'
          '0 1 1;never;Key B;Key A|B;Key B;never;Key B'
          '1 0 1;never;never;Key A|B;Key B;never;never'
          '1 1 1;never;never;Key A|B;never;never;never')
      end
    end
    object grCfgAuthKeys: TGroupBox
      Left = 8
      Top = 16
      Width = 773
      Height = 80
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Authorization keys'
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
        Caption = 'Key A:'
      end
      object Label4: TLabel
        Left = 34
        Top = 51
        Width = 31
        Height = 13
        Alignment = taRightJustify
        Caption = 'Key B:'
      end
      object labCfgKeyBWarning: TLabel
        Left = 388
        Top = 45
        Width = 373
        Height = 32
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Key B must by read. Cannot use for authorization.'
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
        Hint = 'Keys from memory reader'
        Caption = 'Reader keys'
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
        Hint = 'Keys from memory reader'
        Caption = 'Reader keys'
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
      Caption = 'User Data Access'
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
        Caption = 'Block 10-14:'
      end
      object labCfgArea1: TLabel
        Left = 18
        Top = 69
        Width = 47
        Height = 13
        Alignment = taRightJustify
        Caption = 'Block 5-9:'
      end
      object labCfgArea0: TLabel
        Left = 18
        Top = 94
        Width = 47
        Height = 13
        Alignment = taRightJustify
        Caption = 'Block 0-4:'
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
          '0 0 0;Key A|B;Key A|B;Key A|B;Key A|B;transport configuration'
          '0 1 0;Key A|B;never;never;never;read/write block'
          '1 0 0;Key A|B;Key B;never;never;read/write block'
          '1 1 0;Key A|B;Key B;Key B;Key A|B;value block'
          '0 0 1;Key A|B;never;never;Key A|B;value block'
          '0 1 1;Key B;Key B;never;never;read/write block'
          '1 0 1;Key B;never;never;never;read/write block'
          '1 1 1;never;never;never;never;read/write block')
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
          '0 0 0;Key A|B;Key A|B;Key A|B;Key A|B;transport configuration'
          '0 1 0;Key A|B;never;never;never;read/write block'
          '1 0 0;Key A|B;Key B;never;never;read/write block'
          '1 1 0;Key A|B;Key B;Key B;Key A|B;value block'
          '0 0 1;Key A|B;never;never;Key A|B;value block'
          '0 1 1;Key B;Key B;never;never;read/write block'
          '1 0 1;Key B;never;never;never;read/write block'
          '1 1 1;never;never;never;never;read/write block')
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
          '0 0 0;Key A|B;Key A|B;Key A|B;Key A|B;transport configuration'
          '0 1 0;Key A|B;never;never;never;read/write block'
          '1 0 0;Key A|B;Key B;never;never;read/write block'
          '1 1 0;Key A|B;Key B;Key B;Key A|B;value block'
          '0 0 1;Key A|B;never;never;Key A|B;value block'
          '0 1 1;Key B;Key B;never;never;read/write block'
          '1 0 1;Key B;never;never;never;read/write block'
          '1 1 1;never;never;never;never;read/write block')
      end
    end
  end
  object btnRead: TButton
    Left = 89
    Top = 899
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Read'
    TabOrder = 9
    OnClick = btnReadClick
  end
  object btnWrite: TButton
    Left = 8
    Top = 899
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Write'
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
      Caption = 'Read Sector'
      OnClick = miReadSectorClick
    end
    object miReadGroup: TMenuItem
      Caption = 'Read Group'
      OnClick = miReadGroupClick
    end
    object miReadAll: TMenuItem
      Caption = 'Read All'
      OnClick = miReadAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miWriteSector: TMenuItem
      Caption = 'Write Sector'
      OnClick = miWriteSectorClick
    end
    object miWriteGroup: TMenuItem
      Caption = 'Write Group'
      OnClick = miWriteGroupClick
    end
    object miWriteAll: TMenuItem
      Caption = 'Write All'
      OnClick = miWriteAllClick
    end
  end
  object menuAuthRdKeys: TPopupMenu
    Left = 512
    Top = 64
    object miAuthRdKeysCheckAll: TMenuItem
      Caption = 'Check All'
      OnClick = miAuthRdKeysCheckAllClick
    end
    object miAuthRdKeysUncheckAll: TMenuItem
      Caption = 'Uncheck All'
      OnClick = miAuthRdKeysUncheckAllClick
    end
  end
end
