{$I Compiler.inc}
program AvDraw(input, output);

uses
  Globals,
  Apps,
  Utils,
  DrawApp;

begin
  ExeName := ParamStr(0);
  AppDirectory := ExtractFilePath(ExeName);
  Application.Create('Application', 65536);
  Application.Run;
  Application.Done;
end.