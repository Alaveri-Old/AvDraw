{$IFDEF debug}
  {$A+,B-,D+,E+,F+,G+,I+,L+,N+,O-,P+,Q+,R+,S+,V+,X+,Y+}
{$ELSE}
  {$A+,B-,D-,E+,F+,G+,I+,L-,N+,O-,P+,Q-,R-,S-,V+,X+,Y-}
{$ENDIF}
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