program OutLookMailTest;

uses
  FastMM5 in '..\Attracs-Common\components\core\FastMM5.pas',
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
