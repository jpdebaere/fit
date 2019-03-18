{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definitions of base curve class allowing setting up type name.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit NamedPointsSet;

{$MODE Delphi}

interface

uses Classes, SysUtils, CurvePointsSet, IntPointsSet, ConfigurablePointsSet;

type
    TNamedPointsSetClass = class of TNamedPointsSet;
    { Base curve class allowing setting up type name. Type name distinguishes
      this curve from all other curve types, as opposite to the 'Title' attributes
      which is used to distinguish separate curve instances. }
    TNamedPointsSet = class(TCurvePointsSet, IPointsSet)
    private
        { The attribute should not be used in descendants. }
        FName: string;
        FCurveTypeId: TCurveTypeId;

    public
        { Sets unique identifier of curve type. }
        procedure SetCurveTypeId(CurveTypeId: TCurveTypeId); virtual;
        { Sets name of curve type. The method is used in deserializing
          objects received from server. }
        procedure SetCurveTypeName(Name: string); virtual;
        { Returns unique identifier of curve type. }
        function GetCurveTypeId: TCurveTypeId; virtual;
        { Returns name of curve type. It's better to use function
          instead of property because property assumes storing data
          in object, but storing any data is not necessary in this case. }
        function GetCurveTypeName: string; virtual;
        class function GetCurveTypeId_: TCurveTypeId; virtual; abstract;

        class function GetConfigurablePointsSet:
            TConfigurablePointsSetClass; virtual;
    end;

implementation

uses NonConfigurablePointsSet;

{============================ TNamedPointsSet =================================}

function TNamedPointsSet.GetCurveTypeName: string;
begin
    Result := FName;
end;

procedure TNamedPointsSet.SetCurveTypeName(Name: string);
begin
    FName := Name;
end;

function TNamedPointsSet.GetCurveTypeId: TCurveTypeId;
begin
    Result := FCurveTypeId;
end;

procedure TNamedPointsSet.SetCurveTypeId(CurveTypeId: TCurveTypeId);
begin
    FCurveTypeId := CurveTypeId;
end;

class function TNamedPointsSet.GetConfigurablePointsSet: TConfigurablePointsSetClass;
begin
    Result := TNonConfigurablePointsSet;
end;

end.

