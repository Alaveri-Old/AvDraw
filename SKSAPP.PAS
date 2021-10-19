{$O+,F+}
unit SksApp;

interface

uses
  Overlay,
  Crt,
  Apps,
  Objects,
  WideStr,
  TextCont,
  TextDraw,
  Drawing,
  Mouse,
  Keyboard,
  DateTime;

type
  TEditMode =
  (
    emDraw,
    emText,
    emSelect
  );
  PDrawApp = ^TDrawApp;
  TDrawApp = object(TApplication)
    KeyDriver: TKeyboardDriver;
    DrawingWindow: PWindow;
    ToolWindow: PWindow;
    DrawButton: PButton;
    TextButton: PButton;
    SelectButton: PButton;
    LineButton: PButton;
    CircleButton: PButton;
    RectButton: PButton;
    FillButton: PButton;
    BoundaryButton: PButton;
    Image: PImage;
    CharBox: PPanel;
    NewDialog: PDialog;
    NewOkButton: PDialogButton;
    NewCancelButton: PDialogButton;
    NewWidthLabel: PLabel;
    NewHeightLabel: PLabel;
    NewWidthEntry: PIntegerEdit;
    NewHeightEntry: PIntegerEdit;
    TestEntry: PEditBox;
    CurrentChar: byte;
    Closed: boolean;
    Desktop: PDesktop;
    EditMode: TEditMode;
    procedure WriteChar(x, y: integer; ch: TTextChar);
    procedure Refresh; virtual;
    procedure DrawChars;
    procedure NewImage(width, height: word);
    procedure ResetImageControls;
    procedure CreateMainMenu; virtual;
    procedure Init; virtual;
    procedure Run; virtual;
    destructor Done; virtual;
  end;

const
  EditModeText: array[TEditMode] of string =
  (
    'Draw',
    'Text',
    'Select'
  );

implementation

uses
  Globals,
  EventHnd;

procedure TDrawApp.WriteChar(x, y: integer; ch: TTextChar);
var
  sourceRect: TRect;
  sourcePos: PTextChar;
begin
  Image^.GetBounds(sourceRect);
  sourceRect.Translate(DrawingWindow^.Contents^.ScrollX, DrawingWindow^.Contents^.ScrollY);
  sourceRect.SetWidth(sourceRect.Width - DrawingWindow^.Contents^.ScrollX);
  sourceRect.SetHeight(sourceRect.Height - DrawingWindow^.Contents^.ScrollY);
  sourcePos := Image^.Data;
  Inc(sourcePos, (y - sourceRect.Y) * Image^.Width + (x + sourceRect.X));
  sourcePos^ := ch;
end;

procedure TDrawApp.Refresh;
begin
  HideMouse;
  Desktop^.Draw;
  DrawChars;
  if (Image^.Data <> nil) and (EditMode = emText) then
    Drawer.CursorOn
  else
    Drawer.CursorOff;
  Image^.SetXY(0, 0);
  Image^.Focus;
  ShowMouse;
end;

procedure TDrawApp.CreateMainMenu;
var
  control: PControl;
  menuBar: PMenuBar;
  menu: PMenu;
  item: PMenuItem;
begin
  menuBar := Desktop^.MenuBar;
  menu := New(PMenu, Create('FileMenu'));
  item := New(PMenuItem, CreateMenuBar('FileMenuItem', '&File', menuBar, menu, kAltF, nil));
  control := New(PMenuItem, CreateText('NewMenuItem', '&New...', menu, kCtrlN, @NewClick));
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
  control := New(PMenuItem, CreateText('ExitMenuItem', 'E&xit', menu, kAltX, @ExitClick));
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

procedure TDrawApp.Init;
var
  rect: TRect;

  test: TDateTime;
  test2: TDateTime;
  temp: longint;
  ticks: comp;
