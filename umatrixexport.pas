unit uMatrixExport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  uFormMain;

type

  { TFormMatrixExport }

  TFormMatrixExport = class(TForm)
    btnExportData: TButton;
    btnPrepData: TButton;
    btnPrepHTML: TButton;
    cbShortComp: TCheckBox;
    cbShortRes: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnExportDataClick(Sender: TObject);
    procedure btnPrepHTMLClick(Sender: TObject);
    procedure PrepData;
    procedure PrepHTML;
    procedure ExportData(fileName:string);
    procedure btnPrepDataClick(Sender: TObject);
  private

  public

  end;

var
  FormMatrixExport: TFormMatrixExport;
  //holds formed text values for matrix hits
  outMatrix:array of array of string;
  //headers for columns and rows
  compTitles:array of string;
  resTitles:array of string;
  //container to export html
  htmlData:TStringList;

implementation

{$R *.lfm}

{ TFormMatrixExport }
function makeHeader(text:string;short:boolean):string;
var vSet:string;
    i:integer;
begin
  if (not short) then result:=text;
  if (short) then
  begin
    vset:='';
    i:=1;
    while (i<=Length(text)) do
    begin
      if (text[i]<>'.') then vset:=vset+text[i];
      if (text[i]='.') then break;
      inc(i);
    end;
    result:=vset;
  end;
end;

procedure TFormMatrixExport.PrepData;
var shortRest,shortComp,shortDisc:boolean;
    i,j,k:integer;
    hitsRes,hitsComp:integer;
begin
  //prep logging
  Memo1.Clear;
  Memo1.Lines.Add('[!] Initiating prep...');
  //step 1 - read settings
  shortRest:=cbShortRes.Checked;
  shortComp:=cbShortComp.Checked;
  //step 2 - form headers
  SetLength(compTitles,nComp);
  SetLength(resTitles,nResult);
  for i:=0 to nComp-1 do
  begin
    compTitles[i]:=makeHeader(comps[i],shortComp);
  end;
  for i:=0 to nResult-1 do
  begin
    resTitles[i]:=makeHeader(rests[i],shortRest);
  end;
  //step 3 - prep main arrays
  SetLength(outMatrix,nResult);
  for i:=0 to nResult-1 do SetLength(outMatrix[i],nComp);
  //step 4 - parse all results for disiplines, then finad all disciplines
  //  that also heave comps

  //for each result...
  for i:=0 to nResult-1 do
  begin
    hitsRes:=0;
    //check if a discipline has it...
    for k:=0 to nDisc-1 do
    begin
      inc(hitsRes);
      if discs[k].resultIds[i] then
      begin
        //and if it does, find all competences it has
        hitsComp:=0;
        for j:=0 to nComp-1 do
        begin
          if discs[k].competIds[j] then
          begin
            inc(hitsComp);
            //and for each case of it having a competence, record it
            if (length(outMatrix[i][j])>0) then
              outMatrix[i][j]:=outMatrix[i][j]+', '+discs[k].epedname
            else
              outMatrix[i][j]:=discs[k].epedname;
          end;
        end;
        if (hitsComp=0) then Memo1.Lines.Add('[!!!] '+discs[k].name+' has no competences assigned!');
      end;
    end;
    if (hitsRes=0) then Memo1.Lines.Add('[!!!] '+rests[i]+' has no associated disciplines!');
  end;
  Memo1.Lines.Add('[!] Prep complete.');
  Memo1.Lines.Add('[!] Ready to export.');
end;

procedure TFormMatrixExport.btnPrepDataClick(Sender: TObject);
begin
  PrepData;
end;

procedure TFormMatrixExport.btnPrepHTMLClick(Sender: TObject);
begin
 PrepHTML;
end;

procedure TFormMatrixExport.btnExportDataClick(Sender: TObject);
begin
  if (FormMain.SDMatrixExport.Execute) then
  begin
    ExportData(FormMain.SDMatrixExport.FileName);
  end;
end;

procedure TFormMatrixExport.PrepHTML;
var i,j:integer;
begin
  htmlData:=TStringList.Create;
  htmlData.Clear;
  htmlData.Add('<!DOCTYPE html>');
  htmlData.Add('<html>');

  htmlData.Add('<head>');
  htmlData.Add('<style>');
  htmlData.Add('table, th, td { border: 1px solid black; border-collapse: collapse; }');
  htmlData.Add('</style>');
  htmlData.Add('</head>');

  htmlData.Add('<body>');
  htmlData.Add('<table>');
  //here goes the actual output
  //first row is comps + cell 0 is results header
  //each next row is result name + set of values in matrix
  htmlData.Add('<tr>');

  htmlData.Add('<th>Education Results</th>');
  for i:=0 to nComp-1 do htmlData.Add('<th>'+compTitles[i]+'</th>');

  htmlData.Add('</tr>');

  //now fill all raws with matrix data
  for i:=0 to nResult-1 do
  begin
    htmlData.Add('<tr>');
    for j:=-1 to nComp-1 do
    begin
      if (j=-1) then htmlData.Add('<td>'+resTitles[i]+'</td>')
      else
        begin
          htmlData.Add('<td>'+outMatrix[i][j]+'</td>');
        end;
    end;
    htmlData.Add('</tr>');
  end;

  htmlData.Add('</table>');
  htmlData.Add('</body>');
  htmlData.Add('</html>');
end;

procedure TFormMatrixExport.ExportData(fileName:string);
begin
 Memo1.Lines.Clear;
 Memo1.Lines.Add('[!] Exporting data to '+fileName+'...');
 try
   htmlData.SaveToFile(fileName);
 except
   Memo1.Lines.Add('[!!!] Export error!');
 end;
 Memo1.Lines.Add('[!] Export process ended.');
end;



end.

