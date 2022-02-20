{$I Compiler.inc}
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
  MouseDrv,
  Streams,
  Apps,
  GraphApp;

type
  PDrawApp = ^TDrawApp;
  TDrawApp = object(TGraphicApplication)
  private
  public
    { Controls }

    { Properties }
    procedure Init; virtual;
    procedure InitMenubar; virtual;
    procedure MainLoop; virtual;
    procedure InitControls; virtual;
    destructor Done; virtual;
  end;

implementation

uses
  Globals;

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
  with Desktop^ do begin
    SetBounds(0, 0, Graphics.Mode^.Width, Graphics.Mode^.Height);
    ForeColor := icDesktop;
    BackColor := icDesktopBack;
    SetupControls;
  end;
  InitMenuBar;
end;

destructor TDrawApp.Done;
begin
  Graphics.Done;
end;

procedure TDrawApp.Init;
begin
  TypeName := 'TDrawApp';
  InitGraphics(gdSVga256, 'SVGA1024x768x8');
  TGraphicApplication.Init;
  if (Graphics.Error.ErrorCode <> ecNone) then
  begin
    WriteLn('Error: ', Graphics.Error.ErrorCode, ': ', Graphics.Error.ErrorMessage);
    Close;
    exit;
  end
  else
  begin
    WriteLn('Graphics initialized.');
  end;
  InitControls;
  Desktop^.Draw;
end;

procedure TDrawApp.MainLoop;
begin
end;

end.