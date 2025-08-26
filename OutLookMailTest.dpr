program OutLookMailTest;

// Change path for FastMM5 or FastMM4 do detect memleaks easier. Or just remove it and use builtin
uses
  FastMM5 in '..\Attracs-Common\components\core\FastMM5.pas',
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EFastMM5Support,
  EDebugJCL,
  EDebugExports,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  Vcl.Forms,
  uOutLookMailTest in 'uOutLookMailTest.pas' {OutLookAzureTest};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TOutLookAzureTest, OutLookAzureTest);
  Application.Run;
end.

