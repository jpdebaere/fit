{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of stub class receiving messages from client.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}

unit fit_server_stub;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

uses fit_server, int_points_set, log, mscr_specimen_list,
    MyExceptions, named_points_set, points_set, self_copied_component,
    SysUtils, title_points_set,
    {$IFDEF _WINDOWS}
    persistent_curve_parameters, {$ENDIF};

type
    { For transmission through network class converts exceptions into error codes.
      Maintains instance of TFitServer, recreates it in the case of fatal error. }
    TFitServerStub = class(TObject)
    protected
        FServer: TFitServer;
        FRecreateServer:
        procedure of object;
    public
        { Getting / setting attributes of the server. }

        function GetMaxRFactor: double;
        procedure SetMaxRFactor(AMaxRFactor: double);
        function GetBackFactor: double;
        procedure SetBackFactor(ABackFactor: double);
        function GetCurveThresh: double;
        procedure SetCurveThresh(ACurveThresh: double);
        function GetCurveType: TCurveTypeId;
        procedure SetCurveType(ACurveType: TCurveTypeId);
        function GetState: TFitServerState;
        function GetWaveLength: double;
        procedure SetWaveLength(AWaveLength: double);
        function GetSelectedProfileIntervalMode: boolean;

        { Wrappers to server methods. They should not throw exceptions. 
          Return codes: 0 - success, -1 - inadmissible state, -2 - fatal error. }

        function SmoothProfile(var ErrMsg: string): longint;
        function SubtractBackground(Auto: boolean;
            var ErrMsg: string): longint;
        function DoAllAutomatically(var ErrMsg: string): longint;
        function MinimizeDifference(var ErrMsg: string): longint;
        function MinimizeDifferenceAgain(var ErrMsg: string): longint;
        function MinimizeNumberOfCurves(var ErrMsg: string): longint;
        function ComputeCurveBounds(var ErrMsg: string): longint;
        function ComputeBackgroundPoints(var ErrMsg: string): longint;
        function ComputeCurvePositions(var ErrMsg: string): longint;
        function SelectAllPointsAsCurvePositions(var ErrMsg: string): longint;

        function StopAsyncOper(var ErrMsg: string): longint;
        function AsyncOper(var ErrMsg: string): boolean;
        function GetCalcTimeStr(var ErrMsg: string): string;
        function GetRFactorStr(var ErrMsg: string): string;
        function GetAbsRFactorStr(var ErrMsg: string): string;
        function GetSqrRFactorStr(var ErrMsg: string): string;
        function SelectProfileInterval(StartPointIndex, StopPointIndex: longint;
            var ErrMsg: string): longint;
        function SelectEntireProfile(var ErrMsg: string): longint;
        function CreateCurveList(var ErrMsg: string): longint;

        { Data setting. Set methods create new objects. The responsibility
          to free them is put on server. }

        function SetProfilePointsSet(APointsSet: TTitlePointsSet;
            var ErrMsg: string): longint;
        function SetBackgroundPointsSet(ABackgroundPoints: TTitlePointsSet;
            var ErrMsg: string): longint;
        function SetCurvePositions(ACurvePositions: TPointsSet;
            var ErrMsg: string): longint;
        function SetRFactorBounds(ARFactorBounds: TPointsSet;
            var ErrMsg: string): longint;
{$IFDEF _WINDOWS}
        function SetSpecialCurveParameters(ACurveExpr: string;
        { Equality to Nil means initialization. }
            CP: Curve_parameters; var ErrMsg: string): longint;
{$ENDIF}
        function AddPointToProfile(XValue, YValue: double;
            var ErrMsg: string): longint;
        function AddPointToBackground(XValue, YValue: double;
            var ErrMsg: string): longint;
        function AddPointToRFactorBounds(XValue, YValue: double;
            var ErrMsg: string): longint;
        function AddPointToCurvePositions(XValue, YValue: double;
            var ErrMsg: string): longint;

        function ReplacePointInProfile(PrevXValue, PrevYValue,
            NewXValue, NewYValue: double; var ErrMsg: string): longint;
        function ReplacePointInBackground(PrevXValue, PrevYValue,
            NewXValue, NewYValue: double; var ErrMsg: string): longint;
        function ReplacePointInRFactorBounds(PrevXValue, PrevYValue,
            NewXValue, NewYValue: double; var ErrMsg: string): longint;
        function ReplacePointInCurvePositions(PrevXValue, PrevYValue,
            NewXValue, NewYValue: double; var ErrMsg: string): longint;

        { Getting data. }

        function GetProfilePointsSet(var Points: TPointsSet;
            var ErrMsg: string): longint;
        function GetSelectedProfileInterval(var Points: TPointsSet;
            var ErrMsg: string): longint;
        function GetBackgroundPoints(var Points: TPointsSet;
            var ErrMsg: string): longint;
        function GetCurvePositions(var Points: TPointsSet;
            var ErrMsg: string): longint;
        function GetRFactorBounds(var Points: TPointsSet;
            var ErrMsg: string): longint;
{$IFDEF _WINDOWS}
        function GetSpecialCurveParameters(var CP: Curve_parameters;
            var ErrMsg: string): longint;
{$ENDIF}
        { Returns list of curve (specimen) parameters. }
        function GetCurveList(var Points: TMSCRCurveList;
            var ErrMsg: string): longint;
        { Returns list of components containing points of curves. }
        function GetCurvesList(var Points: TSelfCopiedCompList;
            var ErrMsg: string): longint;

        function GetCurveCount(var Count: longint;
            var ErrMsg: string): longint;
        function GetCurvePoints(SpecIndex: longint;
            var Points: TPointsSet; var Name: string; var ErrMsg: string): longint;
        function GetCurveParameterCount(SpecIndex: longint;
            var Count: longint; var ErrMsg: string): longint;
        function GetCurveParameter(SpecIndex: longint; ParamIndex: longint;
            var Name: string; var Value: double; var Type_: longint;
            var ErrMsg: string): longint;
        function SetCurveParameter(SpecIndex: longint; ParamIndex: longint;
            Value: double; var ErrMsg: string): longint;
        function GetCalcProfilePointsSet(var Points: TPointsSet;
            var ErrMsg: string): longint;
        function GetDeltaProfilePointsSet(var Points: TPointsSet;
            var ErrMsg: string): longint;

        { Wrappers to server attributes. WSDL does not support properties. }
        //property MaxRFactor: Double read GetMaxRFactor write SetMaxRFactor;
        //property BackFactor: Double read GetBackFactor write SetBackFactor;
        //property CurveThresh: Double read GetCurveThresh write SetCurveThresh;
        //property CurveTypeId: TCurveTypeId read GetCurveType write SetCurveType;
        //property State: TFitServerState read GetState;
        //property WaveLength: Double read GetWaveLength write SetWaveLength;

        property RecreateServer: TRecreateServer
            read FRecreateServer write FRecreateServer;
        property Server: TFitServer read FServer write FServer;
    end;

