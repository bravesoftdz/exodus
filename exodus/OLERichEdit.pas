{+++++++++++++++ TCRYPTEDIT +++++++++++++++++++++++++++++++

I've found a lot of usefull Delphi-Freeware in the Internet.
So I want to return some code to the Internet...

TCryptedit is a OLERichedit that encrypts data on SaveToFile
and decrypts data on Loadfromfile - depends of the fileextension.

AUTOR: Joe Blocher <joe.b@magnet.at>
DATE: Jan. 98
WARRANTY: No warranty, promise, or guarantee -> try yourself
STATUS: Freeware for Delphi 3



1) First you have to register the Fileextensions and the encryption-keys,
   for example in the OnCreate-Event:

   procedure TForm1.FormCreate(Sender: TObject);
   begin
    Cryptedit1.RegisterExt('xyz',12345,6789,2468);
    Cryptedit1.RegisterExt('abc',23456,3456,7890);
    ...
   end;

   Use these registered extensions in the Opendialog-Filter.
   Not registered extensions like (*.txt, *.rtf ...) or registered with 0
   (like: RegisterExt('rtf',0,0,0)) will not be supported by encryption.

2) Don't forget to use the method Cryptedit1.SaveToFile instead of
   Cryptedit1.lines.SaveToFile (same for Loadfromfile),
   when you store and load data!!


I know, that the XOR-Encryption I used (Code from Borland-Homepage) is not
very secure, but it's fast. You have to change then ConvertWriteStream and
ConvertReadStream - methods from TCryptConvert when you want to use
another algorithm.


***************** TOLERICHEDIT *****************************************
I found TOLERICHEDIT in Newsgroups and I was really happy!!!!!!!!
Here the text:

Subject:      TRichEdit and Graphics -- SOLVED!!
From:         "Greg Chapman" <glc@well.com>
Date:         1997/10/29
Message-ID:   <638r29$n0b9@forums.borland.com>
Newsgroups:   borland.public.delphi.vcl.components.using


Using Delphi 3 and the RichEdit control which comes with the IE 4 release,
it appears that all you absolutely have to do to display graphics and other
embedded or linked objects in a RichEdit control is implement one method of
IRichEditOLECallback: specifically GetNewStorage.  I've attached a TRichEdit
descendent which does this (in the file OLERichEdit.pas) as well as a
translation of the richole.h file (from BC5) which defines the RichEdit OLE
interfaces.

The OLERichEdit file also includes one obvious enhancement to the default
behavior.  If you enable the VerbMenu define, then when you select a (linked
or embedded) object and right click on it, the control will pop up a menu of
available verbs for the object.  The code used is essentially the same as
that in the VCL's TOleContainer.

The implementation of the control included here allows you to edit objects
by double clicking on them; it opens whatever application is registered to
edit the object type (e.g., double click on a bitmap and Paint opens up).
The RichEdit control will also support in-place activation, provided you
implement the right methods of IRichEditOleCallback (I did not try this in
the unit included here).  It appears to me that alot of the stuff in
OLECTNRS.PAS could be used to enable this behavior.

Finally, a warning.  This control has not been extensively tested by any
means, and there may well be bugs or gotchas that I have not anticipated.
Use with caution.  It is intended primarily as a starting point for people
interested in extending TRichEdit.

Version 0.01: I added code to explicitly close OLE objects when they are deleted or
when the rich edit control is closed or cleared.  It is not clear to me whether
this is necessary: Microsoft's C-based REITP sample (which demonstrates the RichEdit
COM interfaces) never calls IOleObject.Close, which implies that the RichEdit
control handles closing the objects itself.  On the other hand, MFC 4.1 wraps each
IOleObject in a C++ class called CRichEditCntrItem.  This class descends from
COleClientItem, which always calls IOleObject.Close before releasing its IOleObject
reference.  The upshot is that MFC will call IOleObject.Close for each object in
the RichEdit control when it is done with the object.  So now TOleEdit does the
same thing.

