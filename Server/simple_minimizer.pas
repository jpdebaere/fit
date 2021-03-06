{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definitions of classes implementing optimization algorithms.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit simple_minimizer;

interface

uses int_minimizer, SysUtils;

type
    { Implements simple downhill simplex algorithm. }
    TSimpleMinimizer = class(TMinimizer)
    public
        procedure Minimize(var ErrorCode: longint); override;
    end;

    { Implements simple downhill simplex algorithm having different steps for
      every parameter. }
    TSimpleMinimizer2 = class(TMinimizer)
    public
        { Divides all steps by 2. }
        FDivideVariationStepBy2: procedure of object;
        { Returns flag terminating calculation. }
        FEndOfCalculation: function: boolean of object;
        procedure Minimize(var ErrorCode: longint); override;
    end;

    { Implements simple downhill simplex algorithm able to increase step size.
      Currently this variant is used. }
    TSimpleMinimizer3 = class(TMinimizer)
    public
        FMultiplyVariationStep: procedure(Factor: double) of object;
        { Returns flag terminating calculation. }
        FEndOfCalculation: function: boolean of object;
        procedure Minimize(var ErrorCode: longint); override;
    end;

procedure Register;

implementation

procedure Register;
begin
    //RegisterComponents('Fit',[TSimpleMinimizer]);
    //RegisterComponents('Fit',[TSimpleMinimizer2]);
    //RegisterComponents('Fir',[TSimpleMinimizer3]);
end;

{============================== TSimpleMinimizer ==============================}
procedure TSimpleMinimizer.Minimize(var ErrorCode: longint);
var
    Step:      double;
    SaveParam: double;
    MinimizeValue, MinimizeValue2: double;
    MinIndex:  longint;
    TotalMinimum: double;
begin
    //  proverka prisoedineniya interfeysnyh funktsiy
    ErrorCode := IsReady;
    if ErrorCode <> MIN_NO_ERRORS then
        Exit;

    Step := OnGetVariationStep;
    while (Step >= 0.001{!!!}) and (not Terminated) do
    begin
        OnSetFirstParam;
        Step := OnGetVariationStep;
        OnComputeFunc;
        TotalMinimum := OnGetFunc;
        while (not OnEndOfCycle) and (not Terminated) do
        begin
            OnComputeFunc;
            SaveParam      := OnGetParam;
            FCurrentMinimum := OnGetFunc;

            OnSetParam(SaveParam + Step);
            OnComputeFunc;
            MinimizeValue := OnGetFunc;

            OnSetParam(SaveParam - Step);
            OnComputeFunc;
            MinimizeValue2 := OnGetFunc;

            OnSetParam(SaveParam);
            MinIndex := 0;

            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 0;
            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                MinIndex := 2;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 1;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                if MinimizeValue <= MinimizeValue2 then
                    MinIndex := 1
                else
                    MinIndex := 2;

            case MinIndex of
                1: OnSetParam(SaveParam + Step);
                2: OnSetParam(SaveParam - Step);
            end;

            OnComputeFunc;

            if Assigned(OnShowCurMin) then
                if OnGetFunc < FCurrentMinimum then
                begin
                    FCurrentMinimum := OnGetFunc;
                    OnShowCurMin;
                end;
            OnSetNextParam;
        end;
        if OnGetFunc >= TotalMinimum then
            OnSetVariationStep(Step / 2);
    end;{while (Step > 1e-5) and (not Terminated) do...}
end;

{============================== TSimpleMinimizer2 =============================}
procedure TSimpleMinimizer2.Minimize(var ErrorCode: longint);
var
    Step:      double;
    SaveParam: double;
    MinimizeValue, MinimizeValue2: double;
    MinIndex:  longint;
    TotalMinimum: double;
    NewMinFound: boolean;
begin
    //  proverka prisoedineniya interfeysnyh funktsiy
    ErrorCode := IsReady;
    if ErrorCode <> MIN_NO_ERRORS then
        Exit;
    FCurrentMinimum := OnGetFunc;

    Assert(Assigned(FDivideVariationStepBy2));

    //  beskonechnyy tsikl optimizatsii
    while (not FEndOfCalculation) and (not Terminated) do
    begin
        OnSetFirstParam;
        TotalMinimum := FCurrentMinimum;
        //  tsikl optimizatsii po vsem parametram
        while (not OnEndOfCycle) and (not Terminated) do
        begin
            //  poluchenie shaga izmeneniya dlya ocherednogo parametra
            Step      := OnGetVariationStep;
            //  poluchenie znacheniya ocherednogo parametra
            SaveParam := OnGetParam;

            //  pervoe izmenenie parametra
            OnSetParam(SaveParam + Step);
            //  vychislenie novogo znacheniya funktsii
            OnComputeFunc;
            // poluchenie novogo znacheniya funktsii
            MinimizeValue := OnGetFunc;

            //  vtoroe izmenenie parametra
            OnSetParam(SaveParam - Step);
            //  vychislenie novogo znacheniya funktsii
            OnComputeFunc;
            //  poluchenie novogo znacheniya funktsii
            MinimizeValue2 := OnGetFunc;

            //  vosstanovlenie ishodnogo znacheniya parametra
            OnSetParam(SaveParam);
            MinIndex := 0;
            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 0;
            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                MinIndex := 2;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 1;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                if MinimizeValue <= MinimizeValue2 then
                    MinIndex := 1
                else
                    MinIndex := 2;

            NewMinFound := False;
            case MinIndex of
                1:
                begin
                    OnSetParam(SaveParam + Step);
                    NewMinFound := True;
                end;
                2:
                begin
                    OnSetParam(SaveParam - Step);
                    NewMinFound := True;
                end;
            end;

            if NewMinFound then
            begin
                OnComputeFunc; //  pereschet nuzhno delat', chtoby dopolnitel'nye dannye
                //  imeli znacheniya, sootvetstvuyuschie minimal'nomu znacheniyu
                //  funktsii
                FCurrentMinimum := OnGetFunc;
                if Assigned(OnShowCurMin) then
                    OnShowCurMin;
                //OutputDebugString(PChar(FloatToStr(FCurrentMinimum) + Chr(10) + Chr(13)));
            end;
            OnSetNextParam;
        end;{while (not OnEndOfCycle) and (not Terminated) do...}
        if (TotalMinimum <> 0) and (Abs(FCurrentMinimum - TotalMinimum) /
            TotalMinimum < 1e-5) then
            FDivideVariationStepBy2;
    end;{while (not FEndOfCalculation) and (not Terminated) do...}
end;

{============================== TSimpleMinimizer3 =============================}
procedure TSimpleMinimizer3.Minimize(var ErrorCode: longint);
var
    Step:      double;
    SaveParam: double;
    MinimizeValue, MinimizeValue2: double;
    MinIndex:  longint;
    TotalMinimum: double;
    NewMinFound: boolean;
    DownCount: longint;
begin
    //  proverka prisoedineniya interfeysnyh funktsiy
    ErrorCode := IsReady;
    if ErrorCode <> MIN_NO_ERRORS then
        Exit;
    FCurrentMinimum := OnGetFunc;
    TotalMinimum   := FCurrentMinimum;
    DownCount      := 0;

    Assert(Assigned(FMultiplyVariationStep));

    //  beskonechnyy tsikl optimizatsii
    while (not FEndOfCalculation) and (not Terminated) do
    begin
        OnSetFirstParam;
        //  tsikl optimizatsii po vsem parametram
        while (not OnEndOfCycle) and (not Terminated) do
        begin
            //  poluchenie shaga izmeneniya dlya ocherednogo parametra
            Step      := OnGetVariationStep;
            //  poluchenie znacheniya ocherednogo parametra
            SaveParam := OnGetParam;

            //  pervoe izmenenie parametra
            OnSetParam(SaveParam + Step);
            //  vychislenie novogo znacheniya funktsii
            OnComputeFunc;
            // poluchenie novogo znacheniya funktsii
            MinimizeValue := OnGetFunc;

            //  vtoroe izmenenie parametra
            OnSetParam(SaveParam - Step);
            //  vychislenie novogo znacheniya funktsii
            OnComputeFunc;
            //  poluchenie novogo znacheniya funktsii
            MinimizeValue2 := OnGetFunc;

            //  vosstanovlenie ishodnogo znacheniya parametra
            OnSetParam(SaveParam);
            MinIndex := 0;
            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 0;
            if (MinimizeValue >= FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                MinIndex := 2;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 >= FCurrentMinimum) then
                MinIndex := 1;
            if (MinimizeValue < FCurrentMinimum) and
                (MinimizeValue2 < FCurrentMinimum) then
                if MinimizeValue <= MinimizeValue2 then
                    MinIndex := 1
                else
                    MinIndex := 2;

            NewMinFound := False;
            case MinIndex of
                1:
                begin
                    OnSetParam(SaveParam + Step);
                    NewMinFound := True;
                end;
                2:
                begin
                    OnSetParam(SaveParam - Step);
                    NewMinFound := True;
                end;
            end;

            if NewMinFound then
            begin
                OnComputeFunc;
                //  pereschet nuzhno delat', chtoby dopolnitel'nye dannye
                //  imeli znacheniya, sootvetstvuyuschie minimal'nomu znacheniyu
                //  funktsii
                FCurrentMinimum := OnGetFunc;
                if Assigned(OnShowCurMin) then
                    OnShowCurMin;
                //OutputDebugString(PChar(FloatToStr(FCurrentMinimum)));
            end;
            OnSetNextParam;
        end;{while (not OnEndOfCycle) and (not Terminated) do...}

        if (TotalMinimum <> 0) then
        begin
            //  FCurrentMinimum m. stat' bol'she, chem TotalMinimum posle
            //  uvelicheniya shaga
            if (FCurrentMinimum < TotalMinimum) and
                (Abs(FCurrentMinimum - TotalMinimum) / TotalMinimum >= 1e-5) then
            begin
                TotalMinimum := FCurrentMinimum;
                //  neskol'ko tsiklov idet vniz -
                //  shag uvelichivaetsya
                Inc(DownCount);
                if DownCount >= 10 then
                    FMultiplyVariationStep(1.01);
                //OutputDebugString(PChar('Parameter steps increased...'));
            end
            else
            begin
                //  za posledniy tsikl suschestvenno luchshiy
                //  minimum ne nayden - shag umen'shaetsya
                FMultiplyVariationStep(0.99);
                DownCount := 0;
                //OutputDebugString(PChar('Parameter steps decreased...'));
            end;
            if FCurrentMinimum < TotalMinimum then
                TotalMinimum := FCurrentMinimum;
        end
        else
            Break;
    end; {while (not FEndOfCalculation) and (not Terminated) do...}
end;

end.
