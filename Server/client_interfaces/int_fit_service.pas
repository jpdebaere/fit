{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains base interface of communication from client to server.)

@author(Dmitry Morozov dvmorozov@hotmail.com,
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794,
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit int_fit_service;

{$MODE Delphi}

interface

uses
    Classes, SysUtils, IntPointsSet, CommonTypes, PointsSet, TitlePointsSet,
    CurvePointsSet, MSCRDataClasses, SelfCopied;

type
    { Defines base interface of communication from client to server. }
    IFitService = interface
        function GetMaxRFactor: Double;
        procedure SetMaxRFactor(AMaxRFactor: Double);
        function GetBackFactor: Double;
        procedure SetBackFactor(ABackFactor: Double);
        function GetCurveThresh: Double;
        procedure SetCurveThresh(ACurveThresh: Double);
        function GetCurveType: TCurveTypeId;
        procedure SetCurveType(ACurveType: TCurveTypeId);
        function GetState: TFitServerState;
        procedure SetWaveLength(AWaveLength: Double);
        function GetWaveLength: Double;
        { All GetXXXX methods create and return A NEW OBJECT,
          responsibility to free it is put on calling code. }

        { Returns hint or error message received from the server. }
        function SetProfilePointsSet(APointsSet: TTitlePointsSet): string;
        function GetProfilePointsSet: TTitlePointsSet;
        function GetSelectedArea: TTitlePointsSet;

        { Returns hint or error message received from the server. }
        function SetBackgroundPointsSet(ABackgroundPoints: TTitlePointsSet): string;
        function GetBackgroundPoints: TTitlePointsSet;

        { Returns hint or error message received from the server. }
        function SetCurvePositions(ACurvePositions: TPointsSet): string;
        function GetCurvePositions: TTitlePointsSet;

        { Returns hint or error message received from the server. }
        function SetRFactorIntervals(ARFactorIntervals: TPointsSet): string;
        function GetRFactorIntervals: TTitlePointsSet;
    {$IFNDEF EXCLUDE_SOMETHING}
        function GetSpecialCurveParameters: Curve_parameters;
        procedure SetSpecialCurveParameters(
            ACurveExpr: string;
            { Nil means initialization. }
            CP: Curve_parameters
            );
    {$ENDIF}
        procedure AddPointToData(XValue, YValue: Double);
        procedure AddPointToBackground(XValue, YValue: Double);
        procedure AddPointToRFactorIntervals(XValue, YValue: Double);
        procedure AddPointToCurvePositions(XValue, YValue: Double);

        procedure ReplacePointInData(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInBackground(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInRFactorIntervals(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInCurvePositions(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);

        function GetSpecimenList: TMSCRSpecimenList;
        function GetSpecimenCount: LongInt;
        function GetSpecimenParameterCount(SpecIndex: LongInt): LongInt;
        procedure GetSpecimenParameter(SpecIndex: LongInt; ParamIndex: LongInt;
            var Name: string; var Value: Double; var Type_: LongInt);
        procedure SetSpecimenParameter(SpecIndex: LongInt; ParamIndex: LongInt;
            Value: Double);
        function GetCurvesList: TSelfCopiedCompList;

        function GetCalcProfilePointsSet: TTitlePointsSet;
        function GetDeltaProfilePointsSet: TTitlePointsSet;

        { Asynchronous (long) methods. }

        { Returns hint or error message received from the server. }
        function SmoothProfile: string;
        procedure SubtractAllBackground(Auto: Boolean);
        { Returns hint or error message received from the server. }
        function DoAllAutomatically: string;
        { Returns hint or error message received from the server. }
        function FindGausses: string;
    {$IFNDEF EXCLUDE_SOMETHING}
        { Returns hint or error message received from the server. }
        function FindGaussesAgain: string;
    {$ENDIF}
        { Returns hint or error message received from the server. }
        function FindGaussesSequentially: string;
        { Returns hint or error message received from the server. }
        function FindPeakBounds: string;
        { Returns hint or error message received from the server. }
        function FindBackPoints: string;
        { Returns hint or error message received from the server. }
        function FindPeakPositions: string;
    {$IF DEFINED(FIT) OR DEFINED(FITPRO)}
        { Returns hint or error message received from the server. }
        function AllPointsAsPeakPositions: string;
    {$ENDIF}
    {$IFDEF FITCGI}
        function GetGraph(
            const Width: LongInt; const Height: LongInt): TMemoryStream;
        function GetProfileChunk(const ChunkNum: LongInt): TTitlePointsSet;
        function GetProfileChunkCount: LongInt;
    {$ENDIF}
        { Control methods. }

        procedure StopAsyncOper;
        function AsyncOper: Boolean;
        function GetCalcTimeStr: string;
        function GetRFactorStr: string;
        function GetAbsRFactorStr: string;
        function GetSqrRFactorStr: string;

        { Synchronous methods. }
        { Returns hint or error message received from the server. }
        function SelectArea(StartPointIndex, StopPointIndex: LongInt): string;
        { Returns hint or error message received from the server. }
        function ReturnToTotalProfile: string;
        procedure CreateSpecimenList;
    end;
    
    IFitProblem = interface(IFitService)
        procedure CreateProblem;
        function GetProblemId: LongInt;
        procedure SetProblemId(AProblemId: LongInt);
        procedure DiscardProblem(AProblemId: LongInt);
    end;

implementation

end.
