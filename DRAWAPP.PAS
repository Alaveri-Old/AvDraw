{$IFDEF debug}
  {$A-,B-,D+,F+,G+,I+,L+,N+,P+,Q+,R+,S+,V+,X+,Y+}
{$ELSE}
  {$A-,B-,D-,F+,G+,I+,L-,N+,P+,Q-,R-,S-,V+,X+,Y-}
{$ENDIF}
unit DrawApp;

interface

uses
  Crt,
  Objects,
  Controls,
  KeyDrv,
  GraphDrv,
  GraphIni,
  SVgaDrv,
  MemDrv,
  WideStr,
  Drawing,
  Utils,
  Mouse,
  Streams,
  Apps;

const
  InterfaceReservedMem = 65536;

type
  PGraphicDesktop = ^TGraphicDesktop;
  TGraphicDesktop = object(TDesktop)
  public
    procedure GetClientRect(var rect: TRect); virtual;
  end;
  PDrawApp = ^TDrawApp;
  TDrawApp = object(TApplication)
  private
  public
    InterfaceMem: longint;
    { Controls }
    Desktop: PGraphicDesktop;

    { Properties }
    procedure Init; virtual;
    procedure Run; virtual;
    procedure InitDefaultColors; virtual;
    procedure InitGraphics; virtual;
    procedure InitMenubar; virtual;
    procedure InitControls; virtual;
    destructor Done; virtual;
  end;

implementation

uses
  Globals;

procedure TDrawApp.InitGraphics;
var
  mode: PGraphicsMode;
  modeIndex: integer;
  error: TError;
  factory: TGraphicsFactory;
  rect: TRect;
begin
  factory.Create;
  factory.GetGraphicsDriver(gdSVga256, Graphics);
  modeIndex := Graphics.Modes.IndexOfId('SVGA1024x768x256');
  mode := Graphics.Modes.GetItem(modeIndex);
  Graphics.SetMode(mode^, error);
  if (error.ErrorCode <> ecNone) then
  begin
    WriteLn(error.ErrorCode, ': ', error.ErrorMessage);
    Halt(error.ErrorCode);
  end;
  rect.Create(0, 0, mode^.MaxX, mode^.MaxY);
  Graphics.SetViewPort(rect);
end;

procedure TDrawApp.InitMenubar;
begin
end;

procedure TDrawApp.InitControls;
begin
  Desktop := new(PGraphicDesktop, Create('Application'));
  with Desktop^ do begin
    SetBounds(0, 0, Graphics.Mode.MaxX, Graphics.Mode.MaxY);
    ForeColor := icDesktop;
    BackColor := icDesktopBack;
  end;
  InitMenuBar;
end;

procedure TDrawApp.InitDefaultColors;
begin
  icDesktop := Graphics.GetColor(scWhite, MaxIntensity);
  icDesktopBack := Graphics.GetColor(scGreen, MaxIntensity);
  icWindow := Graphics.GetColor(scBlack, 0);
  icWindowBack := Graphics.GetColor(scWhite, MaxIntensity);
  icBorder := Graphics.GetColor(scBlack, 0);
  icButton := Graphics.GetColor(scBlack, 0);
  icButtonBack := Graphics.GetColor(scWhite, Intensity75);
  icButtonDown := Graphics.GetColor(scBlack, 0);
  icButtonDownBack := Graphics.GetColor(scWhite, Intensity75);
  icButtonHotKey := Graphics.GetColor(scRed, MaxIntensity);
  icButtonShadow := Graphics.GetColor(scWhite, Intensity25);
  icButtonHighlight := Graphics.GetColor(scWhite, 11);
  icWindowTitle := Graphics.GetColor(scBlack, 0);
  icWindowTitleBack := Graphics.GetColor(scGreen, MaxIntensity);
  icMenu := Graphics.GetColor(scBlack, 0);
  icMenuBack := Graphics.GetColor(scWhite, MaxIntensity);
  icHotKey := Graphics.GetColor(scRed, MaxIntensity);
  icScroll := Graphics.GetColor(scBlack, 0);
  icScrollBack := Graphics.GetColor(scWhite, Intensity50);
  icEditor := Graphics.GetColor(scBlack, MaxIntensity);
  icEditorBack := Graphics.GetColor(scWhite, MaxIntensity);
  icDialog := Graphics.GetColor(scBlack, 0);
  icDialogBack := Graphics.GetColor(scCyan, MaxIntensity);
  icSelect := Graphics.GetColor(scWhite, MaxIntensity);
  icSelectBack := Graphics.GetColor(scGreen, MaxIntensity);
  icFocusedBack := Graphics.GetColor(scGreen, MaxIntensity);
end;

procedure TDrawApp.Init;
var
  error: TError;
  test: TMemoryStream;
  buffer: PReference;
  {$IFDEF debug}
    filename: string;
    debugFile: File;
    xmsHandle: word;
    xmsControl: pointer;
  {$ENDIF}


  stream: TMemoryStream;
  count: integer;
begin
  TApplication.Init;
  TypeName := 'TDrawApp';
  ClrScr;
  {$IFDEF debug}
    { Deallocate the last used XMS handle if the program abnormally terminated}
    filename := 'XmsDebug.bin';
    if FileExists(FileName) then
    begin
      Assign(debugFile, filename);
      Reset(debugFile, 1);
      BlockRead(debugFile, xmsHandle, SizeOf(xmsHandle));
      System.Close(debugFile);
      asm
        push es
        mov  ax, 4310h
        int  2Fh
        mov  word ptr [xmsControl], bx
        mov  word ptr [xmsControl + 2], es
        pop  es
      end;
      asm
        mov  ah, 0Ah
        mov  dx, [xmsHandle]
        call [XmsControl]
      end;
    end;
  {$ENDIF}
  Memory.Create(InterfaceReservedMem);
  WriteLn('Memory manager initialized.');
  if (Memory.XmsEnabled) then
  begin
    WriteLn
    (
      'XMS Memory Enabled.',
      #10#13,
      MemAvail,
      ' bytes lower memory available.',
      #10#13,
      longint(Memory.XmsMemAvail),
      ' bytes XMS memory available.'
    );
  end;

  stream.Create(2097152, error);
  stream.Done;

{  InitGraphics;
  WriteLn('Graphics initialized.');
  InitDefaultColors;
  InitMouse;
  WriteLn('Mouse initialized.');
  InitControls;}
end;

destructor TDrawApp.Done;
begin
  Memory.Done;
{  Graphics.Done;}
end;

procedure TDrawApp.Run;
begin
{  Desktop^.Draw;}
  TApplication.Run;
end;

procedure TGraphicDesktop.GetClientRect(var rect: TRect);
begin
  rect.Create(0, 0, Graphics.Mode.Width, Graphics.Mode.Height);
end;

end.