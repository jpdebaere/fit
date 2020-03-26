{
This unit has been produced by ws_helper.
  Input unit name : "fit_server".
  This unit name  : "fit_server_proxy".
  Date            : "12.01.2009 11:43:17".
}

unit fit_server_proxy;

{$IFDEF FPC} {$mode objfpc}{$H+} {$ENDIF}
interface

uses
    SysUtils, Classes, TypInfo, int_points_set, base_service_intf,
    service_intf, int_fit_server;

type


    TFitServer_Proxy = class(TBaseProxy, IFitServer)
    protected
        class function GetServiceType(): PTypeInfo; override;
        function SmoothProfile(const ProblemID: integer): TResult;
        function SubtractBackground(const Auto: boolean;
            const ProblemID: integer): TResult;
        function DoAllAutomatically(const ProblemID: integer): TResult;
        function MinimizeDifference(const ProblemID: integer): TResult;
        function MinimizeNumberOfSpecimens(
            const ProblemID: integer): TResult;
        function FindSpecimenIntervals(const ProblemID: integer): TResult;
        function FindSpecimenPositions(const ProblemID: integer): TResult;
        function FindBackPoints(const ProblemID: integer): TResult;
        function StopAsyncOper(const ProblemID: integer): TResult;
        function AsyncOper(const ProblemID: integer): TBoolResult;
        function SelectArea(const StartPointIndex: integer;
            const StopPointIndex: integer; const ProblemID: integer): TResult;
        function ReturnToTotalProfile(const ProblemID: integer): TResult;
        function CreateSpecimenList(const ProblemID: integer): TResult;
        function SetProfilePointsSet(const PointsSet:
            TArrayOfFloatDoubleRemotable; const ProblemID: integer): TResult;
        function SetBackgroundPointsSet(
            const BackgroundPoints: TArrayOfFloatDoubleRemotable;
            const ProblemID: integer): TResult;
        function SetSpecimenPositions(
            const SpecimenPositions: TArrayOfFloatDoubleRemotable;
            const ProblemID: integer): TResult;
        function SetSpecimenIntervals(
            const SpecimenIntervals: TArrayOfFloatDoubleRemotable;
            const ProblemID: integer): TResult;
        function AddPointToBackground(const XValue: double;
            const YValue: double; const ProblemID: integer): TResult;
        function AddPointToSpecimenIntervals(const XValue: double;
            const YValue: double; const ProblemID: integer): TResult;
        function AddPointToSpecimenPositions(const XValue: double;
            const YValue: double; const ProblemID: integer): TResult;
        function GetProfilePointsSet(const ProblemID: integer): TPointsResult;
        function GetSelectedArea(const ProblemID: integer): TPointsResult;
        function GetBackgroundPoints(const ProblemID: integer): TPointsResult;
        function GetSpecimenPositions(
            const ProblemID: integer): TPointsResult;
        function GetSpecimenIntervals(
            const ProblemID: integer): TPointsResult;
        function GetCalcProfilePointsSet(
            const ProblemID: integer): TPointsResult;
        function GetDeltaProfilePointsSet(const ProblemID: integer):
            TPointsResult;
        procedure SetCurveThresh(const CurveThresh: double;
            const ProblemID: integer);
        function GetMaxRFactor(const ProblemID: integer): double;
        procedure SetMaxRFactor(const MaxRFactor: double;
            const ProblemID: integer);
        function GetBackFactor(const ProblemID: integer): double;
        procedure SetBackFactor(const BackFactor: double;
            const ProblemID: integer);
        function GetCurveType(const ProblemID: integer): TCurveTypeId;
        procedure SetCurveType(const CurveTypeId: TCurveTypeId;
            const ProblemID: integer);
        function GetWaveLength(const ProblemID: integer): double;
        procedure SetWaveLength(const WaveLength: double;
            const ProblemID: integer);
        function GetCurveThresh(const ProblemID: integer): double;
        function GetState(const ProblemID: integer): integer;
        function ReplacePointInProfile(const PrevXValue: double;
            const PrevYValue: double; const NewXValue: double;
            const NewYValue: double; const ProblemID: integer): TResult;
        function ReplacePointInBackground(const PrevXValue: double;
            const PrevYValue: double; const NewXValue: double;
            const NewYValue: double; const ProblemID: integer): TResult;
        function ReplacePointInSpecimenIntervals(const PrevXValue: double;
            const PrevYValue: double; const NewXValue: double;
            const NewYValue: double; const ProblemID: integer): TResult;
        function ReplacePointInSpecimenPositions(const PrevXValue: double;
            const PrevYValue: double; const NewXValue: double;
            const NewYValue: double; const ProblemID: integer): TResult;
        function CreateProblem(): integer;
        procedure DiscardProblem(const ProblemID: integer);
        function GetSpecimenCount(const ProblemID: integer): TIntResult;
        function GetSpecimenPoints(const SpecIndex: integer;
            const ProblemID: integer): TNamedPointsResult;
        function GetSpecimenParameterCount(const ProblemID: integer;
            const SpecIndex: integer): TIntResult;
        function GetSpecimenParameter(const ProblemID: integer;
            const SpecIndex: integer;
            const ParamIndex: integer): TSpecParamResult;
        function AddPointToData(const XValue: double; const YValue: double;
            const ProblemID: integer): TResult;
        function GetGraph(const Width: integer; const Height: integer;
            const ProblemID: integer): TPictureResult;
        function GetProfileChunk(const ProblemID: integer;
            const ChunkNum: integer): TPointsResult;
        function GetProfileChunkCount(const ProblemID: integer): TIntResult;
        function SetSpecimenParameter(const ProblemID: integer;
            const SpecIndex: integer; const ParamIndex: integer;
            const Value: double): TResult;
        function GetCalcTimeStr(const ProblemID: integer): TStringResult;
        function GetRFactorStr(const ProblemID: integer): TStringResult;
        function GetAbsRFactorStr(const ProblemID: integer): TStringResult;
        function GetSqrRFactorStr(const ProblemID: integer): TStringResult;
    end;

