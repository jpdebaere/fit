{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of class-adapter for ICurveTypeStorage.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn: https://www.linkedin.com/in/dmitry-morozov-79490a59/
Facebook: https://www.facebook.com/dmitry.v.morozov)
}
unit curve_type_storage_adapter;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

uses
    app_settings, int_curve_type_storage, SysUtils;

type
    { Class-adapter implementing basic operation for 
      storing parameters of custom curve type.
      Implemented as singleton. }
    {$warnings off}
    TCurveTypeStorageAdapter = class(TInterfacedObject, ICurveTypeStorage)
    private
        constructor Init;

    public
        class function Create: ICurveTypeStorage;

        procedure AddCurveType(CurveType: Curve_type);
        procedure UpdateCurveType(CurveType: Curve_type);
        procedure DeleteCurveType(CurveType: Curve_type);
    end;

    {$warnings on}

implementation

uses
    form_main;

var
    CurveTypeStorageAdapter: TCurveTypeStorageAdapter;

constructor TCurveTypeStorageAdapter.Init;
begin
    inherited;
end;

class function TCurveTypeStorageAdapter.Create: ICurveTypeStorage;
begin
    Result := ICurveTypeStorage(CurveTypeStorageAdapter);
end;

procedure TCurveTypeStorageAdapter.AddCurveType(CurveType: Curve_type);
begin
    //  Saving curve parameters.
    FormMain.FSettings.Curve_types.Add(CurveType);
    FormMain.WriteUserCurve(CurveType);

    //FormMain.DeleteDummyCurve;
    //  Adds new menu item.
    FormMain.AddUserCurveMenu(CurveType);
end;

procedure TCurveTypeStorageAdapter.UpdateCurveType(CurveType: Curve_type);
begin
    DeleteFile(PChar(CurveType.FFileName));
    FormMain.WriteUserCurve(CurveType);
end;

procedure TCurveTypeStorageAdapter.DeleteCurveType(CurveType: Curve_type);
begin
    FormMain.DeleteUserCurve(CurveType);
end;

initialization
    CurveTypeStorageAdapter := TCurveTypeStorageAdapter.Init;

finalization
    CurveTypeStorageAdapter.Free;

end.
