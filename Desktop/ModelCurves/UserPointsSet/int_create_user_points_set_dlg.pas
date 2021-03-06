{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of interface for creating user dialog for configuring parameters of custom curve type.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn: https://www.linkedin.com/in/dmitry-morozov-79490a59/
Facebook: https://www.facebook.com/dmitry.v.morozov)
}
unit int_create_user_points_set_dlg;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

type
    { Interface defining basic operations for creating user
      dialog for configuring parameters of custom curve type. }
    ICreateUserPointsSetDlg = interface
        function ShowModal: integer;
        function GetExpression: string;
        function GetName: string;
    end;

implementation

end.