implementation

uses app;

{=========================== TFitServerStub ===================================}
function TFitServerStub.SmoothProfile(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SmoothProfile;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SubtractBackground(Auto: boolean;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.SubtractBackground(Auto);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.DoAllAutomatically(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.DoAllAutomatically;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.MinimizeDifference(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.MinimizeDifference;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.MinimizeDifferenceAgain(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.MinimizeDifferenceAgain;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.MinimizeNumberOfCurves(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.MinimizeNumberOfCurves;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ComputeCurveBounds(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.ComputeCurveBounds;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ComputeBackgroundPoints(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.ComputeBackgroundPoints;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ComputeCurvePositions(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.ComputeCurvePositions;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SelectAllPointsAsCurvePositions(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SelectAllPointsAsCurvePositions;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.CreateCurveList(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.CreateCurveList;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SelectProfileInterval(StartPointIndex, StopPointIndex: longint;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SelectProfileInterval(StartPointIndex, StopPointIndex);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SelectEntireProfile(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SelectEntireProfile;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.StopAsyncOper(var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.StopAsyncOper;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.AsyncOper(var ErrMsg: string): boolean;
begin
    try
        Result := False;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := False;
        ErrMsg := '';
        Result := Server.AsyncOper;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := False;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := False;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCalcTimeStr(var ErrMsg: string): string;
begin
    try
        Result := '';
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := '';
        ErrMsg := '';
        Result := Server.GetCalcTimeStr;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := '';
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := '';
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetRFactorStr(var ErrMsg: string): string;
begin
    try
        Result := '';
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := '';
        ErrMsg := '';
        Result := Server.GetRFactorStr;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := '';
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := '';
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetAbsRFactorStr(var ErrMsg: string): string;
begin
    try
        Result := '';
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := '';
        ErrMsg := '';
        Result := Server.GetAbsRFactorStr;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := '';
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := '';
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetSqrRFactorStr(var ErrMsg: string): string;
begin
    try
        Result := '';
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := '';
        ErrMsg := '';
        Result := Server.GetSqrRFactorStr;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := '';
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := '';
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetSelectedProfileIntervalMode: boolean;
begin
    try
        Result := False;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.SelectedAreaMode;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := False;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetMaxRFactor: double;
begin
    try
        Result := 0;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.MaxRFactor;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := 0;
        end
        else
            RecreateServer;
    end;
end;

procedure TFitServerStub.SetMaxRFactor(AMaxRFactor: double);
begin
    try
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Server.MaxRFactor := AMaxRFactor;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetBackFactor: double;
begin
    try
        Result := 0;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.BackFactor;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := 0;
        end
        else
            RecreateServer;
    end;
end;

procedure TFitServerStub.SetBackFactor(ABackFactor: double);
begin
    try
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Server.BackFactor := ABackFactor;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurveThresh: double;
begin
    try
        Result := 0;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.CurveThresh;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := 0;
        end
        else
            RecreateServer;
    end;
end;

procedure TFitServerStub.SetCurveThresh(ACurveThresh: double);
begin
    try
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Server.CurveThresh := ACurveThresh;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurveType: TCurveTypeId;
begin
    try
        Result := Server.CurveTypeId;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

procedure TFitServerStub.SetCurveType(ACurveType: TCurveTypeId);
begin
    try
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Server.CurveTypeId := ACurveType;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

{$IFDEF _WINDOWS}
function TFitServerStub.SetSpecialCurveParameters(ACurveExpr: string;
    CP: Curve_parameters;   //  ravenstvo nil oznachaet
    //  pervonachal'nuyu initsializatsiyu
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        if Assigned(CP) then
            Server.SetSpecialCurveParameters(
                ACurveExpr, Curve_parameters(CP.GetCopy))
        else
            Server.SetSpecialCurveParameters(ACurveExpr, nil);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

{$ENDIF}

function TFitServerStub.SetProfilePointsSet(APointsSet: TTitlePointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SetProfilePointsSet(APointsSet);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SetBackgroundPointsSet(ABackgroundPoints: TTitlePointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SetBackgroundPointsSet(
            TTitlePointsSet(ABackgroundPoints.GetCopy));
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SetCurvePositions(ACurvePositions: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SetCurvePositions(TPointsSet(ACurvePositions.GetCopy));
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SetRFactorBounds(ARFactorBounds: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        ErrMsg := Server.SetRFactorBounds(
            TPointsSet(ARFactorBounds.GetCopy));
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetProfilePointsSet(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetProfilePointsSet;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetSelectedProfileInterval(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetSelectedProfileInterval;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCalcProfilePointsSet(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetCalcProfilePointsSet;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetDeltaProfilePointsSet(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetDeltaProfilePointsSet;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetBackgroundPoints(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetBackgroundPoints;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurvePositions(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetCurvePositions;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetRFactorBounds(var Points: TPointsSet;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetRFactorBounds;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

{$IFDEF _WINDOWS}
function TFitServerStub.GetSpecialCurveParameters(var CP: Curve_parameters;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        CP     := Server.GetSpecialCurveParameters;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

{$ENDIF}

function TFitServerStub.GetCurveList(var Points: TMSCRCurveList;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetCurveList;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

//{$IFDEF FIT}
function TFitServerStub.GetCurvesList(var Points: TSelfCopiedCompList;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Points := Server.GetCurvesList;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;
//{$ELSE}
function TFitServerStub.GetCurveCount(var Count: longint;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Count  := Server.GetCurveCount;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurvePoints(SpecIndex: longint;
    var Points: TPointsSet; var Name: string; var ErrMsg: string): longint;
var
    CPS: TNamedPointsSet;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        CPS    := Server.GetCurvePoints(SpecIndex);
        Points := CPS;
        Name   := CPS.GetCurveTypeName;
        Result := 0;
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurveParameterCount(SpecIndex: longint;
    var Count: longint; var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Count  := Server.GetCurveParameterCount(SpecIndex);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.SetCurveParameter(SpecIndex: longint;
    ParamIndex: longint; Value: double; var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.SetCurveParameter(SpecIndex, ParamIndex, Value);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetCurveParameter(SpecIndex: longint;
    ParamIndex: longint; var Name: string; var Value: double;
    var Type_: longint; var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.GetCurveParameter(SpecIndex, ParamIndex, Name, Value, Type_);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;
//{$ENDIF}

function TFitServerStub.GetState: TFitServerState;
begin
    try
        Result := ProfileWaiting;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.State;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := ProfileWaiting;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.GetWaveLength: double;
begin
    try
        Result := 0;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := Server.WaveLength;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := 0;
        end
        else
            RecreateServer;
    end;
end;

procedure TFitServerStub.SetWaveLength(AWaveLength: double);
begin
    try
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Server.WaveLength := AWaveLength;
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.AddPointToProfile(XValue, YValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.AddPointToProfile(XValue, YValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.AddPointToBackground(XValue, YValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.AddPointToBackground(XValue, YValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.AddPointToRFactorBounds(XValue, YValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.AddPointToRFactorBounds(XValue, YValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.AddPointToCurvePositions(XValue, YValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.AddPointToCurvePositions(XValue, YValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ReplacePointInProfile(
    PrevXValue, PrevYValue, NewXValue, NewYValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.ReplacePointInProfile(PrevXValue, PrevYValue, NewXValue, NewYValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ReplacePointInBackground(
    PrevXValue, PrevYValue, NewXValue, NewYValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.ReplacePointInBackground(
            PrevXValue, PrevYValue, NewXValue, NewYValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ReplacePointInRFactorBounds(
    PrevXValue, PrevYValue, NewXValue, NewYValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.ReplacePointInRFactorBounds(
            PrevXValue, PrevYValue, NewXValue, NewYValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

function TFitServerStub.ReplacePointInCurvePositions(
    PrevXValue, PrevYValue, NewXValue, NewYValue: double;
    var ErrMsg: string): longint;
begin
    try
        Result := -2;
        Assert(Assigned(RecreateServer));
    except
        on E: Exception do
        begin
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            Exit;
        end
        else
            Exit;
    end;

    try
        Result := 0;
        ErrMsg := '';
        Server.ReplacePointInCurvePositions(
            PrevXValue, PrevYValue, NewXValue, NewYValue);
    except
        on E: EUserException do
        begin
            ErrMsg := E.Message;
            Result := -1;
        end;
        on E: Exception do
        begin
            ErrMsg := E.Message;
            WriteLog(CreateErrorMessage(E.Message), Fatal);
            RecreateServer;
            Result := -2;
        end
        else
            RecreateServer;
    end;
end;

end.
