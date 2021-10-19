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
  PDrawApp = ^TDrawApp;
  TDrawApp = object(TApplication)
  private
  public
    InterfaceMem: longint;
    { Controls }
    Desktop: PDesktop;

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
  modeIndex := Graphics.Modes.IndexOfId('SVGA640x480x256');
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
var
  control: PControl;
  menuBar: PMenuBar;
  menu: PMenu;
  item: PMenuItem;
begin
  menuBar := Desktop^.MenuBar;
  menu := New(PMenu, Create('FileMenu'));
  item := New(PMenuItem, CreateMenuBar('FileMenuItem', '&File', menuBar, menu, kAltF, nil));
  control := New(PMenuItem, CreateText('NewMenuItem', '&New...', menu, kCtrlN, nil));
  control^.ToolTip := 'Create a new image or animation';
  control := New(PMenuItem, CreateSeparator('~Separator', menu));
  control := New(PMenuItem, CreateText('OpenMenuItem', '&Open...', menu, kCtrlO, nil));
  control^.ToolTip := 'Open an existing image or animation';
  control := New(PMenuItem, CreateText('SaveMenuItem', '&Save', menu, kCtrlS, nil));
  control^.ToolTip := 'Save the current file';
  control := New(PMenuItem, CreateText('SaveAsMenuItem', 'Save &As...', menu, 0, nil));
  control^.ToolTip := 'Save the current file under a new name, directory or drive';
  control := New(PMenuItem, CreateText('SaveAllMenuItem', 'Save A&ll', menu, 0, nil));
  control := New(PMenuItem, CreateSeparator('~Separator', menu));
  control := New(PMenuItem, CreateText('CloseMenuItem', '&Close', menu, 0, nil));
  control := New(PMenuItem, CreateText('CloseAllMenuItem', 'Clos&e All', menu, 0, nil));
  control := New(PMenuItem, CreateSeparator('~Separator', menu));
  control := New(PMenuItem, CreateText('ExitMenuItem', 'E&xit', menu, kAltX, nil));
  control^.ToolTip := 'Exit the program';

  menu := New(PMenu, Create('EditMenu'));
  item := New(PMenuItem, CreateMenuBar('EditMenuItem', '&Edit', menuBar, menu, kAltE, nil));
  control := New(PMenuItem, CreateText('UndoMenuItem', '&Undo', menu, kCtrlZ, nil));
  control := New(PMenuItem, CreateText('RedoMenuItem', '&Redo', menu, kCtrlY, nil));

  menu := New(PMenu, Create('SearchMenu'));
  item := New(PMenuItem, CreateMenuBar('SearchMenuItem', '&Search', menuBar, menu, kAltS, nil));
  control := New(PMenuItem, CreateText('FindMenuItem', '&Find', menu, kCtrlF, nil));

  menu := New(PMenu, Create('ViewMenu'));
  item := New(PMenuItem, CreateMenuBar('ViewMenuItem', '&View', menuBar, menu, kAltV, nil));
  control := New(PMenuItem, CreateText('FullScreenMenuItem', '&Full Screen', menu, kSpace, nil));

  menu := New(PMenu, Create('HelpMenu'));
  item := New(PMenuItem, CreateMenuBar('HelpMenuItem', '&Help', menuBar, menu, kAltH, nil));
  control := New(PMenuItem, CreateText('AboutMenuItem', '&About', menu, 0, nil));
end;

procedure TDrawApp.InitControls;
begin
  Desktop := new(PDesktop, Create('Application'));
  with Desktop^ do begin
    SetBounds(0, 0, Graphics.Mode.Width, Graphics.Mode.Height);
    ForeColor := icDesktop;
    BackColor := icDesktopBack;
    SetupControls;
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
  icFocused := Graphics.GetColor(scGreen, MaxIntensity);
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
      'XMS memory enabled.',
      #10#13,
      longint(Memory.LowerMemAvail),
      ' bytes lower memory available.',
      #10#13,
      longint(Memory.XmsMemAvail),
      ' bytes XMS memory available.'
    );
  end;
  InitGraphics;
  WriteLn('Graphics initialized.');
  InitDefaultColors;
  InitMouse;
  WriteLn('Mouse initialized.');
  InitControls;
end;

destructor TDrawApp.Done;
begin
  Memory.Done;
  Graphics.Done;
end;

procedure TDrawApp.Run;
begin
  Desktop^.Draw;
  TApplication.Run;
end;

end.