object fmTemicPasswordsDlg: TfmTemicPasswordsDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1055#1072#1088#1086#1083#1080' Temic'
  ClientHeight = 258
  ClientWidth = 421
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
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
    421
    258)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 327
    Top = 225
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 233
    Top = 225
    Width = 88
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object ListView1: TListView
    Left = 8
    Top = 0
    Width = 407
    Height = 148
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1055#1072#1088#1086#1083#1080
        Width = 130
      end
      item
        AutoSize = True
        Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
      end>
    HideSelection = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
    OnDataHint = ListView1DataHint
    OnKeyDown = ListView1KeyDown
    OnSelectItem = ListView1SelectItem
  end
  object panProperties: TPanel
    Left = 8
    Top = 154
    Width = 407
    Height = 65
    Anchors = [akLeft, akRight, akBottom]
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      407
      65)
    object labPassword: TLabel
      Left = 48
      Top = 11
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1072#1088#1086#1083#1100':'
    end
    object labComment: TLabel
      Left = 49
      Top = 38
      Width = 49
      Height = 13
      Alignment = taRightJustify
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    end
    object cbPasswFormat: TComboBox
      Left = 255
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemIndex = 1
      TabOrder = 1
      Text = 'Hexadecimal'
      OnSelect = cbPasswFormatSelect
      Items.Strings = (
        #1044#1077#1089#1103#1090#1080#1095#1085#1099#1081
        #1064#1077#1089#1090#1085#1072#1076#1094#1072#1090#1077#1088#1080#1095#1085#1099#1081)
    end
    object edtComment: TEdit
      Left = 104
      Top = 35
      Width = 296
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object edtPassword: TMaskEdit
      Left = 104
      Top = 8
      Width = 144
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      CharCase = ecUpperCase
      TabOrder = 0
      Text = ''
      OnKeyPress = edtPasswordKeyPress
    end
  end
end
