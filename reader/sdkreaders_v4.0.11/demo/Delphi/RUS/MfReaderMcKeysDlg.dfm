object fmMfReaderMcKeysDlg: TfmMfReaderMcKeysDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1050#1083#1102#1095#1080' Mifare Classic '#1089#1095#1080#1090#1099#1074#1072#1090#1077#1083#1103
  ClientHeight = 462
  ClientWidth = 385
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 320
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
    385
    462)
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 6
    Top = 47
    Width = 371
    Height = 305
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = #8470
        Width = 40
      end
      item
        Caption = #1050#1083#1102#1095
        Width = 120
      end
      item
        AutoSize = True
        Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      end>
    HideSelection = False
    Items.ItemData = {
      05EF0100001000000000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000
      000130000E300078004600460046004600460046004600460046004600460046
      00B8C9402A00000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000013100
      00000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001320000000000FF
      FFFFFFFFFFFFFF00000000FFFFFFFF0000000001330000000000FFFFFFFFFFFF
      FFFF00000000FFFFFFFF0000000001340000000000FFFFFFFFFFFFFFFF000000
      00FFFFFFFF0000000001350000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF
      0000000001360000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001
      370000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000013800000000
      00FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001390000000000FFFFFFFF
      FFFFFFFF00000000FFFFFFFF00000000023100300000000000FFFFFFFFFFFFFF
      FF00000000FFFFFFFF00000000023100310000000000FFFFFFFFFFFFFFFF0000
      0000FFFFFFFF00000000023100320000000000FFFFFFFFFFFFFFFF00000000FF
      FFFFFF00000000023100330000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF
      00000000023100340000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
      000231003500FFFF}
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawSubItem = ListView1CustomDrawSubItem
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
    OnItemChecked = ListView1ItemChecked
    ExplicitWidth = 370
  end
  object rgKeyType: TRadioGroup
    Left = 6
    Top = 0
    Width = 155
    Height = 41
    Caption = #1058#1080#1087' '#1082#1083#1102#1095#1072
    Columns = 2
    Items.Strings = (
      #1050#1083#1102#1095' '#1040
      #1050#1083#1102#1095' '#1041)
    TabOrder = 0
    OnClick = rgKeyTypeClick
  end
  object btnCancel: TButton
    Left = 289
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 5
    ExplicitLeft = 288
  end
  object btnOk: TButton
    Left = 195
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOkClick
    ExplicitLeft = 194
  end
  object panProperties: TPanel
    Left = 6
    Top = 358
    Width = 371
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    ShowCaption = False
    TabOrder = 2
    ExplicitWidth = 370
    DesignSize = (
      371
      65)
    object laKey: TLabel
      Left = 76
      Top = 11
      Width = 22
      Height = 13
      Alignment = taRightJustify
      Caption = #1050#1083#1102#1095':'
    end
    object labComment: TLabel
      Left = 49
      Top = 38
      Width = 49
      Height = 13
      Alignment = taRightJustify
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    end
    object edtComment: TEdit
      Left = 104
      Top = 35
      Width = 260
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ExplicitWidth = 259
    end
    object edtKey: TMaskEdit
      Left = 104
      Top = 8
      Width = 260
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      EditMask = '\0xAAAAAAAAAAAA;0;_'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      MaxLength = 14
      ParentFont = False
      TabOrder = 0
      Text = 'ffffffffffff'
      OnKeyPress = edtKeyKeyPress
      ExplicitWidth = 259
    end
  end
  object btnWriteAll: TButton
    Left = 8
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1047#1072#1087#1080#1089#1072#1090#1100' '#1074#1089#1105
    TabOrder = 3
    OnClick = btnWriteAllClick
  end
end
