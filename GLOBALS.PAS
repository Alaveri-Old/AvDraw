{$IFDEF debug}
  {$A+,B-,D+,F+,G+,I+,L+,N+,P+,Q+,R+,S+,V+,X+,Y+}
{$ELSE}
  {$A+,B-,D-,F+,G+,I+,L-,N+,P+,Q-,R-,S-,V+,X+,Y-}
{$ENDIF}
unit Globals;

interface

uses
  Objects,
  Controls,
  Apps,
  Utils,
  KeyDrv,
  GraphDrv,
  MemDrv,
  DrawApp;

var
  Application: TDrawApp;
  ExeName: string;
  AppDirectory: string;

implementation

end.