Note that if the control is enhanced to support in-place activation, a call to
IRichEdit.InPlaceDeactivate should be made before closing the objects.
}


unit OLERichEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, StdCtrls, ComCtrls, ComObj, RichEdit, RichOLE, Menus, OleCtnrs;


{$DEFINE VerbMenu}

type

(*
  TCryptKeys = class
   Key,C1,C2:Word;
   constructor create(AKey,AC1,AC2:Word);
  end;
*)

  TOLEEdit = class(TRichEdit)
  private
    { Private declarations }

    FPopupVerbMenu: TPopupMenu;
    FAutoVerbMenu: boolean;
    FObjectVerbs: TStringList;
    FSelObject: IOleObject;
    procedure DestroyVerbs;
    procedure UpdateVerbs;
    procedure PopupVerbMenuClick(Sender: TObject);
    procedure DoVerb(Verb: Integer);
    procedure WMDestroy(var Msg: TMessage); message WM_DESTROY;  {!!0.01 -- changed from WM_NCDESTROY}
  protected
    { Protected declarations }
    procedure CloseOLEObjects;                      {!!0.01 -- added method}
    procedure CreateWnd; override;
    function GetPopupMenu: TPopupMenu; override;
  public
    { Public declarations }

    FRichEditOle: IRichEditOLE;
    FRichEditOleCallback: IRichEditOleCallback;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Objectselected:Boolean;
    procedure Clear; override;                          {!!0.01 -- overriden to close objects}
  published
    property AutoVerbMenu: boolean read FAutoVerbMenu write FAutoVerbMenu default true;
  end;


(*
  TCryptEdit=class(TOLEEdit)
   private
    keylist:TStringlist;
    procedure preparekeys(AFilename:TFilename);
    procedure resetkeys;
   public
    constructor create(AOwner:TComponent); override;
    destructor destroy; override;
    procedure SaveToFile(FName:TFilename);
    procedure LoadFromFile(FName:TFilename);
    procedure RegisterExt(AExt:String;AKey,AC1,AC2:Word); virtual;
  end;
*)


 procedure Register;

implementation
(*
var CurKey,CurC1,CurC2:Word;
*)


type

