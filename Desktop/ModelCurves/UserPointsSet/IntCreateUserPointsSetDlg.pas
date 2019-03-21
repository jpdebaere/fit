{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of interface for creating user dialog for configuring parameters of custom curve type.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit IntCreateUserPointsSetDlg;

{$MODE Delphi}

interface

uses Classes, SysUtils, Settings;

type
    { Interface defining basic operation for creating user
      dialog for configuring parameters of custom curve type. }
    ICreateUserPointsSetDlg = interface
        procedure ShowModal;
        function GetExpression: string;
        function GetName: string;
    end;

implementation

end.

