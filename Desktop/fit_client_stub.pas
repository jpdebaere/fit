{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of stub class implementing callbacks to client.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn: https://www.linkedin.com/in/dmitry-morozov-79490a59/
Facebook: https://www.facebook.com/dmitry.v.morozov)
}
unit fit_client_stub;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

uses
    int_client_callback;

type
    TFitClientStub = class(TInterfacedObject, IClientCallback)
    protected
        FFitClient: TObject;

    public
        procedure ShowCurMin(Min: double);
        procedure ShowProfile;
        procedure Done;
        procedure ComputeCurveBoundsDone;
        procedure ComputeBackgroundPointsDone;
        procedure ComputeCurvePositionsDone;

        property FitClient: TObject read FFitClient write FFitClient;
    end;

implementation

uses
    fit_client;

procedure TFitClientStub.ShowCurMin(Min: double);
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).ShowCurMin(Min);
end;

procedure TFitClientStub.ShowProfile;
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).ShowProfile;
end;

procedure TFitClientStub.Done;
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).Done;
end;

procedure TFitClientStub.ComputeCurveBoundsDone;
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).ComputeCurveBoundsDone;
end;

procedure TFitClientStub.ComputeBackgroundPointsDone;
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).ComputeBackgroundPointsDone;
end;

procedure TFitClientStub.ComputeCurvePositionsDone;
begin
    Assert(Assigned(FitClient));

    TFitClient(FitClient).ComputeCurvePositionsDone;
end;

end.
