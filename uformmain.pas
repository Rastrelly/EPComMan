unit uFormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, CheckLst, StdCtrls,
  ExtCtrls, Buttons, Menus;

type

  { TFormMain }

  TDiscipline = class
  public
    name,epedname:string;
    semester,credits,lec,pract,lab:integer;
    colour:TColor;
    competIds:array [0..1000] of boolean;
    resultIds:array [0..1000] of boolean;
    constructor Create;
  end;

  PDiscipline = ^TDiscipline;

  TFormMain = class(TForm)
    btnShowTools: TSpeedButton;
    btnOpenComps: TSpeedButton;
    btnOpenMatrix: TSpeedButton;
    btnOpenResults: TSpeedButton;
    btnSaveMatrix: TSpeedButton;
    btnExportMatrix: TSpeedButton;
    CDDiscColour: TColorDialog;
    LBCompets: TCheckListBox;
    LBResults: TCheckListBox;
    gbDisc: TGroupBox;
    gbComp: TGroupBox;
    gbRes: TGroupBox;
    ImgList: TImageList;
    LBDisciplines: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    ODMatrix: TOpenDialog;
    ODResults: TOpenDialog;
    ODDisciplines: TOpenDialog;
    ODComps: TOpenDialog;
    Panel1: TPanel;
    btnOpenDisciplines: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    RBExtDisc: TRadioButton;
    RBExtComp: TRadioButton;
    RBExtRes: TRadioButton;
    RBExtNone: TRadioButton;
    SDMatrix: TSaveDialog;
    SDMatrixExport: TSaveDialog;
    procedure btnExportMatrixClick(Sender: TObject);
    procedure LBCompetsClick(Sender: TObject);
    procedure LBResultsClick(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure updateDataManipData;
    procedure MoveComp(dir:integer; id:integer);
    procedure MoveRest(dir:integer; id:integer);
    procedure RemoveComp(id:integer);
    procedure RemoveRest(id:integer);
    procedure UpdateComp(id:integer; vName:string);
    procedure UpdateRest(id:integer; vName:string);
    procedure removeDiscipline(id:integer);
    procedure moveDiscipline(dir:integer; id:integer);
    procedure updateDiscipline(id:integer; vName:string; vEdName:string; vSem:integer; vCred:integer; vLec:integer; vLab:integer; vPract:integer; clr:TColor);
    procedure btnOpenMatrixClick(Sender: TObject);
    procedure btnSaveMatrixClick(Sender: TObject);
    procedure btnShowToolsClick(Sender: TObject);
    procedure btnOpenCompsClick(Sender: TObject);
    procedure btnOpenDisciplinesClick(Sender: TObject);
    procedure btnOpenResultsClick(Sender: TObject);
    procedure constructUI;
    procedure ClearDisciplines;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LBCompetsClickCheck(Sender: TObject);
    procedure LBDisciplinesClick(Sender: TObject);
    procedure LBResultsClickCheck(Sender: TObject);
    procedure loadDisciplines(fileName:string);
    procedure loadCompetences(fileName:string);
    procedure loadResults(fileName:string);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure RBExtCompChange(Sender: TObject);
    procedure RBExtCompClick(Sender: TObject);
    procedure RBExtDiscChange(Sender: TObject);
    procedure RBExtDiscClick(Sender: TObject);
    procedure RBExtNoneChange(Sender: TObject);
    procedure RBExtNoneClick(Sender: TObject);
    procedure RBExtResChange(Sender: TObject);
    procedure RBExtResClick(Sender: TObject);
    procedure refreshDisciplineChecks(discId:integer);
    procedure updateDisciplineChecks(discId:integer);
    procedure ResizeProc;
    procedure SaveMatrix(fileName:string);
    procedure LoadMatrix(fileName:string);
  private

  public

  end;

var
  FormMain: TFormMain;
  comps,rests:array of string;
  discs:array of TDiscipline;
  selectedDiscId:integer=-1;
  selectedCompId:integer=-1;
  selectedRestId:integer=-1;
  discsPath,compPath,resPath:string;

  nDisc,nComp,nResult:integer;

implementation

{$R *.lfm}

uses uTools, uMatrixExport, uAbout;

{ TDiscipline }
constructor TDiscipline.Create;
begin
  name:='TDisciplineName';
  epedname:='ЗП';
  semester:=1;
  credits:=4;
  lab:=0;
  lec:=32;
  pract:=16;
  colour:=clSkyBlue;
end;

{ TFormMain }

procedure CloneDiscipline(var dFrom:TDiscipline; var dTo:TDiscipline);
var i:integer;
begin
  dTo.name:=dFrom.name;
  dTo.epedname:=dFrom.epedname;
  dTo.semester:=dFrom.semester;
  dTo.credits:=dFrom.credits;
  dTo.lec:=dFrom.lec;
  dTo.lab:=dFrom.lab;
  dTo.pract:=dFrom.pract;
  dTo.colour:=dFrom.colour;
  for i:=0 to 1000 do
  begin
    dTo.competIds[i]:=dFrom.competIds[i];
    dTo.resultIds[i]:=dFrom.resultIds[i];
  end;
end;

procedure  SwapDisciplines(var disc1:TDiscipline; var disc2:TDiscipline);
var tmpDisc:TDiscipline;
begin
  tmpDisc:=TDiscipline.Create;
  CloneDiscipline(disc2,tmpDisc);
  CloneDiscipline(disc1,disc2);
  CloneDiscipline(tmpDisc,disc1);
  FreeAndNil(tmpDisc);
end;

//give data to toolbar
procedure TFormMain.updateDataManipData;
begin
  //update only if tolbar is visible
  if FormTools.Visible then
  begin
    if (selectedDiscId<>-1) then
    begin
      with discs[selectedDiscId] do
      begin
        FormTools.edDiscName.Text:=name;
        FormTools.edDiscEpIDName.Text:=epedname;
        FormTools.edDiscCredits.Text:=inttostr(credits);
        FormTools.edDiscSemester.Text:=inttostr(semester);
        FormTools.edDiscLectures.Text:=inttostr(lec);
        FormTools.edDiscLabWork.Text:=inttostr(lab);
        FormTools.edDiscPractice.Text:=inttostr(pract);
        FormTools.shpDiscColour.Brush.Color:=colour;
      end;
    end;
    if (selectedCompId<>-1) then
    begin
      FormTools.edCompName.Text:=comps[selectedCompId];
    end;
    if (selectedRestId<>-1) then
    begin
      FormTools.edRestName.Text:=rests[selectedRestId];
    end;
  end;
end;

//would be good to rewrite these two properly but for now keep two
//at once; too lazy to do abstraction ATM
procedure TFormMain.MoveComp(dir:integer; id:integer);
var buff:string;
    i,p1,p2:integer;
    ibuff:boolean;
begin
  if (id>=0) and (id<nComp) then
  if ((id+dir>=0) and (id+dir<nComp)) then
  begin
    //register ids
    p1:=id;
    p2:=id+dir;
    //do the swap
    buff:=comps[p2];
    comps[p2]:=comps[p1];
    comps[p1]:=buff;
    //ajust comps in disciplines accordingly
    if (nDisc>0) then
    for i:=0 to nDisc-1 do
    begin
      ibuff:=discs[i].competIds[p2];
      discs[i].competIds[p2]:=discs[i].competIds[p1];
      discs[i].competIds[p1]:=ibuff;
    end;
  end;
end;


procedure TFormMain.MoveRest(dir:integer; id:integer);
var buff:string;
    i,p1,p2:integer;
    ibuff:boolean;
begin
  if (id>=0) and (id<nResult) then
  if ((id+dir>=0) and (id+dir<nResult)) then
  begin
    //register ids
    p1:=id;
    p2:=id+dir;
    //do the swap
    buff:=rests[p2];
    rests[p2]:=rests[p1];
    rests[p1]:=buff;
    //ajust comps in disciplines accordingly
    if (nDisc>0) then
    for i:=0 to nDisc-1 do
    begin
      ibuff:=discs[i].resultIds[p2];
      discs[i].resultIds[p2]:=discs[i].resultIds[p1];
      discs[i].resultIds[p1]:=ibuff;
    end;
  end;
end;

//same for deleting items
procedure TFormMain.RemoveComp(id:integer);
var buff:string;
    i,j,p1:integer;
    ibuff:boolean;
begin
  if (id>=0) and (id<nComp) then
  begin
    //register ids
    p1:=id;
    //do the cleanup
    for i:=p1 to nComp-2 do
    comps[i]:=comps[i+1];
    SetLength(comps,Length(comps)-1);
    //ajust comps in disciplines accordingly
    if (nDisc>0) then
    for i:=0 to nDisc-1 do
    begin
      for j:=p1 to 999 do
      discs[i].competIds[j]:=discs[i].competIds[j+1];
    end;
  end;
end;

//same for deleting items
procedure TFormMain.RemoveRest(id:integer);
var buff:string;
    i,j,p1:integer;
    ibuff:boolean;
begin
  if (id>=0) and (id<nResult) then
  begin
    //register ids
    p1:=id;
    //do the cleanup
    try
        for i:=p1 to nResult-2 do
          rests[i]:=rests[i+1];
    except
      ShowMessage('Error at i='+inttostr(i)+' for some indexing reason');
    end;
    SetLength(rests,Length(rests)-1);
    //ajust comps in disciplines accordingly
    if (nDisc>0) then
    for i:=0 to nDisc-1 do
    begin
      for j:=p1 to 999 do
      discs[i].resultIds[j]:=discs[i].resultIds[j+1];
    end;
  end;
end;

//these to either update existing or add a new item to the list
procedure TFormMain.UpdateComp(id:integer; vName:string);
var cOp:integer;
begin
  if (id>=nComp) then
  begin
    SetLength(comps,length(comps)+1);
    nComp:=length(comps);
    cOp:=High(comps);
  end
  else
  begin
    if (id>=0) then cOp:=id
    else cOp:=-1;
  end;

  if (cOp<>-1) then
  begin
    comps[cOp]:=vName;
  end;
end;

procedure TFormMain.UpdateRest(id:integer; vName:string);
var cOp:integer;
begin
  if (id>=nResult) then
  begin
    SetLength(rests,length(rests)+1);
    nResult:=length(rests);
    cOp:=High(rests);
  end
  else
  begin
    if (id>=0) then cOp:=id
    else cOp:=-1;
  end;

  if (cOp<>-1) then
  begin
    rests[cOp]:=vName;
  end;
end;

//finally - a set of modified functions for discplines (as those are
//separate class)
procedure TFormMain.removeDiscipline(id:integer);
var i:integer;
begin
  if (id>=0) and (id<nDisc) then
  begin
    FreeAndNil(discs[id]);
    for i:=id to nDisc-2 do
    begin
      discs[i]:=discs[i+1];
    end;
    SetLength(discs,length(discs)-1);
    nDisc:=Length(discs);
  end;
end;


procedure TFormMain.moveDiscipline(dir:integer; id:integer);
var i:integer;
    tempDisc:TDiscipline;
begin
  if (id>=0) and (id<nDisc) then
  if (id + dir >= 0) and (id+dir<=nDisc) then
  begin
    SwapDisciplines(discs[id],discs[id+dir]);
  end;
end;

procedure TFormMain.updateDiscipline(id:integer; vName:string; vEdName:string; vSem:integer; vCred:integer; vLec:integer; vLab:integer; vPract:integer; clr:TColor);
var cOp:integer;
begin
  if (id>=nDisc) then
  begin
    SetLength(discs,length(discs)+1);
    nDisc:=length(discs);
    cOp:=High(discs);
  end
  else
  begin
    if (id>=0) then cOp:=id
    else cOp:=-1;
  end;

  if (cOp<>-1) then
  begin
    discs[cOp]:=TDiscipline.Create;
    with discs[cOp] do
    begin
      name:=vName;
      epedname:=vEdName;
      semester:=vSem;
      credits:=vCred;
      lec:=vLec;
      lab:=vLab;
      pract:=vPract;
      colour:=clr;
    end;
  end;

end;


//main class related stuff
procedure TFormMain.constructUI;
var i:integer;
begin
  LBDisciplines.Clear;
  LBCompets.Clear;
  LBResults.Clear;

  //build disciplines list
  nDisc := Length(discs);
  if (nDisc>0) then
  begin
    for i:=0 to nDisc-1 do
    begin
      LBDisciplines.Items.Add(discs[i].epedname +'. '+discs[i].name);
    end;
  end;

  //build compets list
  nComp := Length(comps);
  if (nComp>0) then
  begin
    for i:=0 to nComp-1 do
    begin
      LBCompets.Items.Add(comps[i]);
    end;
  end;

  //build results list
  nResult := Length(rests);
  if (nResult>0) then
  begin
    for i:=0 to nResult-1 do
    begin
      LBResults.Items.Add(rests[i]);
    end;
  end;

end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FormMain.ResizeProc;
end;

procedure TFormMain.ResizeProc;
var fw,pw:integer;
    coe1,coe2,coe3:real;
begin
  fw:=FormMain.ClientWidth;
  pw:=round(fw/3);

  if (RBExtNone.Checked) then
  begin
    coe1:=1;
    coe2:=1;
    coe3:=1;
  end;

  if (RBExtDisc.Checked) then
  begin
    coe1:=2;
    coe2:=0.5;
    coe3:=0.5;
  end;

  if (RBExtComp.Checked) then
  begin
    coe1:=0.5;
    coe2:=2;
    coe3:=0.5;
  end;

  if (RBExtRes.Checked) then
  begin
    coe1:=0.5;
    coe2:=0.5;
    coe3:=2;
  end;

  gbDisc.Width:=round(coe1*pw);
  gbComp.Width:=round(coe2*pw);
  gbRes.Width:=round(coe3*pw);
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  ResizeProc;
end;

procedure TFormMain.LBCompetsClickCheck(Sender: TObject);
begin
  updateDisciplineChecks(selectedDiscId);
end;

procedure TFormMain.LBDisciplinesClick(Sender: TObject);
begin
  selectedDiscId:=LBDisciplines.ItemIndex;
  refreshDisciplineChecks(selectedDiscId);
  updateDataManipData;
end;

procedure TFormMain.LBResultsClickCheck(Sender: TObject);
begin
  updateDisciplineChecks(selectedDiscId);
end;

procedure TFormMain.LBCompetsClick(Sender: TObject);
begin
  selectedCompId:=LBCompets.ItemIndex;
  updateDataManipData;
end;

procedure TFormMain.btnExportMatrixClick(Sender: TObject);
begin
  FormMatrixExport.Show;
end;

procedure TFormMain.LBResultsClick(Sender: TObject);
begin
  selectedRestId:=LBResults.ItemIndex;
  updateDataManipData;
end;

procedure TFormMain.MenuItem10Click(Sender: TObject);
begin
  btnOpenMatrix.Click;
end;

procedure TFormMain.MenuItem5Click(Sender: TObject);
begin
  btnSaveMatrix.Click;
end;

procedure TFormMain.MenuItem6Click(Sender: TObject);
begin
  btnExportMatrix.Click;
end;

procedure TFormMain.MenuItem7Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormMain.MenuItem9Click(Sender: TObject);
begin
  FormAbout.Show;
end;

procedure TFormMain.btnOpenCompsClick(Sender: TObject);
begin
  If (ODComps.Execute) then loadCompetences(ODComps.FileName);
  constructUI;
end;

procedure TFormMain.btnShowToolsClick(Sender: TObject);
begin
  FormTools.Show;
end;

procedure TFormMain.btnSaveMatrixClick(Sender: TObject);
begin
  if (SDMatrix.Execute) then SaveMatrix(SDMatrix.FileName);
  constructUI;
end;

procedure TFormMain.btnOpenMatrixClick(Sender: TObject);
begin
  if (ODMatrix.Execute) then LoadMatrix(ODMatrix.FileName);
  constructUI;
end;

procedure TFormMain.btnOpenDisciplinesClick(Sender: TObject);
begin
  selectedDiscId:=-1;
  If (ODDisciplines.Execute) then loadDisciplines(ODDisciplines.FileName);
  constructUI;
end;

procedure TFormMain.btnOpenResultsClick(Sender: TObject);
begin
  If (ODResults.Execute) then loadResults(ODResults.FileName);
  constructUI;
end;

procedure TFormMain.ClearDisciplines;
var i:integer;
begin
  if (nDisc>0) then
  begin
    for i:=0 to nDisc-1 do FreeAndNil(discs[i]);
  end;
end;

procedure TFormMain.loadDisciplines(fileName:string);
var cFile:TextFile;
    cLine:string;
    i:integer;
begin
  AssignFile(cFile, fileName);
  Reset(cFile);

  //force refresh nDisc
  nDisc:=length(discs);

  //clear disciplines properly
  ClearDisciplines;

  //load and init disciplines
  setlength(discs,0);
  while not Eof(cFile) do
  begin
    ReadLn(cFile, cLine);
    setlength(discs,length(discs)+1);
    discs[High(discs)]:=TDiscipline.Create;
    discs[High(discs)].name:=cLine;
  end;

  //shutdown
  CloseFile(cFile);
  discsPath:=fileName;
end;

procedure TFormMain.loadCompetences(fileName:string);
var cFile:TextFile;
    cLine:string;
begin
  AssignFile(cFile, fileName);
  Reset(cFile);
  setlength(comps,0);
  while not Eof(cFile) do
  begin
    ReadLn(cFile, cLine);
    setlength(comps,length(comps)+1);
    comps[High(comps)]:=cLine;
  end;
  CloseFile(cFile);
  compPath:=fileName;
end;

procedure TFormMain.loadResults(fileName:string);
var cFile:TextFile;
    cLine:string;
begin
  AssignFile(cFile, fileName);
  Reset(cFile);
  setlength(rests,0);
  while not Eof(cFile) do
  begin
    ReadLn(cFile, cLine);
    setlength(rests,length(rests)+1);
    rests[High(rests)]:=cLine;
  end;
  CloseFile(cFile);
  resPath:=fileName;
end;

procedure TFormMain.MenuItem12Click(Sender: TObject);
begin
  btnShowTools.Click;
end;

procedure TFormMain.MenuItem1Click(Sender: TObject);
begin

end;

procedure TFormMain.MenuItem2Click(Sender: TObject);
begin
  btnOpenDisciplines.Click;
end;

procedure TFormMain.MenuItem3Click(Sender: TObject);
begin
  btnOpenComps.Click;
end;

procedure TFormMain.MenuItem4Click(Sender: TObject);
begin
  btnOpenResults.Click;
end;

procedure TFormMain.RBExtCompChange(Sender: TObject);
begin
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtCompClick(Sender: TObject);
begin
  RBExtNone.Checked:=false;
  RBExtDisc.Checked:=false;
  RBExtComp.Checked:=true;
  RBExtRes.Checked:=false;
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtDiscChange(Sender: TObject);
begin
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtDiscClick(Sender: TObject);
begin
  RBExtNone.Checked:=false;
  RBExtDisc.Checked:=true;
  RBExtComp.Checked:=false;
  RBExtRes.Checked:=false;
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtNoneChange(Sender: TObject);
begin
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtNoneClick(Sender: TObject);
begin
  RBExtNone.Checked:=true;
  RBExtDisc.Checked:=false;
  RBExtComp.Checked:=false;
  RBExtRes.Checked:=false;
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtResChange(Sender: TObject);
begin
  FormMain.ResizeProc;
end;

procedure TFormMain.RBExtResClick(Sender: TObject);
begin
  RBExtNone.Checked:=false;
  RBExtDisc.Checked:=false;
  RBExtComp.Checked:=false;
  RBExtRes.Checked:=true;
  FormMain.ResizeProc;
end;

procedure TFormMain.refreshDisciplineChecks(discId:integer);
var i:integer;
begin
  if (discId<>-1) and (discId<nDisc) then
  begin
    if (nComp>0) then
    for i:=0 to nComp-1 do
    begin
      LBCompets.Checked[i]:=discs[discId].competIds[i];
    end;
    if (nResult>0) then
    for i:=0 to nResult-1 do
    begin
      LBResults.Checked[i]:=discs[discId].resultIds[i];
    end;
  end;
end;

procedure TFormMain.updateDisciplineChecks(discId:integer);
var i:integer;
begin
  if (discId<>-1) and (discId<nDisc) then
  begin
    if (nComp>0) then
    for i:=0 to nComp-1 do
    begin
      discs[discId].competIds[i]:=LBCompets.Checked[i];
    end;
    if (nResult>0) then
    for i:=0 to nResult-1 do
    begin
      discs[discId].resultIds[i]:=LBResults.Checked[i];
    end;
  end;
end;

procedure TFormMain.SaveMatrix(fileName:string);
var cFile:TextFile;
    i,j:integer;
begin
  //this writes a special matrix file, i.e
  //essentially, our project file
  AssignFile(cFile,fileName);
  Rewrite(cFile);

  //first, write current sets of competences and results
  //force recalc all for safety

  //competences
  WriteLn(cFile,'$'); // sign $ is a type separator
  nComp:=Length(comps);
  if (nComp>0) then
  for i:=0 to nComp-1 do
  WriteLn(cFile,comps[i]);

  //results
  WriteLn(cFile,'$');
  nResult:=Length(rests);
  if (nResult>0) then
  for i:=0 to nResult-1 do
  WriteLn(cFile,rests[i]);

  //disciplines
  WriteLn(cFile,'$');
  nResult:=Length(discs);
  if (nDisc>0) then
  for i:=0 to nDisc-1 do
  with discs[i] do
  begin
    WriteLn(cFile,name);
    WriteLn(cFile,epedname);
    WriteLn(cFile,semester);
    WriteLn(cFile,credits);
    WriteLn(cFile,lec);
    WriteLn(cFile,lab);
    WriteLn(cFile,pract);
    WriteLn(cFile,Red(colour));
    WriteLn(cFile,Green(colour));
    WriteLn(cFile,Blue(colour));
    for j:=0 to 1000 do
      WriteLn(cFile,BoolToStr(competIds[j]));
    for j:=0 to 1000 do
      WriteLn(cFile,BoolToStr(resultIds[j]));
  end;

  //end process
  CloseFile(cFile);

end;

procedure TFormMain.LoadMatrix(fileName:string);
var cFile:TextFile;
    i,j:integer;
    readMode:integer;
    op,lr:integer;
    cLine:string;
    cRed, cGreen, cBlue:integer;
begin
  AssignFile(cFile,fileName);
  Reset(cFile);

  //clean up all
  ClearDisciplines;
  SetLength(discs,0);
  SetLength(comps,0);
  SetLength(rests,0);

  //read and interpret data line by line
  readMode:=-1; //start in ignore all read mode

  while not Eof(cFile) do
  begin
    ReadLn(cFile, cLine);

    if (cLine='$') then
    begin
      inc(readMode);
      op:=0; lr:=0;
      Continue;
    end;

    if (readMode=0) then
    begin
      setlength(comps,length(comps)+1);
      comps[High(comps)]:=cLine;
    end;

    if (readMode=1) then
    begin
      setlength(rests,length(rests)+1);
      rests[High(rests)]:=cLine;
    end;

    if (readMode=2) then
    begin
      case op of
      0:begin
          setlength(discs,length(discs)+1);
          discs[High(discs)]:=TDiscipline.Create;
          discs[High(discs)].name:=cLine;
          inc(op);
        end;
      1:begin
          discs[High(discs)].epedname:=cLine;
          inc(op);
        end;
      2:begin
          discs[High(discs)].semester:=StrToInt(cLine);
          inc(op);
        end;
      3:begin
          discs[High(discs)].credits:=StrToInt(cLine);
          inc(op);
        end;
      4:begin
          discs[High(discs)].lec:=StrToInt(cLine);
          inc(op);
        end;
      5:begin
          discs[High(discs)].lab:=StrToInt(cLine);
          inc(op);
        end;
      6:begin
          discs[High(discs)].pract:=StrToInt(cLine);
          inc(op);
        end;
      7:begin
          cRed:=StrToInt(cLine);
          inc(op);
        end;
      8:begin
          cGreen:=StrToInt(cLine);
          inc(op);
        end;
      9:begin
          cBlue:=StrToInt(cLine);
          inc(op);
        end;
      10:begin
          if (lr<=1000) then
          begin
            discs[High(discs)].competIds[lr]:=StrToBool(cLine);
            inc(lr);
          end;
          if (lr>1000) then
          begin
            inc(op);
            lr:=0;
          end;
        end;
      11:begin
          if (lr<=1000) then
          begin
            discs[High(discs)].resultIds[lr]:=StrToBool(cLine);
            inc(lr);
          end;
          if (lr>1000) then
          begin
            inc(op);
            lr:=0;
            op:=0;
          end;
        end;
      end;
    end;
  end;

  //shutdown
  CloseFile(cFile);

  nDisc:=Length(discs);
  nComp:=Length(comps);
  nResult:=Length(rests);

end;

end.

