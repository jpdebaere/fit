{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of class representing the application.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit FitClientApp;

//{$mode objfpc}{$H+}
{$MODE Delphi}

interface

uses Classes, SysUtils, FitClient, FitClientStub, FitClientProxy, DataLoader;

type
	{ Container class (agregate), which integrates all application components except UI. }
    TFitClientApp = class(TObject)
    private
        FFitProxy: TFitClientProxy;
        FFitStub: TFitClientStub;
        FFitClient: TFitClient;
        FDataLoader: TDATFileLoader;

    public
        constructor Create;
        destructor Destroy; override;

        property FitClient: TFitClient read FFitClient;
        property FitStub: TFitClientStub read FFitStub;
        property FitProxy: TFitClientProxy read FFitProxy;
    end;

implementation

{============================== TFitClientApp =================================}
constructor TFitClientApp.Create;
begin
    inherited;
    FFitProxy := TFitClientProxy.Create;
    FFitStub := TFitClientStub.Create(nil);
    FDataLoader := TDATFileLoader.Create(nil);
    FFitClient := TFitClient.Create(nil, FDataLoader);

    FFitClient.FitProxy := FFitProxy;
    FFitStub.FitClient := FFitClient;
end;

destructor TFitClientApp.Destroy;
begin
    FFitClient.Free;
    FFitStub.Free;
    FFitProxy.Free;
    FDataLoader.Free;
end;

end.



