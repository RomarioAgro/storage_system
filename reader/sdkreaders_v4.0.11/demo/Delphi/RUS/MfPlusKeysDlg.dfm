object fmMfPlusKeysDlg: TfmMfPlusKeysDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1050#1083#1102#1095#1080' Mifare Plus'
  ClientHeight = 362
  ClientWidth = 526
  Color = clBtnFace
  Constraints.MinHeight = 220
  Constraints.MinWidth = 410
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
    526
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 430
    Top = 329
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 308
  end
  object btnOk: TButton
    Left = 336
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
    Width = 512
    Height = 244
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #8470
        Width = 40
      end
      item
        Caption = #1050#1083#1102#1095
        Width = 275
      end
      item
        AutoSize = True
        Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    HideSelection = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawSubItem = ListView1CustomDrawSubItem
    OnData = ListView1Data
    OnDataHint = ListView1DataHint
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
    ExplicitWidth = 506
  end
  object panProperties: TPanel
    Left = 6
    Top = 258
    Width = 512
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 390
    DesignSize = (
      512
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
      Width = 401
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ExplicitWidth = 279
    end
    object edtKey: TMaskEdit
      Left = 104
      Top = 8
      Width = 401
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
      ExplicitWidth = 279
    end
  end
end
