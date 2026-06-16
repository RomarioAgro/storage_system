object fmMfReaderMpKeysDlg: TfmMfReaderMpKeysDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare reader Plus keys'
  ClientHeight = 462
  ClientWidth = 516
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
    516
    462)
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 6
    Top = 47
    Width = 502
    Height = 305
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = '#'
        Width = 40
      end
      item
        Caption = 'Key'
        Width = 275
      end
      item
        AutoSize = True
        Caption = 'Comment'
      end>
    HideSelection = False
    Items.ItemData = {
      05190200001000000000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000
      0001300023460046004600460046004600460046002000460046004600460046
      0046004600460020004600460046004600460046004600460020004600460046
      0046004600460046004600780EE91E00000000FFFFFFFFFFFFFFFF00000000FF
      FFFFFF0000000001310000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000
      000001320000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000013300
      00000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001340000000000FF
      FFFFFFFFFFFFFF00000000FFFFFFFF0000000001350000000000FFFFFFFFFFFF
      FFFF00000000FFFFFFFF0000000001360000000000FFFFFFFFFFFFFFFF000000
      00FFFFFFFF0000000001370000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF
      0000000001380000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001
      390000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000023100300000
      000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000023100310000000000
      FFFFFFFFFFFFFFFF00000000FFFFFFFF00000000023100320000000000FFFFFF
      FFFFFFFFFF00000000FFFFFFFF00000000023100330000000000FFFFFFFFFFFF
      FFFF00000000FFFFFFFF00000000023100340000000000FFFFFFFFFFFFFFFF00
      000000FFFFFFFF000000000231003500FFFF}
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawSubItem = ListView1CustomDrawSubItem
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
    OnItemChecked = ListView1ItemChecked
    ExplicitWidth = 501
  end
  object rgKeyType: TRadioGroup
    Left = 6
    Top = 0
    Width = 155
    Height = 41
    Caption = 'Key type'
    Columns = 2
    Items.Strings = (
      'Key A'
      'Key B')
    TabOrder = 0
    OnClick = rgKeyTypeClick
  end
  object btnCancel: TButton
    Left = 420
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    ExplicitLeft = 329
  end
  object btnOk: TButton
    Left = 326
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOkClick
    ExplicitLeft = 235
  end
  object panProperties: TPanel
    Left = 6
    Top = 358
    Width = 502
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    ShowCaption = False
    TabOrder = 2
    ExplicitWidth = 411
    DesignSize = (
      502
      65)
    object laKey: TLabel
      Left = 76
      Top = 11
      Width = 22
      Height = 13
      Alignment = taRightJustify
      Caption = 'Key:'
    end
    object labComment: TLabel
      Left = 49
      Top = 38
      Width = 49
      Height = 13
      Alignment = taRightJustify
      Caption = 'Comment:'
    end
    object edtComment: TEdit
      Left = 104
      Top = 35
      Width = 391
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ExplicitWidth = 300
    end
    object edtKey: TMaskEdit
      Left = 104
      Top = 8
      Width = 391
      Height = 22
      Anchors = [akLeft, akTop, akRight]
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
      OnKeyPress = edtKeyKeyPress
      ExplicitWidth = 300
    end
  end
  object btnWriteAll: TButton
    Left = 8
    Top = 429
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Write All'
    TabOrder = 3
    OnClick = btnWriteAllClick
  end
end
