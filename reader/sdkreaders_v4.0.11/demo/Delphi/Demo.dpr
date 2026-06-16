program Demo;

{$R *.dres}

uses
  Vcl.Forms,
  Vcl.HtmlHelpViewer,
  Main in 'Main.pas' {fmMain},
  uConst in 'uConst.pas',
  uClasses in 'uClasses.pas',
  uReaderLVData in 'uReaderLVData.pas',
  uAppSettings in 'uAppSettings.pas',
  ReaderDlg in 'ReaderDlg.pas' {fmReaderDlg},
  MfUltralightDlg in 'MfUltralightDlg.pas' {fmMfUltralightDlg},
  uTypes in 'uTypes.pas',
  uUtils in 'uUtils.pas',
  TemicDlg in 'TemicDlg.pas' {fmTemicDlg},
  TemicPasswordsDlg in 'TemicPasswordsDlg.pas' {fmTemicPasswordsDlg},
  uTmcPasswLVData in 'uTmcPasswLVData.pas',
  MfClassicDlg in 'MfClassicDlg.pas' {fmMfClassicDlg},
  uMfReaderSettings in 'uMfReaderSettings.pas',
  MfPlusSL3Dlg in 'MfPlusSL3Dlg.pas' {fmMfPlusSL3Dlg},
  MfReaderMcKeysDlg in 'MfReaderMcKeysDlg.pas' {fmMfReaderMcKeysDlg},
  MfReaderMpKeysDlg in 'MfReaderMpKeysDlg.pas' {fmMfReaderMpKeysDlg},
  ProgressDlg in 'ProgressDlg.pas' {fmProgressDlg},
  MfClassicKeysDlg in 'MfClassicKeysDlg.pas' {fmMfClassicKeysDlg},
  uMfClassicKeysLvData in 'uMfClassicKeysLvData.pas',
  MfPlusKeysDlg in 'MfPlusKeysDlg.pas' {fmMfPlusKeysDlg},
  uMfPlusKeysLvData in 'uMfPlusKeysLvData.pas',
  reinit in 'reinit.pas',
  TmcReaderDlg in 'TmcReaderDlg.pas' {fmTmcReaderDlg},
  MfReaderDlg in 'MfReaderDlg.pas' {fmMfReaderDlg},
  MfSecurityLevelDlg in 'MfSecurityLevelDlg.pas' {fmMfSecurityLevelDlg},
  AsyncProgressDlg in 'AsyncProgressDlg.pas' {fmAsyncProgressDlg},
  uAppHelp in 'uAppHelp.pas',
  SpinEdit64 in 'SpinEdit64.pas';

{$R *.res}

begin
  AppInit();
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