function wst_CreateInstance_IFitServer(const AFormat: string = 'SOAP:';
    const ATransport: string = 'HTTP:'): IFitServer;

implementation

uses wst_resources_imp, metadata_repository;

function wst_CreateInstance_IFitServer(const AFormat: string;
    const ATransport: string): IFitServer;
begin
    Result := TFitServer_Proxy.Create('IFitServer', AFormat +
        GetServiceDefaultFormatProperties(TypeInfo(IFitServer)),
        ATransport + 'address=' + GetServiceDefaultAddress(TypeInfo(IFitServer)));
end;

{ TFitServer_Proxy implementation }

class function TFitServer_Proxy.GetServiceType(): PTypeInfo;
begin
    Result := TypeInfo(IFitServer);
end;

function TFitServer_Proxy.SmoothProfile(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SmoothProfile', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SubtractBackground(const Auto: boolean;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SubtractBackground', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('Auto', TypeInfo(boolean), Auto);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.DoAllAutomatically(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('DoAllAutomatically', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.MinimizeDifference(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('MinimizeDifference', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.MinimizeNumberOfSpecimens(
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('MinimizeNumberOfSpecimens', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.FindSpecimenIntervals(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('FindSpecimenIntervals', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.FindSpecimenPositions(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('FindSpecimenPositions', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.FindBackPoints(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('FindBackPoints', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.StopAsyncOper(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('StopAsyncOper', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.AsyncOper(const ProblemID: integer): TBoolResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('AsyncOper', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TBoolResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SelectArea(const StartPointIndex: integer;
    const StopPointIndex: integer; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SelectArea', GetTarget(), (Self as ICallContext));
        locSerializer.Put('StartPointIndex', TypeInfo(integer), StartPointIndex);
        locSerializer.Put('StopPointIndex', TypeInfo(integer), StopPointIndex);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.ReturnToTotalProfile(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('ReturnToTotalProfile', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.CreateSpecimenList(const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('CreateSpecimenList', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SetProfilePointsSet(
    const PointsSet: TArrayOfFloatDoubleRemotable; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetProfilePointsSet', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('PointsSet', TypeInfo(TArrayOfFloatDoubleRemotable),
            PointsSet);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SetBackgroundPointsSet(
    const BackgroundPoints: TArrayOfFloatDoubleRemotable;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetBackgroundPointsSet', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('BackgroundPoints', TypeInfo(TArrayOfFloatDoubleRemotable),
            BackgroundPoints);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SetSpecimenPositions(
    const SpecimenPositions: TArrayOfFloatDoubleRemotable;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetSpecimenPositions', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('SpecimenPositions', TypeInfo(TArrayOfFloatDoubleRemotable),
            SpecimenPositions);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SetSpecimenIntervals(
    const SpecimenIntervals: TArrayOfFloatDoubleRemotable;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetSpecimenIntervals', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('SpecimenIntervals', TypeInfo(TArrayOfFloatDoubleRemotable),
            SpecimenIntervals);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.AddPointToBackground(const XValue: double;
    const YValue: double; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('AddPointToBackground', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('XValue', TypeInfo(double), XValue);
        locSerializer.Put('YValue', TypeInfo(double), YValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.AddPointToSpecimenIntervals(const XValue: double;
    const YValue: double; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('AddPointToSpecimenIntervals', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('XValue', TypeInfo(double), XValue);
        locSerializer.Put('YValue', TypeInfo(double), YValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.AddPointToSpecimenPositions(const XValue: double;
    const YValue: double; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('AddPointToSpecimenPositions', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('XValue', TypeInfo(double), XValue);
        locSerializer.Put('YValue', TypeInfo(double), YValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetProfilePointsSet(const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetProfilePointsSet', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSelectedArea(const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSelectedArea', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetBackgroundPoints(const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetBackgroundPoints', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenPositions(const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenPositions', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenIntervals(const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenIntervals', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetCalcProfilePointsSet(
    const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetCalcProfilePointsSet', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetDeltaProfilePointsSet(
    const ProblemID: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetDeltaProfilePointsSet', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.SetCurveThresh(const CurveThresh: double;
    const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetCurveThresh', GetTarget(), (Self as ICallContext));
        locSerializer.Put('CurveThresh', TypeInfo(double), CurveThresh);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetMaxRFactor(const ProblemID: integer): double;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetMaxRFactor', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(double), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.SetMaxRFactor(const MaxRFactor: double;
    const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetMaxRFactor', GetTarget(), (Self as ICallContext));
        locSerializer.Put('MaxRFactor', TypeInfo(double), MaxRFactor);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetBackFactor(const ProblemID: integer): double;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetBackFactor', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(double), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.SetBackFactor(const BackFactor: double;
    const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetBackFactor', GetTarget(), (Self as ICallContext));
        locSerializer.Put('BackFactor', TypeInfo(double), BackFactor);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetCurveType(const ProblemID: integer): TCurveTypeId;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetCurveType', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(integer), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.SetCurveType(const CurveTypeId: TCurveTypeId;
    const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetCurveType', GetTarget(), (Self as ICallContext));
        locSerializer.Put('CurveTypeId', TypeInfo(integer), CurveTypeId);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetWaveLength(const ProblemID: integer): double;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetWaveLength', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(double), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.SetWaveLength(const WaveLength: double;
    const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetWaveLength', GetTarget(), (Self as ICallContext));
        locSerializer.Put('WaveLength', TypeInfo(double), WaveLength);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetCurveThresh(const ProblemID: integer): double;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetCurveThresh', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(double), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetState(const ProblemID: integer): integer;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetState', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(integer), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.ReplacePointInProfile(const PrevXValue: double;
    const PrevYValue: double; const NewXValue: double; const NewYValue: double;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('ReplacePointInProfile', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('PrevXValue', TypeInfo(double), PrevXValue);
        locSerializer.Put('PrevYValue', TypeInfo(double), PrevYValue);
        locSerializer.Put('NewXValue', TypeInfo(double), NewXValue);
        locSerializer.Put('NewYValue', TypeInfo(double), NewYValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.ReplacePointInBackground(const PrevXValue: double;
    const PrevYValue: double; const NewXValue: double; const NewYValue: double;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('ReplacePointInBackground', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('PrevXValue', TypeInfo(double), PrevXValue);
        locSerializer.Put('PrevYValue', TypeInfo(double), PrevYValue);
        locSerializer.Put('NewXValue', TypeInfo(double), NewXValue);
        locSerializer.Put('NewYValue', TypeInfo(double), NewYValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.ReplacePointInSpecimenIntervals(const PrevXValue: double;
    const PrevYValue: double; const NewXValue: double; const NewYValue: double;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('ReplacePointInSpecimenIntervals', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('PrevXValue', TypeInfo(double), PrevXValue);
        locSerializer.Put('PrevYValue', TypeInfo(double), PrevYValue);
        locSerializer.Put('NewXValue', TypeInfo(double), NewXValue);
        locSerializer.Put('NewYValue', TypeInfo(double), NewYValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.ReplacePointInSpecimenPositions(const PrevXValue: double;
    const PrevYValue: double; const NewXValue: double; const NewYValue: double;
    const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('ReplacePointInSpecimenPositions', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('PrevXValue', TypeInfo(double), PrevXValue);
        locSerializer.Put('PrevYValue', TypeInfo(double), PrevYValue);
        locSerializer.Put('NewXValue', TypeInfo(double), NewXValue);
        locSerializer.Put('NewYValue', TypeInfo(double), NewYValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.CreateProblem(): integer;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('CreateProblem', GetTarget(), (Self as ICallContext));
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        strPrmName := 'result';
        locSerializer.Get(TypeInfo(integer), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

procedure TFitServer_Proxy.DiscardProblem(const ProblemID: integer);
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('DiscardProblem', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenCount(const ProblemID: integer): TIntResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenCount', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TIntResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenPoints(const SpecIndex: integer;
    const ProblemID: integer): TNamedPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenPoints', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('SpecIndex', TypeInfo(integer), SpecIndex);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TNamedPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenParameterCount(const ProblemID: integer;
    const SpecIndex: integer): TIntResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenParameterCount', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.Put('SpecIndex', TypeInfo(integer), SpecIndex);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TIntResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSpecimenParameter(const ProblemID: integer;
    const SpecIndex: integer; const ParamIndex: integer): TSpecParamResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSpecimenParameter', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.Put('SpecIndex', TypeInfo(integer), SpecIndex);
        locSerializer.Put('ParamIndex', TypeInfo(integer), ParamIndex);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TSpecParamResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.AddPointToData(const XValue: double;
    const YValue: double; const ProblemID: integer): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('AddPointToData', GetTarget(), (Self as ICallContext));
        locSerializer.Put('XValue', TypeInfo(double), XValue);
        locSerializer.Put('YValue', TypeInfo(double), YValue);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetGraph(const Width: integer; const Height: integer;
    const ProblemID: integer): TPictureResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetGraph', GetTarget(), (Self as ICallContext));
        locSerializer.Put('Width', TypeInfo(integer), Width);
        locSerializer.Put('Height', TypeInfo(integer), Height);
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPictureResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetProfileChunk(const ProblemID: integer;
    const ChunkNum: integer): TPointsResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetProfileChunk', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.Put('ChunkNum', TypeInfo(integer), ChunkNum);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TPointsResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetProfileChunkCount(const ProblemID: integer): TIntResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetProfileChunkCount', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TIntResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.SetSpecimenParameter(const ProblemID: integer;
    const SpecIndex: integer; const ParamIndex: integer;
    const Value: double): TResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('SetSpecimenParameter', GetTarget(),
            (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.Put('SpecIndex', TypeInfo(integer), SpecIndex);
        locSerializer.Put('ParamIndex', TypeInfo(integer), ParamIndex);
        locSerializer.Put('Value', TypeInfo(double), Value);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetCalcTimeStr(const ProblemID: integer): TStringResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetCalcTimeStr', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TStringResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetRFactorStr(const ProblemID: integer): TStringResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetRFactorStr', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TStringResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetAbsRFactorStr(const ProblemID: integer): TStringResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetAbsRFactorStr', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TStringResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;

function TFitServer_Proxy.GetSqrRFactorStr(const ProblemID: integer): TStringResult;
var
    locSerializer: IFormatterClient;
    strPrmName:    string;
begin
    locSerializer := GetSerializer();
    try
        locSerializer.BeginCall('GetSqrRFactorStr', GetTarget(), (Self as ICallContext));
        locSerializer.Put('ProblemID', TypeInfo(integer), ProblemID);
        locSerializer.EndCall();

        MakeCall();

        locSerializer.BeginCallRead((Self as ICallContext));
        TObject(Result) := nil;
        strPrmName      := 'Result';
        locSerializer.Get(TypeInfo(TStringResult), strPrmName, Result);

    finally
        locSerializer.Clear();
    end;
end;


initialization
  {$i ..\fit_server.wst}

  {$IF DECLARED(Register_fit_server_ServiceMetadata)}
    Register_fit_server_ServiceMetadata();
  {$IFEND}
end.
