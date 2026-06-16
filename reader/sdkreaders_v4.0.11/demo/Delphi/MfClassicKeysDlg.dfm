object fmMfClassicKeysDlg: TfmMfClassicKeysDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mifare Classic keys'
  ClientHeight = 362
  ClientWidth = 402
  Color = clBtnFace
  Constraints.MinHeight = 220
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    402
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 306
    Top = 329
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 308
  end
  object btnOk: TButton
    Left = 212
    Top = 329
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
    ExplicitLeft = 214
  end
  object ListView1: TListView
    Left = 6
    Top = 8
    Width = 388
    Height = 244
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = '#'
        Width = 40
      end
      item
        Caption = 'Key'
        Width = 120
      end
      item
        AutoSize = True
        Caption = 'Comment'
      end>
    HideSelection = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawSubItem = ListView1CustomDrawSubItem
    OnData = ListView1Data
    OnDataHint = ListView1DataHint
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
    ExplicitWidth = 390
  end
  object panProperties: TPanel
    Left = 6
    Top = 258
    Width = 388
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 390
    DesignSize = (
      388
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
      Width = 277
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ExplicitWidth = 279
    end
    object edtKey: TMaskEdit
      Left = 104
      Top = 8
      Width = 275
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
      Text = ''
      OnKeyPress = edtKeyKeyPress
      ExplicitWidth = 277
    end
  end
end
