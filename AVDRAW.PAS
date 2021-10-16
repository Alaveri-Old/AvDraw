{$IFDEF debug}
  {$A+,B-,D+,F+,G+,I+,L+,N+,P+,Q+,R+,S+,V+,X+,Y+}
{$ELSE}
  {$A+,B-,D-,F+,G+,I+,L-,N+,P+,Q-,R-,S-,V+,X+,Y-}
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
  Application.Create('Application');
  Application.Run;
  Application.Done;
end.