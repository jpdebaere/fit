{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of interface for iterating through curve types.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn: https://www.linkedin.com/in/dmitry-morozov-79490a59/
Facebook: https://www.facebook.com/dmitry.v.morozov)
}
unit int_curve_type_iterator;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

uses
    named_points_set;

type
    { Interface defining basic operation for iterating through curve types. }
    ICurveTypeIterator = interface
        procedure FirstCurveType;
        procedure NextCurveType;
        function EndCurveType: boolean;
        function GetCurveTypeName: string;
        function GetCurveTypeId: TCurveTypeId;
        function GetCurveTypeTag(CurveTypeId: TCurveTypeId): integer;
    end;

implementation

end.
