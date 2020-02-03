{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definitions of generic container for point set of all calcuated curves.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn: https://www.linkedin.com/in/dmitry-morozov-79490a59/
Facebook: https://www.facebook.com/dmitry.v.morozov)
}
unit curve_points_set;

{$IF NOT DEFINED(FPC)}
{$DEFINE _WINDOWS}
{$ELSEIF DEFINED(WINDOWS)}
{$DEFINE _WINDOWS}
{$ENDIF}

interface

uses
    Classes, SysUtils, self_copied_component, points_set,
    title_points_set, amplitude_curve_parameter, sigma_curve_parameter,
    position_curve_parameter, persistent_curve_parameter_container,
    special_curve_parameter;

type
    { Generic type of instance parameter container. }
    Curve_parameters = class(TSelfCopiedComponent)
    protected
        FParams: TCollection;

        function GetParameter(Index: LongInt): TSpecialCurveParameter;
        procedure SetParameter(Index: LongInt; Parameter: TSpecialCurveParameter);

        function GetCount: LongInt;

    public
        { Initial parameters hash. Should be used for copying optimization. }
        SavedInitHash: Cardinal;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure CopyParameters(const Dest: TObject); override;
        function GetParamValueByName(ParamName: string): double;
        procedure SetParamValueByName(ParamName: string; AValue: double);

        property Parameters[Index: LongInt]: TSpecialCurveParameter
            read GetParameter write SetParameter;

        property Count: LongInt read GetCount;

    published
        { Published for XML-serialization. }
        property Params: TCollection read FParams write FParams;
    end;

    { Generic container for point set of all calcuated curves. }
    TCurvePointsSet = class(TTitlePointsSet)
    protected
        { List of all curve parameters. }
        FParams: Curve_parameters;
        { List of variable parameters. }
        FVariableParameters: TList;
        { Set of variable parameters common for all curve types (meaning could
          be different in particular cases).
          Parameters with predefined semantics have constraints, which
          can be associated with curve points. Attributes store pointers
          to parameters with predefined semantics. Parameters are created
          in descendant constructors. }
        AmplitudeP: TAmplitudeCurveParameter;
        PositionP: TPositionCurveParameter;
        SigmaP: TSigmaCurveParameter;
        { It is used in TUserPointsSet. TODO: move it to TUserPointsSet. }
        ArgP: TSpecialCurveParameter;

        { Returns variable parameter by through index. }
        function GetParam(Index: LongInt): Double; virtual;
        { Sets value of variable parameter. }
        procedure SetParam(Index: LongInt; Value: Double); virtual;
        { Returns total number of variable parameters. }
        function GetParamCount: LongInt;
        
        { Returns value of parameter with given name. }
        function GetParamByName(Name: string): Double; virtual;
        procedure SetParamByName(Name: string; Value: Double); virtual;
        
        { Initializes pointers to parameters with predefined semantics. }
        procedure SetSpecParamPtr(P: TSpecialCurveParameter); virtual;
        { Initializes indexes of variable parameters with predefined semantics. }
        procedure SetSpecParamVarIndex(
            P: TSpecialCurveParameter; Index: LongInt); virtual;

    protected
        Modified: Boolean;

        procedure AddParameter(Parameter: TSpecialCurveParameter);
        { Performs recalculation of all profile points. }
        procedure DoCalc(const Intervals: TPointsSet); virtual; abstract;
        { Multiplies profile points by given factor. }
        procedure ScaleCurve(const Factor: Double);
        { Performs intialization of variable list parameters and 
          set up of AmplIndex, PosIndex, SigmaIndex. }
        procedure InitListOfVariableParameters;
        
        { These functions don't perform profile recalculation and
          are used for initialization purposes (when Modified is set up). }
        
        procedure Setx0(Value: Double);
        procedure SetA(Value: Double);
        procedure SetSigma(Value: Double);
        function Getx0: Double;
        function GetA: Double;
        function GetSigma: Double;

    public
        { Indexes of attributes with predefined semantics. Indexes are
          filled only in the case if parameters with required names are
          variable and are indexes in the List. It's necessary in accessing
          to variable parameters via Param[Index] it would be possible to
          set up parameters with predefined semantics in according to 
          restrictions. Must be public to assign optimization step. }
        { Curve amplitude. }
        AmplIndex: LongInt;
        { Curve position. }
        PosIndex: LongInt;
        { Curve width. }
        SigmaIndex: LongInt;

        { Boundaries for R-factor calculation. }
        MinX, MaxX: Double;
        { Flag designating that boundaries of R-factor calculation
          has been set up. If False R-factor is calculated for all 
          points of profile. }
        RangeDefined: Boolean;
        { Hash of initial parameter values. }
        InitHash: Cardinal;
        { Initial value of x0. It's used in some algorithms. }
        Initx0: Double;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure SetParameters(AParams: Curve_parameters);
        { Set of pairs of indexes of X-coordinates forming intervals in
          which functions should be calcuated (boundaries are included). 
          Equity to nil designates that functions should be calculated 
          for all points. Indexes instead of coordinates are used to 
          avoid searching. }
        procedure ReCalc(const Intervals: TPointsSet);
        { Temporarily stores values of variable parameters in internal memory area. }
        procedure StoreParams;
        { Restores values of variable parameters from temporary storage. }
        procedure RestoreParams;
        procedure CopyParameters(const Dest: TObject); override;

        { Designate initialization of attributes with predefined semantics. }
        
        function Hasx0: Boolean;
        function HasA: Boolean;
        function HasSigma: Boolean;

        { Provides access to variable parameters for optimizer. }
        property Param[index: LongInt]: Double read GetParam write SetParam;
        property ParamCount: LongInt read GetParamCount;
        { Provides access to all parameters by name. }
        property ParamByName[Name: string]: Double read GetParamByName write SetParamByName;
        { Returns object containing all parameters. }
        property Params: Curve_parameters read FParams;
        { Properties provide access to attributes having predefined semantics for special algorithms.
          Use methods HasX before to check existense of such attributes. }

        { Variation of the parameter x0 is limited by two adjacent points. }
        property x0: Double read Getx0 write Setx0;
        property A: Double read GetA write SetA;
        property Sigma: Double read GetSigma write SetSigma;
    end;

implementation

{=========================== TCurvePointsSet ==================================}

constructor TCurvePointsSet.Create(AOwner: TComponent);
begin
    inherited;
    FParams := Curve_parameters.Create(nil);
    Modified := True;
    AmplIndex := -1;
    PosIndex := -1;
    SigmaIndex := -1;
end;

destructor TCurvePointsSet.Destroy;
begin
    FVariableParameters.Free;
    FParams.Free;
    inherited;
end;

procedure TCurvePointsSet.ReCalc(const Intervals: TPointsSet);
begin
    if Modified then
    begin
        DoCalc(Intervals);
        Modified := False;
    end;
end;

procedure TCurvePointsSet.CopyParameters(const Dest: TObject);
begin
    inherited;
    TCurvePointsSet(Dest).MinX := MinX;
    TCurvePointsSet(Dest).MaxX := MaxX;
    TCurvePointsSet(Dest).RangeDefined := RangeDefined;
    TCurvePointsSet(Dest).SetParameters(Curve_parameters(FParams.GetCopy));
    TCurvePointsSet(Dest).InitHash := InitHash;
end;

function TCurvePointsSet.GetParam(Index: LongInt): Double;
var P: TSpecialCurveParameter;
begin
    Assert(index < GetParamCount);
    
    if Index = PosIndex then Result := x0
    else
    if Index = AmplIndex then Result := A
    else
    if Index = SigmaIndex then Result := Sigma
    else
    begin
        P := TSpecialCurveParameter(FVariableParameters.Items[index]);
        Result := P.Value;
    end;
end;

procedure TCurvePointsSet.SetParam(Index: LongInt; Value: Double);
var P: TSpecialCurveParameter;
begin
    Assert((Index < GetParamCount) and (Index >= 0));
    Modified := True;

    if Index = PosIndex then x0 := Value
    else
    if Index = AmplIndex then A := Value
    else
    if Index = SigmaIndex then Sigma := Value
    else
    begin
        P := TSpecialCurveParameter(FVariableParameters.Items[Index]);
        P.Value := Value;
    end;
end;

function TCurvePointsSet.GetParamByName(Name: string): Double;
var i: LongInt;
    P: TSpecialCurveParameter;
begin
    //  snachala proveryayutsya special'nye imena
    if UpperCase(Name) = 'X0' then
    begin
        Result := x0;
        Exit;
    end
    else
    if UpperCase(Name) = 'A' then
    begin
        Result := A;
        Exit;
    end
    else
    if UpperCase(Name) = 'SIGMA' then
    begin
        Result := Sigma;
        Exit;
    end
    else
    begin
        for i := 0 to FParams.Count - 1 do
        begin
            P := FParams.Parameters[i];
            if UpperCase(P.Name) = UpperCase(Name) then
            begin
                Result := P.Value;
                Exit;
            end;
        end;
    end;
    Assert(False);
end;

procedure TCurvePointsSet.SetParamByName(Name: string; Value: Double);
var i: LongInt;
    P: TSpecialCurveParameter;
{$IFDEF WRITE_PARAMS_LOG}
    LogStr: string;
{$ENDIF}
begin
    Modified := True;
    //  snachala proveryayutsya special'nye imena
    if UpperCase(Name) = 'X0' then
    begin
{$IFDEF WRITE_PARAMS_LOG}
        LogStr := IntToStr(LongInt(Self)) + ' SetParamByName(x0): Value = ' +
            FloatToStr(Value);
        WriteLog(LogStr, Notification_);
{$ENDIF}
        x0 := Value;
        Exit;
    end
    else
    if UpperCase(Name) = 'A' then
    begin
{$IFDEF WRITE_PARAMS_LOG}
        LogStr := IntToStr(LongInt(Self)) + ' SetParamByName(A): Value = ' +
            FloatToStr(Value);
        WriteLog(LogStr, Notification_);
{$ENDIF}
        A := Value;
        Exit;
    end
    else
    if UpperCase(Name) = 'SIGMA' then
    begin
{$IFDEF WRITE_PARAMS_LOG}
        LogStr := IntToStr(LongInt(Self)) + ' SetParamByName(Sigma): Value = ' +
            FloatToStr(Value);
        WriteLog(LogStr, Notification_);
{$ENDIF}
        Sigma := Value;
        Exit;
    end
    else
    begin
        for i := 0 to FParams.Count - 1 do
        begin
            P := FParams.Parameters[i];
            if UpperCase(P.Name) = UpperCase(Name) then
            begin
{$IFDEF WRITE_PARAMS_LOG}
                LogStr := IntToStr(LongInt(Self)) +
                    ' SetParamByName('+ Name +'): Value = ' + FloatToStr(Value);
                WriteLog(LogStr, Notification_);
{$ENDIF}
                P.Value := Value;
                Exit;
            end;
        end;
    end;
    Assert(False);
end;

function TCurvePointsSet.GetParamCount: LongInt;
begin
    Result := FVariableParameters.Count;
end;

procedure TCurvePointsSet.Setx0(Value: Double);
begin
    Assert(Assigned(PositionP));
    Modified := True;
    PositionP.Value := Value;
end;

procedure TCurvePointsSet.SetA(Value: Double);
begin
    Assert(Assigned(AmplitudeP));
    Modified := True;
    AmplitudeP.Value := Value;
end;

procedure TCurvePointsSet.SetSigma(Value: Double);
begin
    Assert(Assigned(SigmaP));
    Modified := True;
    SigmaP.Value := Value;
end;

function TCurvePointsSet.Hasx0: Boolean;
begin
    Result := Assigned(PositionP);
end;

function TCurvePointsSet.HasA: Boolean;
begin
    Result := Assigned(AmplitudeP);
end;

function TCurvePointsSet.HasSigma: Boolean;
begin
    if Assigned(SigmaP) then Result := True else Result := False;
end;

function TCurvePointsSet.Getx0: Double;
begin
    Assert(Assigned(PositionP));
    Result := PositionP.Value;
end;

function TCurvePointsSet.GetA: Double;
begin
    Assert(Assigned(AmplitudeP));
    Result := AmplitudeP.Value;
end;

function TCurvePointsSet.GetSigma: Double;
begin
    Assert(Assigned(SigmaP));
    Result := SigmaP.Value;
end;

procedure TCurvePointsSet.ScaleCurve(const Factor: Double);
var i: LongInt;
begin
    for i := 0 to PointsCount - 1 do
        Points[i][2] := Points[i][2] * Factor;
end;

procedure TCurvePointsSet.InitListOfVariableParameters;
var i, Index: LongInt;
    P: TSpecialCurveParameter;
begin
    Assert(Assigned(FParams));

    FVariableParameters.Free;
    FVariableParameters := TList.Create;

    for i := 0 to FParams.Count - 1 do
    begin
        P := FParams.Parameters[i];

        if (P.Type_ = Variable) or
           (P.Type_ = VariablePosition) then
        begin
            //  zdes' tol'ko var'iruemye
            Index := FVariableParameters.Add(P);
            //  opredelyayutsya indeksy parametrov s
            //  predopredelennoy semantikoy v spiske
            //  var'iruemyh parametrov
            SetSpecParamVarIndex(P, Index);
        end;
        if P.Type_ = Argument then ArgP := P;

        //  ustanavlivayutsya ukazateli na parametry
        //  s predopredelennoy semantikoy
        SetSpecParamPtr(P);
    end;
end;

//  ustanavlivaet ukazateli na parametry s predopredelennoy semantikoy
procedure TCurvePointsSet.SetSpecParamPtr(P: TSpecialCurveParameter);
begin
    Assert(Assigned(P));
    if UpperCase(P.Name) = 'SIGMA' then SigmaP := TSigmaCurveParameter(P);
    if UpperCase(P.Name) = 'A' then AmplitudeP := TAmplitudeCurveParameter(P);
    if (P.Type_ = VariablePosition) or
       (P.Type_ = InvariablePosition) then PositionP := TPositionCurveParameter(P);
end;
//  ustanavlivaet indeksy var'iruemyh parametrov s predopredelennoy
//  semantikoy
procedure TCurvePointsSet.SetSpecParamVarIndex(
    P: TSpecialCurveParameter; Index: LongInt);
begin
    Assert(Assigned(P));
    if UpperCase(P.Name) = 'SIGMA' then SigmaIndex := Index;
    if UpperCase(P.Name) = 'A' then AmplIndex := Index;
    if P.Type_ = VariablePosition then PosIndex := Index;
end;

procedure TCurvePointsSet.StoreParams;
var i: LongInt;
    P: TSpecialCurveParameter;
begin
    Assert(Assigned(FParams));

    for i := 0 to FParams.Count - 1 do
    begin
        P := FParams.Parameters[i];
        P.SavedValue := P.Value;
    end;
end;

procedure TCurvePointsSet.RestoreParams;
var i: LongInt;
    P: TSpecialCurveParameter;
begin
    Assert(Assigned(FParams));

    for i := 0 to FParams.Count - 1 do
    begin
        P := FParams.Parameters[i];
        P.Value := P.SavedValue;
    end;
    Modified := True;
end;

procedure TCurvePointsSet.SetParameters(AParams: Curve_parameters);
begin
    Assert(Assigned(AParams));

    FParams.Free; FParams := AParams;
    InitListOfVariableParameters;
end;

procedure TCurvePointsSet.AddParameter(Parameter: TSpecialCurveParameter);
var
    Container: TPersistentCurveParameterContainer;
begin
    Container := TPersistentCurveParameterContainer(FParams.Params.Add);
    try
        Container.Parameter := Parameter;
    except
        FParams.Params.Delete(Container.ID);
        Container.Free;
        raise;
    end;
end;

{========================== Curve_parameters ==================================}

constructor Curve_parameters.Create;
var Parameter: TSpecialCurveParameter;
    Container: TPersistentCurveParameterContainer;
begin
    inherited;
    FParams := TCollection.Create(TPersistentCurveParameterContainer);
    { Collection should contain at least on item, otherwise is written
      incorrectly. TODO: check it. }
    Parameter := TSpecialCurveParameter.Create;
    Parameter.Name := 'x';
    Parameter.Type_ := Argument;
    Parameter.Value := 0;

    Container := TPersistentCurveParameterContainer(FParams.Add);
    Container.Parameter := Parameter;
end;

destructor Curve_parameters.Destroy;
begin
    FParams.Free;
    inherited;
end;

procedure Curve_parameters.CopyParameters(const Dest: TObject);
var i: LongInt;
    Parameter, NewParameter: TSpecialCurveParameter;
    NewContainer: TPersistentCurveParameterContainer;
begin
    inherited;

    Curve_parameters(Dest).Params.Clear;

    for i := 0 to Count - 1 do
    begin
        Parameter := Parameters[i];

        NewParameter := TSpecialCurveParameter.Create;
        Parameter.CopyTo(NewParameter);

        try
            NewContainer :=
                TPersistentCurveParameterContainer(Curve_parameters(Dest).Params.Add);
        except
            NewParameter.Free;
            raise;
        end;
        NewContainer.Parameter := NewParameter;
    end;
    Curve_parameters(Dest).SavedInitHash := SavedInitHash;
end;

function Curve_parameters.GetParamValueByName(ParamName: string): double;
var i: Integer;
    P: TSpecialCurveParameter;
begin
    for i := 0 to Count - 1 do
    begin
        P := Parameters[i];
        if P.Name = ParamName then
        begin
            Result := P.Value;
            break;
        end;
    end;
end;

procedure Curve_parameters.SetParamValueByName(ParamName: string; AValue: double);
var i: Integer;
    P: TSpecialCurveParameter;
begin
    for i := 0 to Count - 1 do
    begin
        P := Parameters[i];
        if P.Name = ParamName then
        begin
            P.Value := AValue;
            break;
        end;
    end;
end;

function Curve_parameters.GetParameter(Index: LongInt): TSpecialCurveParameter;
begin
    Assert(Assigned(FParams));
    Result := TPersistentCurveParameterContainer(FParams.Items[Index]).Parameter;
end;

procedure Curve_parameters.SetParameter(Index: LongInt; Parameter: TSpecialCurveParameter);
begin
    Assert(Assigned(FParams));
    TPersistentCurveParameterContainer(FParams.Items[Index]).Parameter := Parameter;
end;

function Curve_parameters.GetCount: LongInt;
begin
    Assert(Assigned(FParams));
    Result := FParams.Count;
end;

begin
end.