(*
  TCryptConvert = class(TConversion)
   function ConvertWriteStream(Stream: TStream; Buffer: PChar;
                               BufSize: Integer): Integer; override;
   function ConvertReadStream(Stream: TStream; Buffer: PChar;
                              BufSize: Integer): Integer; override;
  end;
*)


  TRichEditOleCallback = class(TInterfacedObject, IRichEditOleCallback)
  private
    FOwner: TOLEEdit;
  protected
    function GetNewStorage(out stg: IStorage): HRESULT; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame;
         out Doc: IOleInPlaceUIWindow; var FrameInfo: TOleInPlaceFrameInfo): HRESULT; stdcall;
    function ShowContainerUI(fShow: BOOL): HRESULT; stdcall;
    function QueryInsertObject(const clsid: TCLSID; stg: IStorage; cp: longint): HRESULT; stdcall;
    function DeleteObject(oleobj: IOLEObject): HRESULT; stdcall;
    function QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
         out dataobj: IDataObject): HRESULT; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT; stdcall;
    function GetContextMenu(seltype: Word; oleobj: IOleObject;
         const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
  public
    constructor Create(AOwner: TOLEEdit);
  end;

constructor TRichEditOleCallback.Create(AOwner: TOLEEdit);
begin
  inherited Create;
  FOwner:= AOwner;
end;

function TRichEditOleCallback.GetNewStorage(out stg: IStorage): HRESULT;
var LockBytes: ILockBytes;
begin
  Result:= S_OK;
  try
    OleCheck(CreateILockBytesOnHGlobal(0, True, LockBytes));
    OleCheck(StgCreateDocfileOnILockBytes(LockBytes, STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, stg));
  except
    Result:= E_OUTOFMEMORY;
  end;
end;

function TRichEditOleCallback.GetInPlaceContext(out Frame: IOleInPlaceFrame;
       out Doc: IOleInPlaceUIWindow; var FrameInfo: TOleInPlaceFrameInfo): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.ShowContainerUI(fShow: BOOL): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.QueryInsertObject(const clsid: TCLSID; stg: IStorage;
       cp: longint): HRESULT;
begin
  Result:= S_OK;
end;

function TRichEditOleCallback.DeleteObject(oleobj: IOLEObject): HRESULT;
begin
  FOwner.FSelObject:= nil;                        {!!0.01}
  oleobj.Close(OLECLOSE_NOSAVE);                  {!!0.01}
  Result:= S_OK;
end;

function TRichEditOleCallback.QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT;
begin
  Result:= S_OK;
end;

function TRichEditOleCallback.ContextSensitiveHelp(fEnterMode: BOOL): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.GetClipboardData(const chrg: TCharRange; reco: DWORD;
         out dataobj: IDataObject): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT;
const MK_ALT = $20;
var Effect: DWORD;
begin
  Result:= S_OK;
	if not fDrag then begin // allowable dest effects
		// check for force link
		if ((grfKeyState and (MK_CONTROL or MK_SHIFT)) = (MK_CONTROL or MK_SHIFT)) then
			Effect := DROPEFFECT_LINK
		// check for force copy
		else if ((grfKeyState and MK_CONTROL) = MK_CONTROL) then
			Effect := DROPEFFECT_COPY
		// check for force move
		else if ((grfKeyState and MK_ALT) = MK_ALT) then
			Effect := DROPEFFECT_MOVE
		// default -- recommended action is move
		else
			Effect := DROPEFFECT_MOVE;
		if (Effect and dwEffect <> 0) then // make sure allowed type
			dwEffect := Effect;
  end;
end;

function TRichEditOleCallback.GetContextMenu(seltype: Word; oleobj: IOleObject;
         const chrg: TCharRange; var menu: HMENU): HRESULT;
begin
  Result:= S_OK;
  menu:= 0;
end;



constructor TOLEEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoVerbMenu:= true;
  FRichEditOleCallback:= TRichEditOleCallback.Create(Self);
end;

destructor TOLEEdit.Destroy;
begin
  DestroyVerbs;
  inherited Destroy;
end;


{$WARNINGS OFF}
function TOLEEdit.ObjectSelected:Boolean;
var ReObject:TReObject;
begin
  ReObject.cbStruct:= sizeof(TReObject);
  result:=(FRichEditOle.GetObject(REO_IOB_SELECTION, ReObject, REO_GETOBJ_POLEOBJ) = S_OK) and
          Assigned(ReObject.oleobj);
end;
{$WARNINGS ON}

procedure TOLEEdit.CreateWnd;
begin
  inherited CreateWnd;
  if not RichEdit_GetOleInterface(Handle, FRichEditOle) then
    raise Exception.Create('Unable to get interface');
  if not RichEdit_SetOleCallback(Handle, FRichEditOlecallback) then
    raise Exception.Create('Unable to set callback');
end;

procedure TOleEdit.CloseOLEObjects;                      {!!0.01 -- added method}
var i: integer;
    REObject: TREObject;
begin
  if not Assigned(FRichEditOle) then Exit;
  fillchar(REObject, sizeof(REObject), 0);
  REObject.cbStruct:= sizeof(REObject);
  for i:= 0 to Pred(FRichEditOle.GetObjectCount) do begin
    if FRichEditOle.GetObject(i, REObject, REO_GETOBJ_POLEOBJ) = S_OK then
      REObject.oleobj.Close(OLECLOSE_NOSAVE);
  end;
end;

procedure TOLEEdit.WMDestroy(var Msg: TMessage); {!!0.01 -- changed from WM_NCDESTROY}
begin
  CloseOLEObjects;                                {!!0.01}
  FRichEditOle:= nil;
  inherited;
end;

procedure TOLEEdit.Clear;                           {!!0.01 -- overriden to close objects}
begin
  CloseOLEObjects;
  inherited Clear;
end;

{$WARNINGS OFF}
function TOLEEdit.GetPopupMenu: TPopupMenu;
var
  I: Integer;
  Item: TMenuItem;
  ReObject: TReObject;
begin
  Result := inherited GetPopupMenu;
  if FAutoVerbMenu and Assigned(FRichEditOle) then begin
    ReObject.cbStruct:= sizeof(TReObject);
    {if an object is selected, get its IOLEObject interface}
    if (FRichEditOle.GetObject(REO_IOB_SELECTION, ReObject, REO_GETOBJ_POLEOBJ) <> S_OK) or
          not Assigned(ReObject.oleobj) then begin
      {no object selected -- clean up any previous object info}
      FSelObject:= nil;
      DestroyVerbs;
    end
    else
      if FSelObject = ReObject.oleobj then
        {same object selected -- use already allocated menu}
        Result:= FPopupVerbMenu
      else begin
        {new object selected -- create a menu for it}
        FSelObject:= ReObject.oleobj;
        UpdateVerbs;
        if FObjectVerbs.Count = 0 then
          Result:= nil
        else begin
          FPopupVerbMenu:= TPopupMenu.Create(Self);
          for I := 0 to FObjectVerbs.Count - 1 do begin
            Item := TMenuItem.Create(Self);
            Item.Caption := FObjectVerbs[I];
            Item.Tag := I;
            if TVerbInfo(FObjectVerbs.Objects[i]).Verb = 0 then
              Item.Default:= true;              // Verb = 0 is the primary verb
            Item.OnClick := PopupVerbMenuClick;
            FPopupVerbMenu.Items.Add(Item);
          end;
          Result := FPopupVerbMenu;
        end;
      end;
  end;
end;
{$WARNINGS ON}


{The following four methods lifted more or less intact from TOleContainer}
procedure TOLEEdit.DestroyVerbs;
begin
  FPopupVerbMenu.Free;
  FPopupVerbMenu := nil;
  FObjectVerbs.Free;
  FObjectVerbs := nil;
end;

procedure TOLEEdit.UpdateVerbs;
var
  EnumOleVerb: IEnumOleVerb;
  OleVerb: TOleVerb;
  VerbInfo: TVerbInfo;
begin
  DestroyVerbs;
  FObjectVerbs := TStringList.Create;
  if FSelObject.EnumVerbs(EnumOleVerb) = 0 then
  begin
    while (EnumOleVerb.Next(1, OleVerb, nil) = 0) and
      (OleVerb.lVerb >= 0) and
      (OleVerb.grfAttribs and OLEVERBATTRIB_ONCONTAINERMENU <> 0) do
    begin
      VerbInfo.Verb := OleVerb.lVerb;
      VerbInfo.Flags := OleVerb.fuFlags;
      FObjectVerbs.AddObject(OleVerb.lpszVerbName, TObject(VerbInfo));
    end;
  end;
end;

procedure TOLEEdit.PopupVerbMenuClick(Sender: TObject);
begin
  DoVerb((Sender as TMenuItem).Tag);
end;

procedure TOLEEdit.DoVerb(Verb: Integer);
var
  H: THandle;
  R: TRect;
  ClientSite: IOleClientSite;
begin
  if not Assigned(FRichEditOle) or not Assigned(FSelObject) then Exit;
  if Verb > 0 then begin
    if FObjectVerbs = nil then UpdateVerbs;
    if Verb >= FObjectVerbs.Count then
      raise EOleError.Create('Invalid Verb');
    Verb := Smallint(Integer(FObjectVerbs.Objects[Verb]) and $0000FFFF);
  end else
    if Verb = ovPrimary then Verb := 0;
  R := ClientRect;
  H := Handle;
  OleCheck(FRichEditOle.GetClientSite(ClientSite));
  OleCheck(FSelObject.DoVerb(Verb, nil, ClientSite, 0, H, R));
end;




//TProtRec++++++++++++++++++++++++++++

(*
constructor TCryptKeys.create(AKey,AC1,AC2:Word);
begin
 inherited create;
 Key:=AKey;
 C1:=AC1;
 C2:=AC2;
end;


//TCryptEdit++++++++++++++++++++++

constructor TCryptEdit.create(AOwner:TComponent);
begin
 inherited create(AOwner);
 keylist:=TStringlist.create;
end;


destructor TCryptEdit.destroy;
var i:Integer;
begin
 For i:=0 to keylist.count-1 do TCryptKeys(keylist.objects[i]).free;
 keylist.free;
 inherited destroy;
end;

procedure TCryptEdit.RegisterExt(AExt:String;AKey,AC1,AC2:Word);
begin
 keylist.addobject(AExt,TCryptKeys.create(Akey,AC1,AC2));
 RegisterConversionFormat(AExt,TCryptConvert);
end;

procedure TCryptEdit.resetkeys;
begin
 Curkey:=0;
 Curc1:=0;
 Curc2:=0;
end;

procedure TCryptEdit.preparekeys(AFilename:TFilename);
var ce:String; idx:Integer; tmp:TCryptKeys;
begin
 ce:=ExtractFileext(AFileName);
 system.delete(ce,1,1);
 idx:=keylist.indexof(ce);
 if idx>=0 then
 begin
  tmp:=TCryptKeys(keylist.objects[idx]);
  Curkey:=tmp.key;
  Curc1:=tmp.c1;
  Curc2:=tmp.c2;
 end
 else resetkeys;
end;



procedure TCryptEdit.SaveToFile(FName:TFilename);
begin
  preparekeys(FName);
  screen.cursor:=crhourglass;
 try
  try
  Lines.SavetoFile(FName);
  except
    screen.cursor:=crdefault;
    raise;
  end;
 finally
  screen.cursor:=crdefault;
  resetkeys;
 end;
end;

procedure TCryptEdit.LoadFromFile(FName:TFilename);
begin
 preparekeys(FName);
 screen.cursor:=crhourglass;
  try
  try
 Lines.LoadFromFile(FName);
 except
   screen.cursor:=crdefault;
   raise;
  end;
 finally
  screen.cursor:=crdefault;
  resetkeys;
 end;
end;

//TCryptConvert+++++++++++++++++++++++++++++++++++++++++++++++

procedure KeepWindowsAlive;       //Usefull when loading/saveing large files
var M: TMsg;
  begin
    If PeekMessage(M,0,0,0,pm_Remove) then
    begin
      TranslateMessage(M);
      DispatchMessage(M);
    end;
end;


function TCryptConvert.ConvertWriteStream(Stream: TStream; Buffer: PChar; BufSize: Integer): Integer;
var i:Integer;
begin
  // Keepwindowsalive;    For large files!!!
  if (Curkey<>0) and (CurC1<>0) and (CurC2<>0) then
  For i:=0 to Bufsize-1 do
  begin
    Buffer[I] := Char(Integer(Buffer[I]) xor (CurKey shr 8));
    CurKey := (Integer(Buffer[I]) + CurKey) * Curc1 + Curc2;
  end;
  result:=Stream.write(Buffer^,Bufsize);
end;


function TCryptConvert.ConvertReadStream(Stream: TStream; Buffer: PChar; BufSize: Integer): Integer;
var i,c:Integer;
begin
  // Keepwindowsalive;   For large files!!!
  result:=Stream.Read(Buffer^,Bufsize);
  if (Curkey=0) and (CurC1=0) and (CurC2=0) then exit;
  For i:=0 to Bufsize-1 do
  begin
    c:=Integer(Buffer[I]);
    Buffer[I] := Char(c xor (CurKey shr 8));
    CurKey := (c + CurKey) * Curc1 + Curc2;
  end;
end;

*)


procedure Register;
begin
(*
  RegisterComponents('Win32', [TCryptEdit,TOLEEdit]);
*)

    RegisterComponents('Win32', [TOLEEdit]);
end;



end.
