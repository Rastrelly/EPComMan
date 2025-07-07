unit uTools;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, uFormMain;

type

  { TFormTools }

  TFormTools = class(TForm)
    btnDiscUp: TButton;
    btnRestDn: TButton;
    btnRemRest: TButton;
    btnAddRest: TButton;
    btnUpdateRest: TButton;
    btnUpdComp: TButton;
    btnUpdateDisc: TButton;
    btnDiscDn: TButton;
    btnRemoveDisc: TButton;
    btnAddDisc: TButton;
    btnCompUp: TButton;
    btnCompDn: TButton;
    btnRemComp: TButton;
    btnAddComp: TButton;
    btnRestUp: TButton;
    cbIgnoreInMatrix: TCheckBox;
    cbFreeChoice: TCheckBox;
    edDiscCredits: TEdit;
    edDiscSemester: TEdit;
    edDiscName: TEdit;
    edCompName: TEdit;
    edRestName: TEdit;
    edDiscEpIDName: TEdit;
    edDiscLabWork: TEdit;
    edDiscLectures: TEdit;
    edDiscPractice: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    shpDiscColour: TShape;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure btnAddCompClick(Sender: TObject);
    procedure btnAddDiscClick(Sender: TObject);
    procedure btnCompDnClick(Sender: TObject);
    procedure btnCompUpClick(Sender: TObject);
    procedure btnDiscDnClick(Sender: TObject);
    procedure btnDiscUpClick(Sender: TObject);
    procedure btnRemCompClick(Sender: TObject);
    procedure btnRemoveDiscClick(Sender: TObject);
    procedure btnUpdateDiscClick(Sender: TObject);
    procedure btnUpdateRestClick(Sender: TObject);
    procedure btnRestDnClick(Sender: TObject);
    procedure btnRemRestClick(Sender: TObject);
    procedure btnAddRestClick(Sender: TObject);
    procedure btnRestUpClick(Sender: TObject);
    procedure btnUpdCompClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure shpDiscColourClick(Sender: TObject);
  private

  public

  end;

var
  FormTools: TFormTools;

implementation

{$R *.lfm}

{ TFormTools }

procedure TFormTools.PageControl1Change(Sender: TObject);
begin

end;

procedure TFormTools.shpDiscColourClick(Sender: TObject);
begin
  if (selectedDiscId<>-1) then
  begin
    FormMain.CDDiscColour.Color:=discs[selectedDiscId].colour;
    if FormMain.CDDiscColour.Execute then
    begin
      shpDiscColour.Brush.Color:=FormMain.CDDiscColour.Color;
    end;
    FormMain.updateDataManipData;
  end;
end;

procedure TFormTools.FormShow(Sender: TObject);
begin
  FormMain.updateDataManipData;
end;

procedure TFormTools.btnRestUpClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedRestId-1;
  if selStore<0 then selStore:=0;
  FormMain.MoveRest(-1,selectedRestId);
  FormMain.constructUI;
  selectedRestId:=selStore;
  FormMain.LBResults.ItemIndex:=selectedRestId;

end;

procedure TFormTools.btnUpdCompClick(Sender: TObject);
begin
  FormMain.UpdateComp(selectedCompId,edCompName.Text);
  FormMain.constructUI;
  FormMain.LBCompets.ItemIndex:=selectedCompId;
end;

procedure TFormTools.btnRestDnClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedRestId+1;
  if (selStore>=nResult) then selStore:=nResult-1;
  FormMain.MoveRest(1,selectedRestId);
  FormMain.constructUI;
  selectedRestId:=selStore;
  FormMain.LBResults.ItemIndex:=selectedRestId;
end;

procedure TFormTools.btnUpdateRestClick(Sender: TObject);
begin
  FormMain.UpdateRest(selectedRestId,edRestName.Text);
  FormMain.constructUI;
  FormMain.LBResults.ItemIndex:=selectedRestId;
end;

procedure TFormTools.btnRemRestClick(Sender: TObject);
begin
  FormMain.RemoveRest(selectedRestId);
  FormMain.constructUI;
  if (selectedRestId>=nResult) then selectedRestId:=nResult-1;
  FormMain.LBResults.ItemIndex:=selectedRestId;