begin
  test.CreateCurrent;
  temp := test.year;
  temp := test.month;
  temp := test.day;
  temp := test.hour;
  temp := test.minute;
  temp := test.second;
  temp := test.HundredthSecond;
  ticks := test.ticks;
  test2.CreateTicks(ticks);
  temp := test2.year;
  temp := test2.month;
  temp := test2.day;
  temp := test2.hour;
  temp := test2.minute;
  temp := test2.second;
  temp := test2.HundredthSecond;


  ClrScr;
  TApplication.Init;
  TypeName := 'TDrawApp';
  KeyDriver.Create;
  InitMouse;
  ShowMouse;
  CurrentChar := 1;
  Closed := false;
  EditMode := emText;

  Desktop := New(PDesktop, CreateParent('Desktop', nil));
  with Desktop^ do
  begin
    SetBounds(0, 0, 80, 25);
    OnKeyPress := @DesktopKeyPress;
    ForeColor := LightGray;
    BackColor := Black;
  end;

  NewDialog := New(PDialog, CreateParent('NewDialog', Desktop));
  with NewDialog^ do
  begin
    Title := 'New File';
    Width := 60;
    Height := 15;
    SetScreenCenter;
    GetClientRect(rect);
    NewWidthLabel := New(PLabel, CreateText('NewWidthLabel', 'Width:', NewDialog^.Contents));
    NewWidthLabel^.SetBounds(1, 4, 6, 1);
    NewHeightLabel := New(PLabel, CreateText('NewHeightLabel', 'Height:', NewDialog^.Contents));
    NewHeightLabel^.SetBounds(1, 5, 7, 1);

    TestEntry := New(PEditBox, CreateParent('TestEntry', NewDialog^.Contents));
    with TestEntry^ do
    begin
      SetBounds(1, 1, NewDialog^.Width - 4, 1);
      TestEntry^.Text^.SetString
      (
        'This is a test of the entry system.  '
        + 'Had this been some actual problem, which it was, '
        + 'it would have been annoying.'
      );
      TestEntry^.CursorEnd;
    end;

    NewWidthEntry := New(PIntegerEdit, CreateParent('NewWidthEntry', NewDialog^.Contents));
    with NewWidthEntry^ do
    begin
      Value := 10;
      MaxValue := 80;
      MinValue := 10;
      SetBounds(9, 4, 0, 0);
    end;
    NewHeightEntry := New(PIntegerEdit, CreateParent('NewHeightEntry', NewDialog^.Contents));
    with NewHeightEntry^ do
    begin
      Value := 10;
      MaxValue := 25;
      MinValue := 1;
      SetBounds(9, 5, 0, 0);
    end;
    NewOkButton := New(PDialogButton, CreateText('NewOkButton', 'Ok', nil));
    NewCancelButton := New(PDialogButton, CreateText('NewCancelButton', 'Cancel', nil));
    AddButton(NewOkButton, true, false, @NewOkClick);
    AddButton(NewCancelButton, false, true, nil);
    SetupControls;
  end;

  CreateMainMenu;

  ToolWindow := New(PWindow, CreateParent('ToolWindow', Desktop));
  with ToolWindow^ do
  begin
    Title := 'Tools';
    SetBounds(0, 1, 24, 23);
  end;

  DrawButton := New(PButton, CreateParent('DrawButton', ToolWindow^.Contents));
  with DrawButton^ do
  begin
    SetBounds(1, 1, 3, 1);
    Text := #24;
    Toggle := true;
    Grouped := true;
    ToolTip := 'Drawing Mode';
    TextAlign := taCenter;
  end;

  TextButton := New(PButton, CreateParent('TextButton', ToolWindow^.Contents));
  with TextButton^ do
  begin
    SetBounds(1, 3, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := 'T';
    ToolTip := 'Text Mode';
    TextAlign := taCenter;
  end;

  SelectButton := New(PButton, CreateParent('SelectButton', ToolWindow^.Contents));
  with SelectButton^ do
  begin
    SetBounds(1, 5, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := 'S';
    ToolTip := 'Select Mode';
    TextAlign := taCenter;
  end;

  LineButton := New(PButton, CreateParent('LineButton', ToolWindow^.Contents));
  with LineButton^ do
  begin
    SetBounds(1, 7, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := '-';
    ToolTip := 'Line Mode';
    TextAlign := taCenter;
  end;

  CircleButton := New(PButton, CreateParent('CircleButton', ToolWindow^.Contents));
  with CircleButton^ do
  begin
    SetBounds(1, 9, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := #9;
    ToolTip := 'Circle Mode';
    TextAlign := taCenter;
  end;

  RectButton := New(PButton, CreateParent('RectButton', ToolWindow^.Contents));
  with RectButton^ do
  begin
    SetBounds(1, 11, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := #254;
    ToolTip := 'Rectangle Mode';
    TextAlign := taCenter;
  end;

  FillButton := New(PButton, CreateParent('FillButton', ToolWindow^.Contents));
  with FillButton^ do
  begin
    SetBounds(1, 13, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := #15;
    ToolTip := 'Fill Mode';
    TextAlign := taCenter;
  end;

  BoundaryButton := New(PButton, CreateParent('BoundaryButton', ToolWindow^.Contents));
  with BoundaryButton^ do
  begin
    SetBounds(1, 15, 3, 1);
    Toggle := true;
    Grouped := true;
    Text := #201'';
    ToolTip := 'Boundary Mode';
    TextAlign := taCenter;
  end;

  DrawingWindow := New(PWindow, CreateParent('DrawingWindow', Desktop));
  with DrawingWindow^ do
  begin
    Title := 'Editor';
    SetBounds(24, 1, 56, 23);
  end;

  CharBox := New(PPanel, CreateParent('DrawingWindow', ToolWindow^.Contents));
  with CharBox^ do
  begin
    BorderStyle := bsNone;
    BorderColor := White;
    ForeColor := White;
    BackColor := Black;
    SetBounds(5, 1, 16, 16);
    OnKeyPress := @CharBoxKeyPress;
  end;

  DrawButton^.Pressed := true;

  Image := New(PImage, CreateParent('Image', DrawingWindow^.Contents));
  with Image^ do
  begin
    CanFocus := false;
    UsesCursor := true;
  end;
end;

procedure TDrawApp.ResetImageControls;
begin
  with DrawingWindow^ do
  begin
    VertScrollbar^.SetValue(0);
    HorzScrollbar^.SetValue(0);
    Contents^.ScrollX := 0;
  end;
  DrawingWindow^.Contents^.ScrollX := 0;
  DrawingWindow^.Contents^.ScrollY := 0;
end;

procedure TDrawApp.DrawChars;
var
  rect: TRect;
  xPos, yPos: byte;
  index: byte;
  ch: TTextChar;
begin
  CharBox^.GetScreenBounds(rect);
  index := 0;
  ch.Character := 0;
  for yPos := 0 to 15 do
  begin
    for xPos := 0 to 15 do
    begin
      if (ch.Character = CurrentChar) then
        ch.Attributes := Drawer.GetCharAttributes(Yellow, Black)
      else if (ch.Character div 16) = (CurrentChar div 16) then
        ch.Attributes := Drawer.GetCharAttributes(LightBlue, Black)
      else if (ch.Character mod 16) = (CurrentChar mod 16) then
        ch.Attributes := Drawer.GetCharAttributes(LightBlue, Black)
    else
      ch.Attributes := Drawer.GetCharAttributes(Blue, Black);
    Move(ch, Drawer.CurrentScreen^[rect.Y + yPos, rect.X + xPos], 2);
    Inc(ch.Character);
    end;
  end;
end;

procedure TDrawApp.NewImage(width, height: word);
var
  ch: TTextChar;
  tempScreen: pointer;
  rect: TRect;
begin
  ch.Attributes := Drawer.GetCharAttributes(Image^.ForeColor, Image^.BackColor);
  ch.Character := 32;
  GetMem(Image^.Data, width * height * 2);
  Image^.ForeColor := White;
  Image^.BackColor := Black;
  Image^.Width := width;
  Image^.Height := height;
  tempScreen := Drawer.CurrentScreen;
  Drawer.SetCurrentScreen(Image^.Data);
  rect.Create(0, 0, Width, Height);
  Drawer.FillRect(rect, ch);
  Drawer.SetCurrentScreen(tempScreen);
  ResetImageControls;
end;

procedure TDrawApp.Run;
var
  key: word;
  handled : boolean;
  mouseHandled: boolean;
  oldMouseState: TMouseState;
  mouseState: TMouseState;
begin
  TextBackground(Black);
  ClrScr;
  Refresh;
  GetMouseState(oldMouseState);
  repeat
    handled := false;
    mouseHandled := false;
    GetMouseState(mouseState);
    Desktop^.ProcessMouse(mouseState, oldMousestate, mouseHandled);
    if (KeyDriver.KeyPressed) then
    begin
      key := KeyDriver.GetKey;
      Desktop^.ProcessKeyPress(key, handled);
    end;
  until Closed;
end;


destructor TDrawApp.Done;
begin
  Drawer.Done;
  KeyDriver.Done;
  Dispose(Desktop, Done);
  TApplication.Done;
end;

end.