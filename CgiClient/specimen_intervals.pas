unit specimen_intervals;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, cgiModules;

function PrepareTemplate_specimen_intervals: string;

implementation

uses Data, app;

const
    PairCount = 9; // 12; //  kol-vo elementov
    PairArray: array[1..PairCount] of TStringPair = (
        ('Title',
        'Curve intervals'
        //'The page of selection of specimen bounds'
        //'����� ���������� ���������� ����������� ��������'
        ),
        ('HintBounds1',
        'The division of whole experimental data on specimen ' +
        'bounds is advisable only for data looking ' +
        'like set of peaks. The possibility of that division based on ' +
        'assumption that sections of data corresponding to different peaks ' +
        'obtained at different physical conditions and therefore do not ' +
        'have common parameters. Besides the difference between ' +
        'experimental and calculated profiles in regions of relatively ' +
        'great amplitude forms most important contribution into the ' +
        'difference factor. As a result visually worse coincidence ' +
        'between experimental and calculated curves achieved in regions of ' +
        'relatively small amplitude.<BR>' +
        'If a few specimen bounds was created the total ' +
        'difference factor is calculated by summation of the individual ' +
        'values.<BR>' +
        'If the division on intervals has no meaning for your data simply ' +
        'create a single interval covering all the data.'
            //���������� ������� ���������������� ������ �� ���������
            //���������� ����������� �������� ������������� ���������
            //������� ������� ��� ������, ������� ��� �������. �����������
            //������ ���������� �������� �� �������������, ��� �������
            //����������������� ������, ��������������� ��������� �����,
            //�������� ��� ��������� ������ �������� � ������� �� �����
            //����� ����������. ����� ����, � �������� ������� ������������
            //�� ����� ������� ������ ���������� ���� ���������� ����� ����
            //����������� ������������������ � ������������� �������� �
            //������� ����� ������������ ������� ���������. � ����������
            //����� �������� ���������� ����������� �������� � �������
            //����� ������������ ����� ��������� ����������� �����������
            //������ ������������ ����� ����������������� � ������������
            //�������, ��� � �������� � ������� ����������.
            //��� �������� ���������� ���������� �������� ��������
            //������� ������������ ���������� ������������� ��������,
            //���������� �� ���� ����������.
            //���� ��� ����� ������ ���������� �� ��������� �� ����� ������,
            //�� ������ �������� ���� ��������, ���������� ��� ������.
        ),  //  !!! v kontse dolzhen byt' probel !!!
        ('HintBounds2',
        'The specimen bounds could be ' +
        'generated automatically at present time only for data ' +
        'looking like set of peaks. ' +
        //'��������� ���������� ����������� ��������� ����� ���� ' +
        //'������������� ������������� ������ ��� ������, ������� ' +
        //'��� �������. '
        'The specimen application interval cuts down curves which ' +
        'have the position inside.'
        //'���������� �������������� ���������� ��������, ' +
        //'������� ����� �������� � ���.'
        ),
        (* zameneno kartinkoy
        ('CaptButGenerate',
            'Generate'
            //'������������'
        ),
        *)
        ('CaptPointSelection',
        'Boundaries selection'
        //'����� ������ ����������'
        ),
        ('CaptArgument',
        'Argument'
        //'��������'
        ),
        ('CaptValue',
        'Value'
        //'��������'
        ),
        ('CaptBoundPoint',
        ' ' // 'Boundary'
            //'����� �������?'
        ),
        (* zameneno kartinkoy
        ('CaptButBoundPoint',
            'Select / Unselect'
            //'����� ������� / �� ����� �������'
        ),
        *)
        (*
        ('CaptButSkip',
            'Skip boundaries selection'
            //'���������� ����� ������'
        ),
        *)
        ('CaptButNextStage',
        'Curve parameters'
        //'������� � ������� �������� ����������'
        ),
        ('HintValues',
        'To add point to the list of interval boundaries type its argument. ' +
        'Then press the button. To delete press the button again.'
        //'��� ���������� ����� � ������ ������ ���������� ���������� ����������� '     +
        //'�������� ������� �� ��������. ' +
        //'������� ������. ��������� ������� ������ ������� ����� �� ������ ����� ��������.'
        )
        );

function ReplaceStrings_specimen_intervals(Text: string): string;
var
    Pair: array[1..1] of TStringPair;
begin
    Result     := ReplaceStrings(Text, PairArray, PairCount);
    Result     := ReplaceStrings(Result, CommonPairArray, CommonPairCount);
    Pair[1][1] := 'ServerName';
    Pair[1][2] := ExternalIP;
    Result     := ReplaceStrings(Result, Pair, 1);
end;

function PrepareTemplate_specimen_intervals: string;
var
    Page: TStringList;
begin
    Result := '';
    Page   := TStringList.Create;
    try
        Page.LoadFromFile('specimen_intervals.htm');
        Result := ReplaceStrings_specimen_intervals(Page.Text);
    finally
        Page.Free;
    end;
end;

end.
