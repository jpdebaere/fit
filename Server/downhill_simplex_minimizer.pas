{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of downhill simplex algorithm.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit downhill_simplex_minimizer;

interface

uses Classes, DownhillSimplexServer, int_minimizer, log, SysUtils, Tools;

type
    { Implements application interfaces required by downhill simplex algorithm. }
    TDownhillSimplexMinimizer = class(TMinimizer,
        IOptimizedFunction, IDownhillRealParameters, IUpdatingResults)
    private
        Server: TDownhillSimplexServer;

        procedure SelectParameter(index: longint);

    protected
        procedure SetTerminated(ATerminated: boolean); override;

    public
        procedure Minimize(var ErrorCode: longint); override;

        {IOptimizedFunction}
        function GetOptimizedFunction: double;

        {IDownhillRealParameters}
        procedure CreateParameters;
        procedure ParametersUpdated;

        {IDownhillSimplexParameters}
        function GetParametersNumber: longint;
        function GetParameter(index: longint): TVariableParameter;
        procedure SetParameter(index: longint; AParameter: TVariableParameter);
        function GetVariationStep(index: LongInt): double;
        procedure SetVariationStep(index: LongInt; Value: double);

        {IDiscretValue}
        function GetNumberOfValues: longint;
        function GetValueIndex: longint;
        procedure SetValueIndex(const AValueIndex: longint);

        {IUpdatingResults}
        procedure ShowCurJobProgress(Sender: TComponent;
            MinValue, MaxValue, CurValue: longint);
        procedure ResetCurJobProgress(Sender: TComponent);
        procedure ShowMessage(Sender: TComponent; Msg: string);
        procedure UpdateResults(Sender: TComponent);

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    end;

procedure Register;

implementation

procedure Register;
begin
end;

{========================== TDownhillSimplexMinimizer =========================}
procedure TDownhillSimplexMinimizer.Minimize(var ErrorCode: longint);
begin
    ErrorCode  := IsReady;
    Terminated := False;
    if ErrorCode <> MIN_NO_ERRORS then
        Exit;

    with Server do
        Run;
end;

{IOptimizedFunction}
function TDownhillSimplexMinimizer.GetOptimizedFunction: double;
begin
    OnComputeFunc;
    Result := OnGetFunc;
end;

{IDownhillRealParameters}
procedure TDownhillSimplexMinimizer.CreateParameters;
begin
end;

procedure TDownhillSimplexMinimizer.ParametersUpdated;
begin
end;

{IDownhillSimplexParameters}
function TDownhillSimplexMinimizer.GetParametersNumber: longint;
begin
    Result := 0;
    OnSetFirstParam;
    while not OnEndOfCycle do
    begin
        Inc(Result);
        OnSetNextParam;
    end;
end;

function TDownhillSimplexMinimizer.GetParameter(index: longint): TVariableParameter;
begin
    SelectParameter(index);
    Result.Limited := False;
    Result.Value   := OnGetParam;
end;

procedure TDownhillSimplexMinimizer.SetParameter(index: longint;
    AParameter: TVariableParameter);
begin
    SelectParameter(index);
    OnSetParam(AParameter.Value);
end;

function TDownhillSimplexMinimizer.GetVariationStep(index: LongInt): double;
begin
    SelectParameter(index);
    Result := OnGetVariationStep;
end;

procedure TDownhillSimplexMinimizer.SetVariationStep(index: LongInt; Value: double);
begin
    SelectParameter(index);
    OnSetVariationStep(Value);
end;

procedure TDownhillSimplexMinimizer.SelectParameter(index: longint);
var
    i: longint;
begin
    i := 0;
    OnSetFirstParam;
    while not OnEndOfCycle do
    begin
        if i = index then
            Break;
        Inc(i);
        OnSetNextParam;
    end;
end;

{IDiscretValue}
function TDownhillSimplexMinimizer.GetNumberOfValues: longint;
begin
    //  Minimum number of values should be equal to 1.
    Result := 1;
end;

function TDownhillSimplexMinimizer.GetValueIndex: longint;
begin
    Result := 0;
end;

procedure TDownhillSimplexMinimizer.SetValueIndex(const AValueIndex: longint);
begin
    Assert(AValueIndex = 0);
end;

{$hints off}
procedure TDownhillSimplexMinimizer.ShowCurJobProgress(Sender: TComponent;
    MinValue, MaxValue, CurValue: longint);
begin

end;

procedure TDownhillSimplexMinimizer.ResetCurJobProgress(Sender: TComponent);
begin

end;

procedure TDownhillSimplexMinimizer.ShowMessage(Sender: TComponent; Msg: string);
begin

end;

{$hints on}

procedure TDownhillSimplexMinimizer.UpdateResults(Sender: TComponent);
begin
    if Assigned(OnShowCurMin) then
    begin
        FCurrentMinimum := Server.FTotalMinimum;
        OnShowCurMin;
        WriteLog('Current minimium = ' + FloatToStr(FCurrentMinimum), Debug);
    end;
end;

procedure TDownhillSimplexMinimizer.SetTerminated(ATerminated: boolean);
begin
    inherited;
    if ATerminated then
        Server.StopAlgorithm;
end;

constructor TDownhillSimplexMinimizer.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    Server := TDownhillSimplexServer.Create(nil);
    Server.UpdatingResults := Self;
    Server.OptimizedFunction := Self;
    //  Final tolerance should have non zero value,
    //  otherwise computation will never end
    //  (see TDownhillSimplexServer.CreateAlgorithm).
    Server.FinalTolerance := 0.001; //1e-10;
    Server.RestartDisabled := True;
    Server.AddIDSPToList(Self);
end;

destructor TDownhillSimplexMinimizer.Destroy;
begin
    UtilizeObject(Server);
    inherited Destroy;
end;

end.