end;

procedure TFormTools.btnAddRestClick(Sender: TObject);
begin
  FormMain.UpdateRest(nResult+1,edRestName.Text);
  FormMain.constructUI;
  FormMain.LBResults.ItemIndex:=FormMain.LBResults.Items.Count-1;
  selectedRestId:=FormMain.LBResults.ItemIndex;
end;

procedure TFormTools.btnDiscUpClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedDiscId;
  FormMain.moveDiscipline(-1,selectedDiscId);
  FormMain.constructUI;
  selectedDiscId:=selStore-1;
  FormMain.LBDisciplines.ItemIndex:=selectedDiscId;
end;

procedure TFormTools.btnRemoveDiscClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedDiscId;
  FormMain.removeDiscipline(selectedDiscId);
  FormMain.constructUI;
  if (selStore>=FormMain.LBDisciplines.Count) then selStore:=FormMain.LBDisciplines.Count-1;
  selectedDiscId:=selStore;
  FormMain.LBDisciplines.ItemIndex:=selStore;
end;

procedure TFormTools.btnUpdateDiscClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedDiscId;
  FormMain.updateDiscipline(selectedDiscId,
    edDiscName.Text,edDiscEpIDName.Text,StrToInt(edDiscSemester.Text),
    StrToInt(edDiscCredits.Text),StrToInt(edDiscLectures.Text),
    StrToInt(edDiscLabWork.Text),StrToInt(edDiscPractice.Text),shpDiscColour.Brush.Color,cbFreeChoice.Checked,
    cbIgnoreInMatrix.Checked);
  FormMain.constructUI;
  selectedDiscId:=selStore;
  FormMain.LBDisciplines.ItemIndex:=selectedDiscId;
end;

procedure TFormTools.btnDiscDnClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedDiscId;
  FormMain.moveDiscipline(1,selectedDiscId);
  FormMain.constructUI;
  selectedDiscId:=selStore+1;
  FormMain.LBDisciplines.ItemIndex:=selectedDiscId;
end;

procedure TFormTools.btnAddDiscClick(Sender: TObject);
begin
  FormMain.updateDiscipline(nDisc+1,
    edDiscName.Text,edDiscEpIDName.Text,StrToInt(edDiscSemester.Text),
    StrToInt(edDiscCredits.Text),StrToInt(edDiscLectures.Text),
    StrToInt(edDiscLabWork.Text),StrToInt(edDiscPractice.Text),shpDiscColour.Brush.Color,cbFreeChoice.Checked,
    cbIgnoreInMatrix.Checked);
  FormMain.constructUI;
  selectedDiscId:=FormMain.LBDisciplines.Items.Count-1;
  FormMain.LBDisciplines.ItemIndex:=selectedDiscId;
end;

procedure TFormTools.btnRemCompClick(Sender: TObject);
begin
  FormMain.RemoveComp(selectedCompId);
  FormMain.constructUI;
  if (selectedCompId>=nComp) then selectedCompId:=nComp-1;
  FormMain.LBCompets.ItemIndex:=selectedCompId;
end;

procedure TFormTools.btnAddCompClick(Sender: TObject);
begin
  FormMain.UpdateComp(nComp+1,edCompName.Text);
  FormMain.constructUI;
  FormMain.LBCompets.ItemIndex:=FormMain.LBCompets.Items.Count-1;
  selectedCompId:=FormMain.LBCompets.ItemIndex;
end;

procedure TFormTools.btnCompDnClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedCompId+1;
  if (selStore>=nComp) then selStore:=nComp-1;
  FormMain.MoveComp(1,selectedCompId);
  FormMain.constructUI;
  selectedCompId:=selStore;
  FormMain.LBCompets.ItemIndex:=selectedCompId;
end;

procedure TFormTools.btnCompUpClick(Sender: TObject);
var selStore:integer;
begin
  selStore:=selectedCompId-1;
  if (selStore<0) then selStore:=0;
  FormMain.MoveComp(-1,selectedCompId);
  FormMain.constructUI;
  selectedCompId:=selStore;
  FormMain.LBCompets.ItemIndex:=selectedCompId;
end;

end.

