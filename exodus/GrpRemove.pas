unit GrpRemove;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, buttonFrame, StdCtrls;

type
  TfrmGrpRemove = class(TForm)
    frameButtons1: TframeButtons;
    optMove: TRadioButton;
    cboNewGroup: TComboBox;
    optNuke: TRadioButton;
    chkUnsub: TCheckBox;
    chkUnsubed: TCheckBox;
    procedure frameButtons1btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frameButtons1btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    cur_grp: string;
    ct_list: TList;
  end;

var
  frmGrpRemove: TfrmGrpRemove;

procedure RemoveGroup(grp: string; contacts: TList = nil);

implementation

{$R *.dfm}
uses
    Roster, XMLTag, IQ, Session, S10n;

procedure RemoveGroup(grp: string; contacts: TList = nil);
var
    f: TfrmGrpRemove;
begin
    // Either remove a grp, or a bunch of contacts

    f := TfrmGrpRemove.Create(nil);

    with f do begin
        if (contacts <> nil) then begin
            Caption := 'Remove ' + IntToStr(contacts.Count) + ' contacts';
            optMove.Enabled := false;
            cboNewGroup.Enabled := false;
            optNuke.Checked := true;
            ct_list.Assign(contacts);
            end
        else begin
            Caption := 'Remove the ' + grp + ' group';
            cboNewGroup.Items.Assign(MainSession.Roster.GrpList);
            cboNewGroup.Items.Delete(cboNewGroup.Items.IndexOf(grp));
            cboNewGroup.ItemIndex := 0;
            end;
        cur_grp := grp;
        Show();
        end;
end;

procedure TfrmGrpRemove.frameButtons1btnOKClick(Sender: TObject);
var
    iq: TXMLTag;
    gi, i, act: integer;
    cur_jid: string;
    ri: TJabberRosterItem;
begin
    if ((cur_grp <> '') and (ct_list.Count = 0)) then
        ct_list := MainSession.roster.GetGroupItems(cur_grp, false);

    if (optNuke.Checked) then begin
        // Remove the people from my roster

        act := 0;
        if (chkUnSub.Checked) and (chkUnsubed.Checked) then
            act := 1
        else if (chkUnSub.Checked) then
            act := 2
        else if (chkUnsubed.Checked) then
            act := 3;

        for i := 0 to ct_list.Count - 1 do begin
            cur_jid := TJabberRosterItem(ct_list[i]).jid.jid;
            case act of
            1: begin
                // send a subscription='remove'
                iq := TXMLTag.Create('iq');
                with iq do begin
                    PutAttribute('type', 'set');
                    PutAttribute('id', MainSession.generateID);
                    with AddTag('query') do begin
                        PutAttribute('xmlns', XMLNS_ROSTER);
                        with AddTag('item') do begin
                            PutAttribute('jid', cur_jid);
                            PutAttribute('subscription', 'remove');
                            end;
                        end;
                    end;
                MainSession.SendTag(iq);
                end;
            2: SendUnsubscribe(cur_jid, MainSession);
            3: SendUnsubscribed(cur_jid, MainSession);
            end;
            end;
        end
    else begin
        // Move all contacts in this group to the new group
        for i := 0 to ct_list.Count - 1 do begin
            ri := TJabberRosterItem(ct_list[i]);
            gi := ri.Groups.IndexOf(cur_grp);
            if (gi >= 0) then ri.Groups.Delete(gi);
            ri.Groups.Add(cboNewGroup.Text);
            ri.update();
            end;
        end;
    Self.Close;
end;

procedure TfrmGrpRemove.FormCreate(Sender: TObject);
begin
    //
    cur_grp := '';
    ct_list := TList.Create;
end;

procedure TfrmGrpRemove.frameButtons1btnCancelClick(Sender: TObject);
begin
    Self.Close;
end;

procedure TfrmGrpRemove.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

end.
