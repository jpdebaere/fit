//      dvoynoy kosoy chertoy kommentiruyutsya zamechaniya, sohranyaemye vo
//      vseh versiyah ishodnika; figurnymi skobkami kommentiruyutsya zamechaniya,
//      sohranyaemye tol'ko v versii ishodnika dlya besplatnogo rasprostraneniya
{------------------------------------------------------------------------------}
{       Copyright (C) 1999-2007 D.Morozov (dvmorozov@mail.ru)                  }
{------------------------------------------------------------------------------}
//      modul' soderzhit klass, realizuyuschiy logiku servera
//      zdes' net nichego, chto svyazano s pol'zovatel'skim interfeysom;
//      obrabotka isklyucheniy i preobrazovanie ih v soobscheniya ponimaemye aktorom
//      dolzhna delat'sya v pogranichnyh ob'ektah; poetomu metody granichnyh
//      ob'ektov dolzhny nah-sya blizhe k vershine steka, poetomu potok prilozheniya
//      d. krutit'sya v metode granichnogo ob'ekta;
//      isklyucheniya delyatsya na dva tipa dlya togo, chtoby mozhno bylo otpravlyat'
//      klientu dva tipa soobscheniy
//      !!! Vozniknovenie EAssertionFailed na vyhode metoda d. ponimat'sya
//      kak nedopustimost' sostoyaniya dlya vyzova metoda, pri etom sostoyanie
//      servera menyat'sya ne dolzhno !!!
//      !!! Vozniknovenie lyubogo drugogo isklyucheniya d. interpretirovat'sya
//      kak fatal'naya oshibka, pri etom sostoyanie servera d. privodit'sya k
//      iznachal'nomu, kot. bylo posle zapuska !!!
//      !!! Inogda, kogda metod mozhet vypolnit' svoyu semantiku
//      EAssertionFailed mozhet pogloschat'sya vnutri metoda !!!
//      !!! Dlya signalizatsii o nedopustimom sostoyanii luchshe ispol'zovat'
//      ne EAssertionFailed, a isklyuchenie drugogo tipa, poskol'ku
//      EAssertionFailed m. vyzyvat'sya iz bibliotek, a v takom sluchae
//      nel'zya garantirovat' sohranenie sostoyaniya prgrammy !!!

unit FitServer;

//{$mode objfpc}{$H+}
{$MODE Delphi}

interface

uses Classes, DataLoader, SelfCheckedComponentList, SysUtils, MSCRDataClasses,
     Dialogs,
{$IFDEF FIT}
     // obratnaya svyaz' est' tol'ko v monolitnom prilozhenii
     FitServerProxy,
{$ENDIF}
     SelfCopied, MyExceptions, FitTask, SimpMath,
     MainCalcThread, CommonTypes;

type
    //  Pri variatsii parametrov gaussianov seychas var'iruetsya amplituda
    //  i polozhenie, shirina prinimaetsya dlya vseh odinakovoy.
    TRecreateServer = procedure of object;
    //  komponent, kot. realizuet vsyu logiku servera, razbivaet
    //  zadachu podgonki profilya na podzadachi podgonki uchastkov
    //  (predvaritel'no uchastki d.b. opredeleny vruchnuyu ili avtomaticheski);
    //  vse interfeysnye metody d. dopuskat' vozmozhnost' vyzova
    //  v proizvol'nom sostoyanii - eto ne dolzhno schitat'sya
    //  nedopustimoy situatsiey, no dolzhen vozvraschat'sya kod oshibki;
    
    //  pri reshenii zadach, vozlozhennyh na komponent znanie dliny
    //  volny ne trebuetsya, poetomu vse komponenty TNeutronPointsSet
    //  zameneny na TPointsSet; eto sootvetstvuet takzhe abstraktsii
    //  komponenta ot zadach neytronografii i perehodu k zadacham iz
    //  proizvol'noy oblasti, v kotoryh dannye imeyut vid profilya;
    //  !!! nel'zya prosto zamenit' TNeutronPoinstSet na TPointsSet,
    //  poskol'ku na storone servera vyzyvayutsya metody TFitViewer,
    //  kotorye trebuyut TTitlePointsSet; krome togo poka na storone
    //  servera risuyutsya grafiki sleduet ispol'zovat' TNeutronPointsSet,
    //  kotoryi podderzhivaet pereschet argumenta !!!
    
    //  !!! interfeysnye metody vozvraschayut priznak dopustimosti
    //  sostoyaniya dlya vypolneniya operatsii; ne stoit ispol'zovat'
    //  EAssertionFailed kak signal o nedopustimom sostoyanii, t.k.
    //  nel'zya garantirovat', chto eto isklyuchenie ne vozniknet v
    //  biblioteke, poetomu vozvrat vybrosom EUserException (ispol'zovanie
    //  isklyucheniya pozvolyaet peredavat' na verhniy uroven' soobschenie);
    //  takoe povedenie dopustimo tol'ko v klassah, kotorye vypolnyayut
    //  komandy pol'zovatelya, ostal'nye dolzhny v sluchae nedopustimogo
    //  sostoyaniya vybrasyvat' EAssertionFailed; granichnyy klass d.
    //  interpretirovat' takoe isklyuchenie kak fatal'n. oshibku, a
    //  vozvrat EUserException kak oshibku sostoyaniya !!!
    //  dannyy klass servera vypolnyaet vsyu rabotu v potoke vyzyvayuschego
    //  prilozheniya
    //  !!! d. hranit' vse neobhodimye dannye, v t.ch. vydelennuyu
    //  oblast', poskol'ku klient mozhet voobsche ne imet' vozm.
    //  hranit' dannye !!!
    TFitServer = class(TComponent)
    protected
{$IFDEF FIT}
        FFitProxy: TFitServerProxy;
{$ENDIF}
        FWaveLength: Double;  //??? ubrat'
        procedure SetWaveLength(AWaveLength: Double);

    protected
        FState: TFitServerState;
        //  sostoyanie, predshestvovavshee perehodu v AsyncOperation
        SavedState: TFitServerState;
        //  !!! sostoyanie ne dolzhno izmenyat'sya vnutri
        //  dopolnitel'nogo potoka, poskol'ku unichtozhaet ego !!!
        procedure SetState(AState: TFitServerState); virtual;

    protected
        FBackFactor: Double;
        //  dannye polnogo eksperimental'nogo profilya
        ExpProfile: TTitlePointsSet;
        //  krivaya, poluchaemaya summoy vseh summarnyh krivyh podgonyaemyh uchastkov
        //  dlya vychisleniya polnogo R-faktora po vsemu profilyu
        CalcProfile: TTitlePointsSet;
        //  raznost' eksp. i rasschit. profiley
        DeltaProfile: TTitlePointsSet;
        //  uchastok profilya, s kotorym pol'zovatel' rabotaet v dannyy moment
        SelectedArea: TTitlePointsSet;
        //  spisok tochek fona, ispol'zuemyy dlya perehoda
        //  m-u rezhimami ruchnogo i avtomaticheskogo vybora
        BackgroundPoints: TTitlePointsSet;
        //  pary tochek ogranichivayuschie diapazony rascheta R-Factor'a;
        //  !!! nikogda ne dolzhny byt' skryty, chtoby pol'zovatel'
        //  videl, v kakom rezhime schitaetsya R-Factor !!!
        RFactorIntervals: TTitlePointsSet;

        //  elementy v eti spiski d. dobavlyat'sya sinhronno
        //  ispol'zuetsya dlya hraneniya i peredachi klientu
        //  vseh ekzemplyarov patternov sobrannyh iz zadach
        CurvesList: TSelfCopiedCompList;
        //  tochki, v kotoryh raspolagayutsya raschetnye krivye;
        //  ispol'zuyutsya tol'ko x-koordinaty tochek
        CurvePositions: TTitlePointsSet;
        //  rezul'tiruyuschiy nabor parametrov ekzemplyarov patternov
        //  ??? izmenit' tip i udalit' SetWaveLength
        SpecimenList: TMSCRSpecimenList;
        
        //  v zavisimosti ot etogo priznaka v dal'neyshih operatsiyah
        //  ispol'zuyutsya libo dannye vybrannoy oblasti, libo dannye
        //  polnogo profilya
        FSelectedAreaMode: Boolean;
        TaskList: TSelfCheckedComponentList;   //  po-umolchaniyu spisok aktivnyy
        //  parametry pol'zovatel'skoy krivoy;
        //  ob'ekt sozdaetsya serverom; nuzhen dlya obespecheniya
        //  vozmozhnosti redaktirovaniya parametrov v kliente
        Params: Curve_parameters;
        //  vyrazhenie dlya pol'zovatel'skoy krivoy
        FCurveExpr: string;
        //  peremennye podderzhivaet vozmozhnost' chteniya ustanovlennogo znacheniya
        FMaxRFactor: Double;
        procedure SetMaxRFactor(AMaxRFactor: Double);

    protected
        FCurveThresh: Double;
        procedure SetCurveThresh(ACurveThresh: Double);

    protected
        FCurveType: TCurveType;
        procedure SetCurveType(ACurveType: TCurveType);

    protected
        FitDone: Boolean;           //  ust. v True, posle pervogo zaversheniya
                                    //  rascheta
        //  tekuschee summarnoe znachenie R-faktora po vsem podzadacham
        CurrentMinimum: Double;
        //  nachal'nyy moment vremeni zapuska dlitel'noy operatsii
        StartTime: TDateTime;

        //  vyzyvaetsya dlya dobavleniya novoy tochki k zadannomu naboru tochek
        //  !!! povtornyy vyzov dlya dannyh koordinat udalyaet tochku iz spiska;
        //  pri etom spisok zamenyaetsya na novyy !!!
        procedure AddPoint(var Points: TTitlePointsSet; XValue, YValue: Double);

        //  priznak togo, chto tochki privyazki byli naznacheny
        //  avtomaticheski tak kak eto delaetsya pri polnost'yu
        //  avtomaticheskoy obrabotke - t.e. v kazhdoy tochke
        //  otlichnoy ot fona
    protected
        SpecPosFoundForAuto: Boolean;
        DoneDisabled: Boolean;
        //  vyzovy etih metodov vypolnyayutsya v osnovnom potoke prilozheniya
        procedure DoneProc; virtual;
        //  ============== metody, ispol'zuemye optimizatorom ==================
        //  vyzyvaetsya algoritmom optimizatsii dlya vyvoda
        //  informatsii pri dostizhenii ocherednogo minimuma
        procedure ShowCurMin; virtual;

        //  ============ algoritmy - metody, vyzyvaemye asinhronno =============
        //  ischet granitsy rascheta R-faktora na osnove dannyh,
        //  poluchennyh iz FindPeaksInternal
        procedure FindPeakBoundsAlg;
        procedure FindPeakBoundsDoneProcActual;
        //  ischet tochki fona
        procedure FindBackPointsAlg;
        procedure FindBackPointsDoneProcActual;
        //  ischet polozheniya pikov (tochek dlya raspolozheniya krivyh)
        procedure FindPeakPositionsAlg;
        //  выбор всех точек в качестве позиций кривых
        procedure AllPointsAsPeakPositionsAlg;
        procedure FindPeakPositionsDoneProcActual;

        //  ============= perehodniki k sootvet. metodam TFitTask ==============
        procedure FindGaussesSequentiallyAlg; virtual;
        procedure FindGaussesAlg; virtual;
        procedure FindGaussesAgainAlg; virtual;
        procedure DoAllAutomaticallyAlg;

        //  ============== metody nizkogo urovnya dlya algoritmov ================
        procedure Smoothing(ANeutronPointsSet: TPointsSet);
        //  lineyno vychitaet fon na zadannom uchastke nekotorogo nabora tochek
        procedure SubtractLinearly(Data: TPointsSet;
            StartIndex: LongInt; EndIndex: LongInt);
        //  ischet opornye tochki dlya lineynogo otsecheniya fona;
        //  !!! tochki ne uporyadocheny po X !!!
        function FindBackgroundPoints(Data: TPointsSet): TPointsSet;
        //  integriruet krivuyu s zadannymi predelami
        //  i dobavlyaet znacheniya v spisok rezul'tatov
        procedure AddSpecimenToList(Points: TCurvePointsSet;
            StartPointIndex,            //  indeksy nach. i kon. tochek, ot nih
            StopPointIndex: LongInt     //  zavisyat granitsy pika v spiske
                                        //  rezul'tatov
            );
        //  tochki pikov otdelyaet ot tochek fona i pomeschaet v rezul'tat
        function FindPeaksInternal: TTitlePointsSet;
        //  zapolnyaet spisok polozheniy pikov dlya avtomaticheskogo poiska
        procedure FindPeakPositionsForAutoAlg;
        function Integrate(Points: TPointsSet;
            StartPointIndex, StopPointIndex: LongInt): Double;
        function IntegrateAll(Points: TPointsSet): Double;
        //  lineyno vychitaet fon v SelectedArea i obnovlyaet SelectedArea
        //procedure SubtractBackground;
        //  !!! vychislyaet faktor rashodimosti CalcProfile i SelectedArea
        //  summirovaniem po vsem podzadacham !!!
        function GetRFactor: Double;
        function GetAbsRFactor: Double;
        function GetSqrRFactor: Double;
        //  perenosit dannye iz zadannogo spiska v spisok vybrannoy oblasti
        procedure SelectAreaActual(
            Points: TPointsSet; StartPointIndex, StopPointIndex: LongInt);
        function CreateTaskObject: TFitTask; virtual;
        //  esli intervaly ne byli zadany, to oni generiruyutsya avtomaticheski
        procedure CreateTasks;
        procedure InitTasks;

        //  ===================== vspomogatel'nye metody =======================
        procedure CreateResultedProfile;
        //  !!! ne budet pravil'no rabotat', esli oblasti perekryvayutsya !!!
        procedure CreateDeltaProfile;
        procedure CreateResultedCurvesList;
        //  tochki privyazki ne dolzhny sobirat'sya iz podzadach,
        //  tak kak pri etom budut propadat' tochki ne voschedschie
        //  v podzadachi, a eto mozhet ozadachivat' pol'zovatelya
        //procedure CreateResultedCurvePositions;
        //  probegaet spisok ekzemplyarov patterna i sozdaet
        //  spisok parametrov ekzemplyarov patterna, dopolnyaya
        //  vychislyaemymi parametrami
        procedure CreateSpecimenListAlg;
        //  vypolnyaet pereschet dlya vyvoda promezhutochnyh
        //  rezul'tatov pol'zovatelyu
        procedure GoToReadyForFit;

        //  vypolnyaet proverku vyrazheniya i zapoln. spisok parametrov
        procedure CreateParameters(ACurveExpr: string);

        function GetAllInitialized: Boolean;
        //  !!! potok ne sozdaet, prosto sinhronno vypolnyaet
        //  vyzovy metodov !!!
        procedure RecreateMainCalcThread(
            ACurrentTask: TCurrentTask; ADoneProc: TDoneProc); virtual;

    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        //  interfeysnye metody, menyayuschie sostoyanie d. soobschat' ob etom
        //  zagruzka dannyh profilya
        function SetProfilePointsSet(APointsSet: TTitlePointsSet): string;
        //  vygruzka dannyh profilya
        function GetProfilePointsSet: TPointsSet;
        //  vozvraschaet dannye vybrannoy oblasti
        function GetSelectedArea: TPointsSet;
        
        function SetBackgroundPointsSet(ABackgroundPoints: TTitlePointsSet): string;
        function GetBackgroundPoints: TPointsSet;
        
        function SetCurvePositions(ACurvePositions: TPointsSet): string;
        function GetCurvePositions: TPointsSet;

        function SetRFactorIntervals(ARFactorIntervals: TPointsSet): string;
        function GetRFactorIntervals: TPointsSet;
        
        procedure SetSpecialCurveParameters(
            ACurveExpr: string;
            CP: Curve_parameters    //  ravenstvo nil oznachaet
                                    //  pervonachal'nuyu initsializatsiyu
            );
        function GetSpecialCurveParameters: Curve_parameters;
        
        //  !!! server d. podderzhivat' primitivy dobavleniya/zameny tochki,
        //  chtoby podderzhivat' tonkie klienty, kot. ne mogut hranit' ves'
        //  nabor dannyh !!!
        //  !!! vse vyzyvayut AddPoint !!!
        procedure AddPointToData(XValue, YValue: Double);
        procedure AddPointToBackground(XValue, YValue: Double);
        procedure AddPointToRFactorIntervals(XValue, YValue: Double);
        procedure AddPointToCurvePositions(XValue, YValue: Double);
        
        //  !!! vse vyzyvayut ReplacePoint !!!
        procedure ReplacePointInData(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInBackground(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInRFactorIntervals(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
        procedure ReplacePointInCurvePositions(
            PrevXValue, PrevYValue, NewXValue, NewYValue: Double);

        //  vygruzka spiska parametrov krivyh
        function GetSpecimenList: TMSCRSpecimenList;
        //  vygruzka spiska komponentov - naborov tochek krivyh
        function GetCurvesList: TSelfCopiedCompList;
        //  eti metody proveryayut dopustimost' sostoyaniya i
        //  generiruyut isklyuchenie EUserException v sluchae
        //  nedopustimogo sostoyaniya
        function GetSpecimenCount: LongInt;
        function GetSpecimenPoints(SpecIndex: LongInt): TCurvePointsSet;
        function GetSpecimenParameterCount(SpecIndex: LongInt): LongInt;
        procedure GetSpecimenParameter(SpecIndex: LongInt; ParamIndex: LongInt;
            var Name: string; var Value: Double; var Type_: LongInt);
        procedure SetSpecimenParameter(SpecIndex: LongInt; ParamIndex: LongInt;
            Value: Double);

        function GetCalcProfilePointsSet: TPointsSet;
        function GetDeltaProfilePointsSet: TPointsSet;

        //  =============== asinhronnye (dlitel'nye) operatsii ==================
        //??? poka vypolnyaetsya sinhronno - peredelat' na asinhronnuyu obrabotku
        //  vozvraschaet soobschenie ob izmenenii sostoyaniya
        function SmoothProfile: string;
        //  vychitaet fon lineyno approksimiruya ego;
        //  esli Auto = True, to tochki fona vybrannye ranee pol'zovatelem
        //  (ili avtomaticheski) otbrasyvayutsya i opredelyayutsya zanovo, esli
        //  False, to ispol'zuyutsya imeyuschiesya tochki;
        //  metod m.b. kak interfeysnym, tak i vnutrennim
        //  ??? peredelat' tak, chtoby pri vyzove kak interf.
        //  pri AsyncOperation vydaval korrektnoe soobschenie
        procedure SubtractAllBackground(Auto: Boolean);
        //  podgonka krivyh polnost'yu vtomaticheski
        function DoAllAutomatically: string; virtual;
        //  podgonka krivyh pri zadannyh dannyh (pervonachal'naya ili povtornaya)
        //  sootvetstvuet MinimizeDifference
        function FindGausses: string; virtual;
        //  podgonka parametrov ekz. patterna bez pervonachal'noy
        //  initsializatsii intervalov primeneniya
        function FindGaussesAgain: string; virtual;
        //  ischet nabor krivyh opisyvayuschiy profil' s zadannoy tochnost'yu
        //  posledovatel'no umen'shaya kolichestvo krivyh (poluavtomaticheskaya
        //  podgonka krivyh po zadannym dannym)
        //  sootvetstvuet MinimizeNumberOfSpecimens
        function FindGaussesSequentially: string; virtual;
        //  ischet intervaly primeneniya ekzemplyarov patterna
        function FindPeakBounds: string; virtual;
        //  zapuskaet poisk tochek fona
        function FindBackPoints: string; virtual;
        //  ischet polozheniya pikov (tochek dlya raspolozheniya krivyh)
        function FindPeakPositions: string; virtual;
        function AllPointsAsPeakPositions: string; virtual;
        //  ======================= komandy upravleniya =========================
        //  asinhronnaya ostanovka dlitel'noy operatsii
        //  s vyzovom protsedury zaversheniya
        procedure StopAsyncOper; virtual; abstract;
        //  sinhronnoe preryvanie dlitel'noy operatsii
        //  bez vyzova protsedury zaversheniya
        procedure AbortAsyncOper; virtual; abstract;
        //  vozvraschaet priznak asinhr. operatsii
        function AsyncOper: Boolean;
        function GetCalcTimeStr: string;
        function GetRFactorStr: string;
        function GetAbsRFactorStr: string;
        function GetSqrRFactorStr: string;
        //  ======================= sinhronnye komandy =========================
        //  perenosit chast' dannyh iz dannyh profilya
        //  v spisok dannyh vybrannoy oblasti
        function SelectArea(StartPointIndex, StopPointIndex: LongInt): string;
        function ReturnToTotalProfile: string;
        //  opredelyaet nachal'noe i konechnoe polozhenie
        //  dlya kazhdoy krivoy v sootvetstvii so znacheniem
        //  poroga, integriruet i perenosit v spisok rezul'tatov
        procedure CreateSpecimenList;

        //  polya, ustanovka/chtenie kotoryh ne svyazany s suschestvennoy
        //  dlya aktora (imeyuschey suschestvennye pobochnye effekty) ili
        //  dlitel'noy aktivnost'yu luchshe sdelat' v vide svoystv
        
        //  maksimal'no dopustimoe znachenie R-faktora
        property MaxRFactor: Double read FMaxRFactor write SetMaxRFactor;
        //  znamenatel' koeffitsienta, vyrazhayuschego otnoshenie
        //  fona k maksimal'noy intensivnosti
        property BackFactor: Double read FBackFactor write FBackFactor;
        //  porog dlya opredeleniya granits krivoy; predpolagaetsya, chto fon otsechen;
        //  granitsy krivoy opredelyayutsya po prevysheniyu zadannogo otkloneniya ot nulya
        //  etim velichiny zhe porogom isklyuchayutsya krivye slishkom malen'koy
        property CurveThresh: Double read FCurveThresh write SetCurveThresh;
        property CurveType: TCurveType read FCurveType write SetCurveType;
        property State: TFitServerState read FState;
        property WaveLength: Double read FWaveLength write SetWaveLength;
        property SelectedAreaMode: Boolean read FSelectedAreaMode;
{$IFDEF FIT}
        //  dopuskaetsya ravenstvo nil
        property FitProxy: TFitServerProxy read FFitProxy write FFitProxy;
{$ENDIF}
    end;

const
    InadmissibleServerState: string =
        'Inadmissible state for this operation.';
    InadmissibleData: string =
        'Inadmissible data for this operation.';
    NowCalculation: string =
        //'Now calculation is performing.';
        'Now Calculation is executing.';
    RFactorStillNotCalculated: string = 'Not calculated';
    CalcAborted: string = 'Calculation aborted.';
    IsProfileWaiting: string = 'Now the program waits data.';
    //  dannaya stroka dolzhna poyavlyat'sya kogda vse neobhodimye dlya rascheta
    //  dannye byli zadany pol'zovatelem
    IsReadyForFit: string = 'Now the program is ready for fitting with selected conditions.';
    //  dannaya stroka dolzhna poyavlyat'sya kogda nekotorye dannye esche ne
    //  zadany pol'zovatelem i v sluchae zapuska podgonki budut vybrany programmoy
    IsReadyForAutoFit: string = 'Now the program is ready for fitting with automatically selected conditions.';
    BackRemoving: string = 'Now background points should be defined.';
    DataMustBeSet: string = 'Define data before.';
    BackPointsNum: string = 'The number of background points should not be less then 2.';
    RangeAlready: string = 'Range of data already selected.';
    EntireAlready: string = 'Entire dataset already selected.';
    NotAllData: string = 'Not all necessary data has been defined for the calculation.';
    //  Tekst d.b. primerno takoy: Ne vse neobhodimye dlya rascheta dannye opredeleny.
    //  Vy dolzhny zadat' samostoyatel'no, ili pozvolit' programme sgenerirovat'
    //  sleduyuschie dannye: intervaly primeneniya patternov, tochki privyazki i
    //  nachal'nye znacheniya parametrov patternov.
    StillNotDone: string = 'The calculation still not accomplished.';
    //  Raschet ne byl zapuschen
    CalcNotStarted: string = 'The calculation not started.';
    SpecimenListNotReady: string = 'Specimen list not ready.';
    SpecimenParameterListNotReady: string = 'Specimen parameter list not ready.';
    InadmissibleSpecimenIndex: string = 'Inadmissible specimen index.';
    InadmissibleParameterIndex: string = 'Inadmissible parameter index.';
    CRLF: string = #13#10;

implementation

uses Main;

{================================= TFitServer =================================}
function TFitServer.SetProfilePointsSet(APointsSet: TTitlePointsSet): string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    try
        Assert(Assigned(APointsSet));   //  kriticheskaya oshibka
        
        ExpProfile.Free; ExpProfile := APointsSet;
        if ExpProfile.PointsCount = 0 then
            raise EUserException.Create(InadmissibleData);
            
        SetState(BackNotRemoved);
        if Result = '' then Result := BackRemoving
        else Result := Result + ' ' + BackRemoving;
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

function TFitServer.SetBackgroundPointsSet(ABackgroundPoints: TTitlePointsSet): string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    try
        Assert(Assigned(ABackgroundPoints));    //  kriticheskaya oshibka
        Assert(Assigned(ExpProfile));
        
        BackgroundPoints.Free; BackgroundPoints := ABackgroundPoints;

        if ExpProfile.PointsCount > 2 then
        begin
            SetState(BackNotRemoved);
            if Result = '' then Result := BackRemoving
            else Result := Result + ' ' + BackRemoving;
        end
        else
        begin
            SetState(ProfileWaiting);
            if Result = '' then Result := IsProfileWaiting
            else Result := Result + ' ' + IsProfileWaiting;
        end;
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

function TFitServer.SetCurvePositions(ACurvePositions: TPointsSet): string;
var i: LongInt;
    Msg: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    try
        Assert(Assigned(ACurvePositions));
        Assert(Assigned(SpecimenList));
    
        CurvePositions.Clear;
        SpecimenList.Clear;

        for i := 0 to ACurvePositions.PointsCount - 1 do
            AddPoint(CurvePositions,
                ACurvePositions.PointXCoord[i],
                ACurvePositions.PointYCoord[i]
                );
        ACurvePositions.Free;
        
        if ExpProfile.PointsCount > 2 then GoToReadyForFit
        else SetState(ProfileWaiting);

        Msg := '';
        if State = ProfileWaiting then Msg := IsProfileWaiting
        else
        if State = ReadyForFit then Msg := IsReadyForFit
        else
        if State = ReadyForAutoFit then Msg := IsReadyForAutoFit;

        if Result = '' then Result := Msg
        else Result := Result + ' ' + Msg;
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

function TFitServer.SetRFactorIntervals(ARFactorIntervals: TPointsSet): string;
var i: LongInt;
    Msg: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    try
        Assert(Assigned(ARFactorIntervals));
        Assert(Assigned(SpecimenList));
        
        RFactorIntervals.Clear;
        SpecimenList.Clear;
        
        for i := 0 to ARFactorIntervals.PointsCount - 1 do
            AddPoint(RFactorIntervals,
                ARFactorIntervals.PointXCoord[i],
                ARFactorIntervals.PointYCoord[i]
                );
        ARFactorIntervals.Free;
        
        if ExpProfile.PointsCount > 2 then GoToReadyForFit
        else SetState(ProfileWaiting);
        
        Msg := '';
        if State = ProfileWaiting then Msg := IsProfileWaiting
        else
        if State = ReadyForFit then Msg := IsReadyForFit
        else
        if State = ReadyForAutoFit then Msg := IsReadyForAutoFit;

        if Result = '' then Result := Msg
        else Result := Result + ' ' + Msg;
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

destructor TFitServer.Destroy;
begin
    SetState(ProfileWaiting);
    
    BackgroundPoints.Free;
    RFactorIntervals.Free;
    CurvePositions.Free;
    ExpProfile.Free;
    Params.Free;
    inherited;
end;

constructor TFitServer.Create(AOwner: TComponent);
begin
    inherited;
    
    Params := Curve_parameters.Create(nil);

    FMaxRFactor := 0.0001;  //  0.01%
    FBackFactor := 30;
    FCurveThresh := 0;
    FCurveType := Gaussian;
    //  chtoby mozhno bylo dobavlyat' tochki tablichno bez vhoda
    //  v spets. rezhim
    ExpProfile := TTitlePointsSet.Create(nil);
    BackgroundPoints := TTitlePointsSet.Create(nil);
    RFactorIntervals := TTitlePointsSet.Create(nil);
    //  elementy v eti spiski d. dobavlyat'sya sinhronno
    CurvePositions := TTitlePointsSet.Create(nil);
    SpecimenList := TMSCRSpecimenList.Create(nil);
    SpecimenList.Lambda := WaveLength;
    CurvesList := TSelfCopiedCompList.Create(nil);

    SetState(ProfileWaiting);
end;

procedure TFitServer.SubtractAllBackground(Auto: Boolean);
var Data, Background: TPointsSet;
    i, StartIndex, EndIndex: LongInt;
    SavedI: Double;
begin
    if State = AsyncOperation then
        //  kak vnutrenniy metod v sluchae nedop. sost. vybras. iskl.
        Assert(SavedState = BackNotRemoved)
    else
        //  kak interfeysnyy vybrasyvaet spets. isklyuchenie
    begin
        //  kriticheskaya oshibka
        if State = ProfileWaiting then
            raise EUserException.Create(InadmissibleServerState + CRLF +
                DataMustBeSet);
        //  povtornoe udalenie fona zapreschat' ni k chemu
        //if (State <> BackNotRemoved) then
        //    raise EUserException.Create(InadmissibleServerState);
    end;

    Assert(Assigned(BackgroundPoints));
    (*  dlya podderzhki vyzova cherez web-interfeys - sm.nizhe
    if not Auto then
    begin
        //  kriticheskaya oshibka
        //  opyat'-taki kak interfeysnyy...
        if not BackgroundPoints.PointsCount >= 2 then
            raise EUserException.Create(InadmissibleData + CRLF +
                BackPointsNum);
    end;
    *)

    try
        if FSelectedAreaMode then Data := SelectedArea
        else Data := ExpProfile;
        Assert(Assigned(Data));
        Data.Sort;
        
        if not Auto then
        begin
            //  dlya podderzhki vyzova cherez web-interfeys
            if BackgroundPoints.PointsCount < 2 then
                Background := FindBackgroundPoints(Data)
            else Background := BackgroundPoints;
        end
        else Background := FindBackgroundPoints(Data);
        try
            //  zaschischaet resursy Background ot poteri
            Assert(Assigned(Background));
            Background.Sort;
            
            StartIndex := Data.IndexOfValueX(Background.PointXCoord[0]);
            Assert(StartIndex <> -1);

            for i := 1 to Background.PointsCount - 1 do
            begin
                EndIndex := Data.IndexOfValueX(Background.PointXCoord[i]);
                Assert(EndIndex <> -1);
                //  poskol'ku SubstractLinearly vychitaet fon dlya
                //  vseh tochek vklyuchaya granichnye, to trebuetsya
                //  sohranenie intensivnosti posledney tochki dlya
                //  togo, chtoby na sleduyuschem otrezke vychitanie
                //  bylo sdelano korrektno; pri posleduyuschem
                //  primenenii SubtractLinearly v etoy tochke
                //  nichego krome nulya poluchit'sya ne mozhet
                SavedI := Data.PointYCoord[EndIndex];
                SubtractLinearly(Data, StartIndex, EndIndex);
                StartIndex := EndIndex;
                Data.PointYCoord[EndIndex] := SavedI;
            end;
            //  otmenyaet vosstanovlenie intensivnosti
            //  dlya posledney tochki poslednego otrezka
            Data.PointYCoord[EndIndex] := 0;
        except
            if Background <> BackgroundPoints then Background.Free;
            BackgroundPoints.Clear;
            raise;
        end;
        if Background <> BackgroundPoints then Background.Free;
        //  !!! nuzhno ochischat', chtoby tochki fona ne povisali v vozduhe !!!
        BackgroundPoints.Clear;
        //  nel'zya menyat' sostoyanie vnutri dochernego potoka -
        //  eto privodit k ego unichtozheniyu
        if State <> AsyncOperation then
            SetState(ReadyForAutoFit);
    except
        //  nel'zya menyat' sostoyanie vnutri dochernego potoka -
        //  eto privodit k ego unichtozheniyu
        if State <> AsyncOperation then SetState(ProfileWaiting);
        raise;
    end;
end;

//  !!! algoritm osnovan na tom, chto fon dlya neytronogramm imeet vognutyy profil',
//  poetomu na kazhdom shage ischetsya lokal'nyy minimum v storony ot global'nogo;
//  dlya drugih tipov fona dannyy algoritm rabotat' ne budet !!!;
//  !!! dolzhna vozvraschat' korrektnyy ukazatel' ili vybrasyvat' isklyuchenie !!!
function TFitServer.FindBackgroundPoints(Data: TPointsSet): TPointsSet;
var Min, CurMin: Double;
    LeftMin, RightMin: Double;
    MinIndex: LongInt;
    LeftIndex, RightIndex: LongInt;
    i: LongInt;
    Flag: Boolean;
begin
    Assert(Assigned(Data));
    Assert(Data is TPointsSet);
    //  sozdanie spiska tochek fona
    Result := TPointsSet.Create(nil);
    try
        //  vybiraem tochku s min. int. dlya opredeleniya
        Min := Data.PointYCoord[0]; MinIndex := 0;
        for i := 1 to Data.PointsCount - 1 do
        begin
            if Data.PointYCoord[i] < Min then
            begin
                Min := Data.PointYCoord[i];
                MinIndex := i;
            end;
        end;

        LeftIndex := MinIndex; RightIndex := MinIndex;
        LeftMin := Min; RightMin := Min;

        Result.AddNewPoint(Data.PointXCoord[MinIndex], Min);

        Flag := True;
        while Flag do
        begin
            //  nahodim sleduyuschuyu po amplitude tochku
            Flag := False;
            //  ischem sleva
            CurMin := Data.PointYCoord[0]; MinIndex := 0;
            for i := 1 to LeftIndex - 1 do
            begin
                if (Data.PointYCoord[i] < CurMin) and
                   (Data.PointYCoord[i] >= LeftMin) then
                begin
                    CurMin := Data.PointYCoord[i];
                    MinIndex := i;
                end;
            end;

            if MinIndex < LeftIndex then
            begin
                LeftIndex := MinIndex;
                LeftMin := CurMin;
                Flag := True;
                Result.AddNewPoint(Data.PointXCoord[MinIndex], CurMin);
            end;

            //  ischem sprava
            if RightIndex + 1 <= Data.PointsCount - 1 then
            begin
                CurMin := Data.PointYCoord[RightIndex + 1];
                MinIndex := RightIndex + 1;
                for i := RightIndex + 2 to Data.PointsCount - 1 do
                begin
                    if (Data.PointYCoord[i] < CurMin) and
                       (Data.PointYCoord[i] >= RightMin) then
                    begin
                        CurMin := Data.PointYCoord[i];
                        MinIndex := i;
                    end;
                end;
            end;

            if MinIndex > RightIndex then
            begin
                RightIndex := MinIndex;
                RightMin := CurMin;
                Flag := True;
                Result.AddNewPoint(Data.PointXCoord[MinIndex], CurMin);
            end;
        end;
    except
        Result.Free;
        raise;
    end;
end;

function TFitServer.FindPeaksInternal: TTitlePointsSet;
var Data: TPointsSet;
    Max: Double;
    MaxX0: Double;
    MaxIndex: LongInt;
    MaxFound: Boolean;
    LeftIndex, RightIndex: LongInt;
    //LeftIndex2, RightIndex2: LongInt;
    LeftX0, RightX0, Temp: Double;
    i: LongInt;
    GlobalMax: Double;
begin
    if FSelectedAreaMode then Data := SelectedArea
    else Data := ExpProfile;
    Assert(Assigned(Data));
    Data.Sort;

    Result := TTitlePointsSet.Create(nil);
    try
        //  tsiklicheski vybiraetsya maksimal'naya tochka sredi teh,
        //  prinadlezhnost' kotoryh k pikam esche ne opredelena
        repeat
            Max := 0; MaxFound := False;
            for i := 0 to Data.PointsCount - 1 do
            begin
                if (Data.PointYCoord[i] > Max) and
                   (Result.IndexOfValueX(Data.PointXCoord[i]) = -1) then
                begin
                    Max := Data.PointYCoord[i];
                    MaxX0 := Data.PointXCoord[i];
                    MaxIndex := i;
                    MaxFound := True;
                end;
            end;
            //  predotvraschaet zatsiklivanie v sluchae, kogda vse tochki
            //  profilya vybrany (takoe mozhet byt', naprimer, pri slishkom
            //  maloy velichine nizhney granitsy poiska pikov)
            //  !!! vyhod d.b. do dobavleniya tochki !!!
            if not MaxFound then Break;
            //  pervyy naydennyy maksimum yavlyaetsya global'nym
            if Result.PointsCount = 0 then GlobalMax := Max;
            Result.AddNewPoint(MaxX0, Data.PointYCoord[MaxIndex]);
            //  opredelyaem granitsy pika dlya vychisleniya faktora rashodimosti
            Temp := Max; LeftIndex := MaxIndex; LeftX0 := MaxX0;
            //  !!! trebuetsya zaschita ot dubley inache budet sboy sortirovki !!!
            for i := MaxIndex - 1 downto 0 do
            begin
                //  !!! dlya sravneniya d. ispol'zovat'sya <,
                //  tak kak inache piki mogut smykat'sya !!!
                if (Data.PointYCoord[i] < Temp) and
                   (Result.IndexOfValueX(Data.PointXCoord[i]) = -1) then
                begin
                    Temp := Data.PointYCoord[i];
                    LeftIndex := i;
                    LeftX0 := Data.PointXCoord[i];
                    Result.AddNewPoint(LeftX0, Data.PointYCoord[LeftIndex]);
                end
                else Break;
            end;
            //  iskusstvennoe ushirenie pika vlevo
            (*
            if LeftIndex < 10 then LeftIndex2 := 0
            else LeftIndex2 := LeftIndex - 10;
            for i := LeftIndex - 1 downto LeftIndex2 do
            begin
                if (Result.IndexOfValueX(Data.PointXCoord[i]) = -1) then
                begin
                    LeftIndex := i;
                    LeftX0 := Data.PointXCoord[i];
                    Result.AddNewPoint(LeftX0, Data.PointYCoord[LeftIndex]);
                end
            end;
            *)
            Temp := Max; RightIndex := MaxIndex; RightX0 := MaxX0;
            for i := MaxIndex + 1 to Data.PointsCount - 1 do
            begin
                //  !!! dlya sravneniya d. ispol'zovat'sya <,
                //  tak kak inache piki mogut smykat'sya !!!
                if (Data.PointYCoord[i] < Temp) and
                   (Result.IndexOfValueX(Data.PointXCoord[i]) = -1) then
                begin
                    Temp := Data.PointYCoord[i];
                    RightIndex := i;
                    RightX0 := Data.PointXCoord[i];
                    Result.AddNewPoint(RightX0, Data.PointYCoord[RightIndex]);
                end
                else Break;
            end;
            //  iskusstvennoe ushirenie pika vpravo
            (*
            if RightIndex + 10 > Data.PointsCount - 1 then
                RightIndex2 := Data.PointsCount - 1
            else RightIndex2 := RightIndex + 10;
            for i := RightIndex + 1 to RightIndex2 do
            begin
                if (Result.IndexOfValueX(Data.PointXCoord[i]) = -1) then
                begin
                    RightIndex := i;
                    RightX0 := Data.PointXCoord[i];
                    Result.AddNewPoint(RightX0, Data.PointYCoord[RightIndex]);
                end
                else Break;
            end;
            *)

        //??? nuzhno otsenivat' velichinu shuma v fone i ustanavlivat' dolyu ot
        //  maksimuma kot. byla by bol'she shuma, krome togo nuzhna vozmozhnost'
        //  vvoda dannoy velichiny vruchnuyu;
        //  zdes' nuzhna ne dolya maksimuma, a nekotoroe znachenie (poskol'ku
        //  mozhet prisutstvovat' fon), kotoroe k tomu zhe d.b. razlichnym po
        //  profilyu (poprostu fon d.b. udalen!)
        until Max < GlobalMax / BackFactor;
    except
        Result.Free;
        raise;
    end;
end;

procedure TFitServer.FindPeakPositionsForAutoAlg;
begin
    CurvePositions.Free; CurvePositions := nil;
    //  vse tochki pikov vybirayutsya v kachestve tochek privyazki krivyh
    CurvePositions := FindPeaksInternal;
    SpecPosFoundForAuto := True;
end;

procedure TFitServer.FindPeakPositionsAlg;
var i: LongInt;
    Data: TPointsSet;
    PrevInt, CurInt: Double;
    PeakFound: Boolean;
    Peaks: TPointsSet;
    X: Double;
begin
    Assert(Assigned(CurvePositions));
    Peaks := FindPeaksInternal;
    //  Peaks zaschischaetsya ot utechki resursov
    try
        Assert(Assigned(Peaks));
        //  dazhe v samom uzkom pike d.b.
        //  ne men'she 3-h tochek
        Assert(Peaks.PointsCount >= 3);

        Peaks.Sort;    //  !!!

        if FSelectedAreaMode then Data := SelectedArea
        else Data := ExpProfile;
        Assert(Assigned(Data));
        Data.Sort;
        //  iz Peaks, poluchennyh posle vyzova FindPeaksInternal,
        //  isklyuchayutsya vse tochki, krome lokal'nyh maksimumov vnutri
        //  kazhdogo pika
        //  !!! tochki dobavl. k tochkam, vybrannym pol'zovatelem !!!
        PeakFound := False;
        PrevInt := Peaks.PointYCoord[0];
        for i := 1 to Peaks.PointsCount - 1 do
        begin
            CurInt := Peaks.PointYCoord[i];
            if not PeakFound then
            begin
                //  ischem peregib vniz
                if CurInt < PrevInt then
                begin
                    X := Peaks.PointXCoord[i - 1];
                    //  zaschita ot dubley
                    if CurvePositions.IndexOfValueX(X) = -1 then
                        CurvePositions.AddNewPoint(X, PrevInt);
                    PeakFound := True;
                end;
            end
            else
            begin
                //  ischem peregib vverh
                if CurInt > PrevInt then PeakFound := False;
            end;
            PrevInt := CurInt;
        end;
    except
        Peaks.Free;
        raise;
    end;
    Peaks.Free;
end;

procedure TFitServer.FindPeakPositionsDoneProcActual;
begin
    try
        //  iz AsyncOperation perehodit v prezhnee sostoyanie
        SetState(SavedState);
        FState := SavedState;   //  trebuetsya pri perehode iz AsyncOperation
        //  !!! d.b. zdes', a ne v FindPeakPositions, t.k.
        //  etot metod vyzyvaetsya iz naslednika !!!
        GoToReadyForFit;
{$IFDEF FIT}
        if (not DoneDisabled) and Assigned(FitProxy) then
            FitProxy.FindPeakPositionsDone;
{$ENDIF}
    except
        on E: Exception do WriteLog(E.Message, Fatal);
    end;
end;

procedure TFitServer.AllPointsAsPeakPositionsAlg;
var i: LongInt;
    Data: TPointsSet;
begin
    Assert(Assigned(CurvePositions));
    CurvePositions.Clear;

    if FSelectedAreaMode then Data := SelectedArea
    else Data := ExpProfile;
    Assert(Assigned(Data));
    Data.Sort;
    for i := 0 to Data.PointsCount - 1 do
    begin
        CurvePositions.AddNewPoint(Data.PointXCoord[i], Data.PointYCoord[i]);
    end;
end;

procedure TFitServer.FindPeakBoundsAlg;
var i: LongInt;
    Data: TPointsSet;
    First: Boolean;
    Peaks: TPointsSet;
    X: Double;
begin
    //  !!! spisok ne ochischaetsya, chtoby naydennye tochki dobavlyalis'
    //  k tochkam vybrannym pol'zovatelem !!!
    Assert(Assigned(RFactorIntervals));
    Peaks := FindPeaksInternal;
    try
        Assert(Assigned(Peaks));
        //  dazhe v samom uzkom pike d.b.
        //  ne men'she 3-h tochek
        //  !!! nuzhno obrabatyvat' vse sluchai !!!
        //Assert(Peaks.PointsCount >= 3);
        if Peaks.PointsCount = 0 then Exit;
        Peaks.Sort; //  !!!

        if FSelectedAreaMode then Data := SelectedArea
        else Data := ExpProfile;
        Assert(Assigned(Data));
        Data.Sort;
        //  iz Peaks, poluchennyh posle vyzova FindPeaksInternal,
        //  isklyuchayutsya vse tochki, krome tochek ogranichivayuschih pik
        First := False;
        for i := 0 to Data.PointsCount - 1 do
        begin
            if Peaks.IndexOfValueX(Data.PointXCoord[i]) <> -1 then
            begin
                //  naydena tochka pika
                if not First then
                begin
                    //  pervaya tochka pika - levaya granitsa
                    First := True;
                    //  zaschita ot dubley tochek
                    X := Data.PointXCoord[i];
                    if RFactorIntervals.IndexOfValueX(X) = -1 then
                        RFactorIntervals.AddNewPoint(X, Data.PointYCoord[i]);
                end
                //  ostal'nye tochki propuskaem...
            end
            else
            begin
                //  ne tochka pika
                if First then
                begin
                    //  predyduschaya tochka - pravaya granitsa
                    X := Data.PointXCoord[i - 1];
                    if RFactorIntervals.IndexOfValueX(X) = -1 then
                        RFactorIntervals.AddNewPoint(
                            X, Data.PointYCoord[i - 1]);
                    First := False;
                end;
            end;
        end;
        if First then
        begin
            //  perebrali vse tochki, no pravoy granitsy ne naschli -
            //  v kachestve pravoy granitsy berem poslednyuyu tochku
            X := Data.PointXCoord[i];
            //  zaschita ot dubley
            if RFactorIntervals.IndexOfValueX(X) = -1 then
                RFactorIntervals.AddNewPoint(X, Data.PointYCoord[i]);
            First := False;
        end;
    finally
        Peaks.Free;
    end;
end;

procedure TFitServer.FindPeakBoundsDoneProcActual;
begin
    try
        //  iz AsyncOperation perehodit v prezhnee sostoyanie
        SetState(SavedState);
        FState := SavedState;   //  trebuetsya pri perehode iz AsyncOperation
        //  !!! d.b. zdes', a ne v FindPeakBounds, t.k.
        //  etot metod vyzyvaetsya iz naslednika !!!
        GoToReadyForFit;
{$IFDEF FIT}
        if (not DoneDisabled) and Assigned(FitProxy) then
            FitProxy.FindPeakBoundsDone;
{$ENDIF}
    except
        on E: Exception do WriteLog(E.Message, Fatal);
    end;
end;

procedure TFitServer.FindBackPointsAlg;
var Data, Background: TPointsSet;
    i: LongInt;
begin
    Assert(Assigned(BackgroundPoints));

    if FSelectedAreaMode then Data := SelectedArea
    else Data := ExpProfile;
    Assert(Assigned(Data));
    Data.Sort;

    Background := FindBackgroundPoints(Data);
    try
        Assert(Assigned(Background));
        //  !!! spisok nuzhno ochischat', chtoby iskluchit'
        //  dublikaty tochek; bez ochistki (chtoby sohranit'
        //  vybor pol'zovatelya) nuzhno pri dobavlenii tochek
        //  proveryat' na nalichie !!!
        BackgroundPoints.Clear;
        for i := 0 to Background.PointsCount - 1 do
        begin
            BackgroundPoints.AddNewPoint(
                Background.PointXCoord[i], Background.PointYCoord[i]);
        end;
    finally
        Background.Free;
    end;
end;

function TFitServer.FindPeakPositions: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    RecreateMainCalcThread(FindPeakPositionsAlg, FindPeakPositionsDoneProcActual);
end;

function TFitServer.AllPointsAsPeakPositions: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    RecreateMainCalcThread(AllPointsAsPeakPositionsAlg, FindPeakPositionsDoneProcActual);
end;

function TFitServer.FindPeakBounds: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);
            
    StartTime := Now;
    RecreateMainCalcThread(FindPeakBoundsAlg, FindPeakBoundsDoneProcActual);
end;

function TFitServer.FindBackPoints: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    RecreateMainCalcThread(FindBackPointsAlg, FindBackPointsDoneProcActual);
end;

procedure TFitServer.FindBackPointsDoneProcActual;
begin
    try
        //  iz AsyncOperation perehodit v prezhnee sostoyanie
        SetState(SavedState);
        FState := SavedState;   //  trebuetsya pri perehode iz AsyncOperation
{$IFDEF FIT}
        if (not DoneDisabled) and Assigned(FitProxy) then
            FitProxy.FindBackPointsDone;
{$ENDIF}
    except
        on E: Exception do WriteLog(E.Message, Fatal);
    end;
end;

//  sglazhivanie bez smescheniya
procedure TFitServer.Smoothing(ANeutronPointsSet: TPointsSet);
var i: LongInt;
    //MaxBefore, MaxAfter: Double;
    SumBefore, SumAfter: Double;
    Window: array[0..1] of Double;
    Intensity: Double;

    function SumByWindow(NewValue: Double): Double;
    begin
        Result := (Window[0] + Window[1] + NewValue) / 3;
        Window[0] := Window[1];
        Window[1] := NewValue;
    end;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(ANeutronPointsSet));
    with ANeutronPointsSet do
    begin
        //  esli normirovat' na maksimum, to pri sohranenii maksimal'noy
        //  amplitudy otnositel'naya velichina bolee nizkih pikov vozrastaet;
        //  predpochtitel'nee normirovat' na summu, no pri etom maksimal'naya
        //  intensivnost' umen'shaetsya, kak i dolzhno byt' (eto ponyatnee)
        //  vychislyaetsya polnaya summa dlya normirovki
        SumBefore := 0;
        for i := 0 to PointsCount - 1 do
            SumBefore := SumBefore + PointYCoord[i];
        (*
        MaxBefore := PointYCoord[0];
        for i := 1 to PointsCount - 1 do
            if PointYCoord[i] > MaxBefore then
                MaxBefore := PointYCoord[i];
        *)
        //  bez takoy initsializatsii nachalo zavalivaetsya
        for i := 0 to 1 do Window[i] := PointYCoord[0];

        for i := 1 to PointsCount do
        begin
            if i = PointsCount then Intensity := PointYCoord[PointsCount - 1]
            else Intensity := PointYCoord[i];
            PointYCoord[i - 1] := SumByWindow(Intensity);
        end;
        (*
        //  korrektnoe opredelenie maksimuma
        MaxAfter := PointYCoord[0];
        for i := 1 to PointsCount - 1 do
            if PointYCoord[i] > MaxAfter then
                MaxAfter := PointYCoord[i];
        *)
        SumAfter := 0;
        for i := 0 to PointsCount - 1 do
            SumAfter := SumAfter + PointYCoord[i];
        //  normirovka
        for i := 0 to PointsCount - 1 do
            PointYCoord[i] := PointYCoord[i] * SumBefore / SumAfter;
                //MaxBefore / MaxAfter;
    end;
end;

function TFitServer.SmoothProfile: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    try
        Smoothing(ExpProfile);
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

function TFitServer.GetBackgroundPoints: TPointsSet;
begin
    Result := BackgroundPoints;
end;

function TFitServer.GetProfilePointsSet: TPointsSet;
begin
    Result := ExpProfile;
end;

function TFitServer.GetSelectedArea: TPointsSet;
begin
    Result := SelectedArea;
end;

function TFitServer.GetCalcProfilePointsSet: TPointsSet;
begin
    Result := CalcProfile;
end;

function TFitServer.GetDeltaProfilePointsSet: TPointsSet;
begin
    Result := DeltaProfile;
end;

function TFitServer.GetRFactorIntervals: TPointsSet;
begin
    Result := RFactorIntervals;
end;

function TFitServer.GetSpecialCurveParameters: Curve_parameters;
begin
    Result := Params;
end;

function TFitServer.GetCurvePositions: TPointsSet;
begin
    Result := CurvePositions;
end;

function TFitServer.GetCurvesList: TSelfCopiedCompList;
begin
    Result := CurvesList;
end;

function TFitServer.GetSpecimenCount: LongInt;
var SpecList: TSelfCopiedCompList;
begin
    SpecList := GetCurvesList;
    if not Assigned(SpecList) then
        raise EUserException.Create(SpecimenListNotReady);
    Result := SpecList.Count;
end;

function TFitServer.GetSpecimenPoints(SpecIndex: LongInt): TCurvePointsSet;
var Count: LongInt;
begin
    Count := GetSpecimenCount;
    if (SpecIndex < 0) or (SpecIndex >= Count) then
        raise EUserException.Create(InadmissibleSpecimenIndex);
    Result := TCurvePointsSet(GetCurvesList.Items[SpecIndex]);
end;

function TFitServer.GetSpecimenParameterCount(SpecIndex: LongInt): LongInt;
var SpecParamList: TMSCRSpecimenList;
    CP: Curve_parameters;
begin
    SpecParamList := GetSpecimenList;
    if not Assigned(SpecParamList) then
        raise EUserException.Create(SpecimenParameterListNotReady);
    if (SpecIndex < 0) or (SpecIndex >= SpecParamList.Count) then
        raise EUserException.Create(InadmissibleSpecimenIndex);
        
    CP := Curve_parameters(SpecParamList.Items[SpecIndex]);
    Result := CP.Params.Count;
end;

procedure TFitServer.GetSpecimenParameter(SpecIndex: LongInt; ParamIndex: LongInt;
    var Name: string; var Value: Double; var Type_: LongInt);
var SpecParamList: TMSCRSpecimenList;
    CP: Curve_parameters;
    P: TSpecialCurveParameter;
begin
    SpecParamList := GetSpecimenList;
    if not Assigned(SpecParamList) then
        raise EUserException.Create(SpecimenParameterListNotReady);
    if (SpecIndex < 0) or (SpecIndex >= SpecParamList.Count) then
        raise EUserException.Create(InadmissibleSpecimenIndex);
        
    CP := Curve_parameters(SpecParamList.Items[SpecIndex]);
    if (ParamIndex < 0) or (ParamIndex >= CP.Params.Count) then
        raise EUserException.Create(InadmissibleParameterIndex);

    P := TSpecialCurveParameter(CP.Params.Items[ParamIndex]);
    Name := P.Name;
    Value := P.Value;
    Type_ := LongInt(P.Type_);
end;

procedure TFitServer.SetSpecimenParameter(
    SpecIndex: LongInt; ParamIndex: LongInt; Value: Double);
var SpecParamList: TMSCRSpecimenList;
    CP: Curve_parameters;
    P: TSpecialCurveParameter;
begin
    SpecParamList := GetSpecimenList;
    if not Assigned(SpecParamList) then
        raise EUserException.Create(SpecimenParameterListNotReady);
    if (SpecIndex < 0) or (SpecIndex >= SpecParamList.Count) then
        raise EUserException.Create(InadmissibleSpecimenIndex);

    CP := Curve_parameters(SpecParamList.Items[SpecIndex]);
    if (ParamIndex < 0) or (ParamIndex >= CP.Params.Count) then
        raise EUserException.Create(InadmissibleParameterIndex);

    P := TSpecialCurveParameter(CP.Params.Items[ParamIndex]);
    P.Value := Value;
    //  ??? dlya isklucheniya izbytochnogo perescheta pri
    //  izmenenii srazu neskol'kih parametrov mozhno sdelat'
    //  v interfeyse otdel'nuyu funktsiyu perescheta; odnako
    //  eto uslozhnit interfeys i mozhet privesti k oschibkam,
    //  kogda interfeys budet ispol'zovat'sya storonnimi prilozheniyami
    GoToReadyForFit;
end;

procedure TFitServer.SubtractLinearly(Data: TPointsSet;
    StartIndex: LongInt; EndIndex: LongInt);
var i: LongInt;
    Delta: Double;
    I0: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(EndIndex > StartIndex);
    Assert(Assigned(Data));

    with Data do
    begin
        Delta := (PointYCoord[EndIndex] - PointYCoord[StartIndex]) /
                 (PointXCoord[EndIndex] - PointXCoord[StartIndex]);
        I0 := PointYCoord[StartIndex];
        for i := StartIndex to EndIndex do
        begin
            PointYCoord[i] := PointYCoord[i] - I0 -
                (PointXCoord[i] - PointXCoord[StartIndex]) * Delta;
        end;
    end;
end;
(*
procedure TFitServer.SubtractBackground;
var SA: TPointsSet;
begin
    if FSelectedAreaMode then SA := SelectedArea
    else SA := ExpProfile;
    Assert(Assigned(SA));

    SubtractLinearly(SA, 0, SA.PointsCount - 1);
end;
*)
procedure TFitServer.SelectAreaActual(
    Points: TPointsSet; StartPointIndex, StopPointIndex: LongInt);
var i: LongInt;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(Points));
    Assert(Points.PointsCount <> 0);
    Assert((StartPointIndex >= 0) and (StopPointIndex < Points.PointsCount));
    Assert(Points <> SelectedArea);
    
    SelectedArea.Free; SelectedArea := nil;
    SelectedArea := TTitlePointsSet.Create(nil);
    for i := StartPointIndex to StopPointIndex do
        SelectedArea.AddNewPoint(
            Points.PointXCoord[i], Points.PointYCoord[i]);
end;

function TFitServer.SelectArea(StartPointIndex, StopPointIndex: LongInt): string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    //if State = AsyncOperation then
    //    raise EUserException.Create(InadmissibleServerState + CRLF +
    //        NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);
    if FSelectedAreaMode then begin Result := RangeAlready; Exit; end;

    Assert(Assigned(ExpProfile));
    SelectAreaActual(ExpProfile, StartPointIndex, StopPointIndex);
    FSelectedAreaMode := True;
end;

function TFitServer.ReturnToTotalProfile: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    //if State = AsyncOperation then
    //    raise EUserException.Create(InadmissibleServerState + CRLF +
    //        NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);
    if not FSelectedAreaMode then begin Result := EntireAlready; Exit; end;

    Assert(Assigned(ExpProfile));
    FSelectedAreaMode := False;
    SelectedArea.Free; SelectedArea := nil;
end;

function TFitServer.Integrate(
    Points: TPointsSet; StartPointIndex, StopPointIndex: LongInt): Double;
var i: LongInt;
    TempDouble: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(Points));
    Assert((StartPointIndex >= 0) and (StopPointIndex < Points.PointsCount));

    TempDouble := 0;
    with Points do
        for i := StartPointIndex to StopPointIndex do
            TempDouble := TempDouble + PointYCoord[i];
    Result := TempDouble;
end;

procedure TFitServer.AddSpecimenToList(
    Points: TCurvePointsSet; StartPointIndex, StopPointIndex: LongInt
    );
var NC: Curve_parameters;
    P: TSpecialCurveParameter;
    Integral: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(Points));
    Assert(Assigned(SpecimenList));
    Integral := Integrate(Points, StartPointIndex, StopPointIndex);

    NC := Curve_parameters(Points.Params.GetCopy);
    NC.SavedInitHash := Points.InitHash;
    try
        //  dobavlyayutya vychislyaemye parametry
        P := TSpecialCurveParameter(NC.Params.Add);
        P.Name := StartPosName; P.Value := Points.PointXCoord[StartPointIndex];
        P.Type_ := Calculated;
        
        P := TSpecialCurveParameter(NC.Params.Add);
        P.Name := FinishPosName; P.Value := Points.PointXCoord[StopPointIndex];
        P.Type_ := Calculated;
        
        P := TSpecialCurveParameter(NC.Params.Add);
        P.Name := 'Integral'; P.Value := Integral;
        P.Type_ := Calculated;

        SpecimenList.Add(NC);
    except
        NC.Free;
        raise;
    end;
end;

function TFitServer.IntegrateAll(Points: TPointsSet): Double;
var i: LongInt;
    TempDouble: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(Points));

    TempDouble := 0;
    with Points do
        for i := 0 to PointsCount - 1 do
            TempDouble := TempDouble + PointYCoord[i];
    Result := TempDouble;
end;

function TFitServer.GetRFactor: Double;
var i: LongInt;
    FT: TFitTask;
begin
    Result := 0;
    Assert(Assigned(TaskList));
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        Result := Result + FT.GetCurMin;
    end;
end;

function TFitServer.GetAbsRFactor: Double;
var i: LongInt;
    FT: TFitTask;
begin
    Result := 0;
    Assert(Assigned(TaskList));
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        Result := Result + FT.GetCurAbsMin;
    end;
end;

function TFitServer.GetSqrRFactor: Double;
var i: LongInt;
    FT: TFitTask;
begin
    Result := 0;
    Assert(Assigned(TaskList));
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        Result := Result + FT.GetCurSqrMin;
    end;
end;

procedure TFitServer.DoneProc;
var i: LongInt;
    FT: TFitTask;
    AllDone: Boolean;
begin
    try
        Assert(Assigned(TaskList));

        ShowCurMin;

        AllDone := True;
        for i := 0 to TaskList.Count - 1 do
        begin
            FT := TFitTask(TaskList.Items[i]);
            if not FT.GetAllDone then
            begin
                AllDone := False;
                Break;
            end;
        end;
        if AllDone then
        begin
            //  vyzyvatsya v osnovnom potoke servera,
            //  t.e. v tom zhe potoke, chto i ServerStub,
            //  poetomu mozhno ispuskat' te zhe isklyucheniya
            CreateResultedCurvesList;
            //  tochki privyazki ne dolzhny sobirat'sya iz podzadach,
            //  tak kak pri etom budut propadat' tochki ne voschedschie
            //  v podzadachi, a eto mozhet ozadachivat' pol'zovatelya
            //CreateResultedCurvePositions;
            CreateResultedProfile;
            CreateDeltaProfile;
            CreateSpecimenListAlg;

            if SpecPosFoundForAuto then
            begin
                //  esli tochki privyazki byli naydeny avtomaticheski,
                //  to ih pokazyvat' ne nuzhno, t.k. eto vse tochki
                //  otlichnye ot fona
                CurvePositions.Clear;
                SpecPosFoundForAuto := False;
            end;

            FState := SavedState;           //  vossta. sost. predshestvovashee
                                            //  vhodu v AsyncOperation
            FitDone := True;
            //FState := ReadyForFit;
            //SetState(ReadyForFit);        //  !!! udalyaet podzadachi !!!
{$IFDEF FIT}
            if (not DoneDisabled) and Assigned(FitProxy) then FitProxy.Done;
{$ENDIF}
        end;
    except
        on E: Exception do WriteLog(E.Message, Fatal);
    end;
end;

procedure TFitServer.ShowCurMin;
begin
    if GetAllInitialized then
    begin
        CurrentMinimum := GetRFactor;
        //  vyzyvaetsya v osnovnom potoke servera,
        //  t.e. v tom zhe potoke, chto i ServerStub,
        //  poetomu mozhno ispuskat' te zhe isklyucheniya
{$IFDEF FIT}
        if Assigned(FitProxy) then
        begin
            CreateResultedCurvesList();
            FitProxy.ShowCurMin(CurrentMinimum);
        end;
{$ENDIF}
    end;
end;

function TFitServer.GetAllInitialized: Boolean;
var i: LongInt;
    FT: TFitTask;
begin
    //  !!! ne dolzhen ispuskat' isklucheniya, tak kak
    //  vyzyvaetsya iz interfeysnyh metodov !!!
    //Assert(Assigned(TaskList));
    if Assigned(TaskList) then
    begin
        Result := True;
        for i := 0 to TaskList.Count - 1 do
        begin
            FT := TFitTask(TaskList.Items[i]);
            if not FT.GetCurMinInitialized then
            begin
                Result := False;
                Break;
            end;
        end;
    end else Result := False;
end;

procedure TFitServer.FindGaussesSequentiallyAlg;
var i: LongInt;
    FT: TFitTask;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    CreateTasks;
    InitTasks;
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        FT.FindGaussesSequentially;
    end;
end;

procedure TFitServer.FindGaussesAlg;
var i: LongInt;
    FT: TFitTask;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    CreateTasks;
    InitTasks;
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        FT.FindGausses;
    end;
end;

procedure TFitServer.FindGaussesAgainAlg;
var i: LongInt;
    FT: TFitTask;
begin
    Assert(Assigned(TaskList));
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        FT.FindGaussesAgain;
    end;
end;

function TFitServer.FindGaussesSequentially: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    //if State <> ReadyForFit then
    //    raise EUserException.Create(
    //        InadmissibleServerState + CRLF + NotAllData);
    //  vmesto oshibki - sozdanie neobhodimyh dannyh
    if RFactorIntervals.PointsCount < 2 then
    begin
        RFactorIntervals.Clear;
        FindPeakBoundsAlg;
    end;
    if CurvePositions.PointsCount = 0 then FindPeakPositionsForAutoAlg;
    SetState(ReadyForFit);

    RecreateMainCalcThread(FindGaussesSequentiallyAlg, DoneProc);
end;

function TFitServer.FindGaussesAgain: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);
    if State <> ReadyForFit then
        raise EUserException.Create(
            InadmissibleServerState + CRLF + NotAllData);
            
    RecreateMainCalcThread(FindGaussesAgainAlg, DoneProc);
end;

function TFitServer.FindGausses: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    //if State <> ReadyForFit then
    //    raise EUserException.Create(
    //        InadmissibleServerState + CRLF + NotAllData);
    //  vmesto oshibki - sozdanie neobhodimyh dannyh
    if RFactorIntervals.PointsCount < 2 then
    begin
        RFactorIntervals.Clear;
        FindPeakBoundsAlg;
    end;
    if CurvePositions.PointsCount = 0 then FindPeakPositionsForAutoAlg;
    SetState(ReadyForFit);
    
    RecreateMainCalcThread(FindGaussesAlg, DoneProc);
end;

function TFitServer.GetSpecimenList: TMSCRSpecimenList;
begin
    //  vozvraschaem chto est' bez proverki
    Result := SpecimenList;
end;

procedure TFitServer.CreateResultedProfile;
var i, j: LongInt;
    FT: TFitTask;
    PS: TPointsSet;
    CPI, PI: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(TaskList));
    Assert(Assigned(ExpProfile));
    CalcProfile.Free; CalcProfile := nil;
    CalcProfile := TTitlePointsSet.Create(nil);
    //  ustanavlivaetsya trebuemoe kol-vo tochek
    for i := 0 to ExpProfile.PointsCount - 1 do
        CalcProfile.AddNewPoint(ExpProfile.PointXCoord[i], 0);

    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        PS := FT.GetCalcProfile;
        Assert(Assigned(PS));
        Assert((FT.EndIndex - FT.BegIndex + 1) = PS.PointsCount);
        Assert((FT.BegIndex >= 0) and (FT.BegIndex < CalcProfile.PointsCount));
        Assert((FT.EndIndex >= 0) and (FT.EndIndex < CalcProfile.PointsCount));
        CPI := FT.CalcProfileIntegral;
        PI := FT.ProfileIntegral;
        if CPI <> 0 then
            //  esli CPI = 0 to pribavlyat' nechego
            for j := FT.BegIndex to FT.EndIndex do
            begin
                if PI <> 0 then
                    CalcProfile.PointYCoord[j] := CalcProfile.PointYCoord[j] +
                           PS.PointYCoord[j - FT.BegIndex] * PI / CPI
                else
                    //  spetsial'nyy sluchay, kogda vse tochki profilya ravny 0
                    //  rassmatrivaetsya otdel'no
                    CalcProfile.PointYCoord[j] := CalcProfile.PointYCoord[j] +
                           PS.PointYCoord[j - FT.BegIndex];
            end;
    end;
end;
//  tochki privyazki ne dolzhny sobirat'sya iz podzadach,
//  tak kak pri etom budut propadat' tochki ne voschedschie
//  v podzadachi, a eto mozhet ozadachivat' pol'zovatelya
(*
procedure TFitServer.CreateResultedCurvePositions;
var i, j: LongInt;
    FT: TFitTask;
    PS: TPointsSet;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(TaskList));
    Assert(Assigned(CurvePositions));

    CurvePositions.Clear;

    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        PS := FT.GetCurvePositions;
        Assert(Assigned(PS));
        for j := 0 to PS.PointsCount - 1 do
            CurvePositions.AddNewPoint(PS.PointXCoord[j], PS.PointYCoord[j]);
    end;
end;
*)
procedure TFitServer.CreateDeltaProfile;
var i, j: LongInt;
    FT: TFitTask;
    PS: TPointsSet;
    CPI, PI: Double;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(TaskList));
    Assert(Assigned(ExpProfile));
    DeltaProfile.Free; DeltaProfile := nil;
    DeltaProfile := TTitlePointsSet.Create(nil);
    //  ustanavlivaetsya trebuemoe kol-vo tochek
    for i := 0 to ExpProfile.PointsCount - 1 do
        //  !!! zapolnyaetsya nulem, potomu chto tam, gde net
        //  rasschitannogo profilya ne vychislyaetsya fakt. rash.,
        //  poetomu ne imeet smysla schitat' raznost' !!!
        DeltaProfile.AddNewPoint(ExpProfile.PointXCoord[i], 0);

    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        PS := FT.GetCalcProfile;
        Assert(Assigned(PS));
        Assert((FT.EndIndex - FT.BegIndex + 1) = PS.PointsCount);
        Assert((FT.BegIndex >= 0) and (FT.BegIndex < CalcProfile.PointsCount));
        Assert((FT.EndIndex >= 0) and (FT.EndIndex < CalcProfile.PointsCount));

        CPI := FT.CalcProfileIntegral;
        PI := FT.ProfileIntegral;
        if CPI <> 0 then
        begin
            for j := FT.BegIndex to FT.EndIndex do
            begin
                DeltaProfile.PointYCoord[j] :=
                    ExpProfile.PointYCoord[j] -
                    PS.PointYCoord[j - FT.BegIndex] * PI / CPI;
            end;
        end
        else
        begin
            for j := FT.BegIndex to FT.EndIndex do
                DeltaProfile.PointYCoord[j] := ExpProfile.PointYCoord[j];
        end;
    end;
end;

procedure TFitServer.CreateResultedCurvesList;
var i, j, k: LongInt;
    FT: TFitTask;
    CL: TSelfCopiedCompList;
    CPI, PI: Double;
    Copy: TPointsSet;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(TaskList));
    CurvesList.Free; CurvesList := nil;
    CurvesList := TSelfCopiedCompList.Create(nil);
    
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        CL := FT.GetCurvesList;
        Assert(Assigned(CL));
        CPI := FT.CalcProfileIntegral;
        PI := FT.ProfileIntegral;
        for j := 0 to CL.Count - 1 do
        begin
            Copy := TPointsSet(TPointsSet(CL.Items[j]).GetCopy);
            if CPI <> 0 then
            begin
                if PI <> 0 then
                    for k := 0 to Copy.PointsCount - 1 do
                        Copy.PointYCoord[k] := Copy.PointYCoord[k] * PI / CPI
                else
                    //  spetsial'nyy sluchay, kogda PI = 0
                    //  rassmatrivaetsya otdel'no
                    for k := 0 to Copy.PointsCount - 1 do
                        Copy.PointYCoord[k] := Copy.PointYCoord[k];
            end;
            CurvesList.Add(Copy);
        end;
    end;
end;

procedure TFitServer.SetState(AState: TFitServerState);
begin
    //  pobochnym effektom yavlyaetsya initsializatsiya dannyh;
    //  prosche vsego i nadezhney dlya kazhdogo sostoyaniya provodit'
    //  initsializatsiyu sootvetstvuyuschih dannyh nezavisimo ot
    //  predyduschego sostoyaniya
    case AState of
        //  ozhidanie dannyh profilya posle zagruzki;
        //  !!! zdes' sostoyanie servera dolzhno polnost'yu
        //  privodit'sya k tomu, kotoroe bylo posle zapuska !!!
        //  !!! d.b. vozmozhnost' povtornogo vhozhdeniya v eto sostoyaniya !!!
        ProfileWaiting: begin
            Assert(Assigned(ExpProfile));
            Assert(Assigned(BackgroundPoints));
            Assert(Assigned(RFactorIntervals));
            Assert(Assigned(CurvePositions));
            Assert(Assigned(SpecimenList));
            //  chtoby mozhno bylo dobavlyat' tochki tablichno bez vhoda
            //  v spets. rezhim
            ExpProfile.Clear;
            //  !!! ne dolzhen udalyat'sya pri vhode v BackNotRemoved !!!
            BackgroundPoints.Clear;
            RFactorIntervals.Clear;
            CurvePositions.Clear;
            SpecimenList.Clear;
            CurvesList.Clear;
            
            SelectedArea.Free; SelectedArea := nil;
            CalcProfile.Free; CalcProfile := nil;
            DeltaProfile.Free; DeltaProfile := nil;
            TaskList.Free; TaskList := nil;
        end;
        //  fon esche ne otsechen (profil' i/ili SelectedArea zagruzheny)
        BackNotRemoved: begin
            CalcProfile.Free; CalcProfile := nil;
            DeltaProfile.Free; DeltaProfile := nil;
            TaskList.Free; TaskList := nil;
        end;
        //  vypolnyaetsya dlitel'naya operatsiya
        AsyncOperation: begin end;
        //  fon uzhe otsechen (gotovnost' k podgonke
        //  krivyh v avtomaticheskom rezhime)
        ReadyForAutoFit: begin
            CalcProfile.Free; CalcProfile := nil;
            DeltaProfile.Free; DeltaProfile := nil;
            TaskList.Free; TaskList := nil;
        end;
        //  gotovnost' k podgonke pri zadannyh ogranicheniyah
        ReadyForFit: begin
            CalcProfile.Free; CalcProfile := nil;
            DeltaProfile.Free; DeltaProfile := nil;
            TaskList.Free; TaskList := nil;
        end;
    end;
    if FState <> AsyncOperation then
    begin
        SavedState := FState;
        FState := AState;
    end
    else SavedState := AState;  //  dlya posleduyuschego vosstanovleniya
end;

procedure TFitServer.SetWaveLength(AWaveLength: Double);
begin
    Assert(Assigned(SpecimenList));
    FWaveLength := AWaveLength;
    SpecimenList.Lambda := WaveLength;
end;

procedure TFitServer.DoAllAutomaticallyAlg;
begin
    //  сохраняется пользовательский выбор кривой;
    //  https://action.mindjet.com/task/14588987
    //  udalyaetsya vse, chto bylo vybrano pol'zovatelem
    RFactorIntervals.Clear;
    BackgroundPoints.Clear;

    if SavedState = BackNotRemoved then
    begin
        //  pri povtornyh zapuskah fon ne udalyaetsya
        SubtractAllBackground(True);
    end;
    //??? mozhno optimizirovat' razbiv na nesk. funktsiy
    //  i vyzyvaya FindPeaksInternal tol'ko odin raz

    //  сохраняется пользовательский выбор точек расположения кривых, если задан;
    //  https://action.mindjet.com/task/14588987
    if CurvePositions.PointsCount <> 0 then
       FindPeakPositionsForAutoAlg;

    FindPeakBoundsAlg;
    FindGaussesSequentiallyAlg;
end;

function TFitServer.DoAllAutomatically: string;
begin
    Result := '';
    if State = AsyncOperation then
    begin AbortAsyncOper; Result := CalcAborted; end;

    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    StartTime := Now;
    try
        RecreateMainCalcThread(DoAllAutomaticallyAlg, DoneProc);
    except
        on E: Exception do
        begin
            SetState(ProfileWaiting);
            E.Message := E.Message + CRLF + IsProfileWaiting;
            raise;
        end;
    end;
end;

function TFitServer.CreateTaskObject: TFitTask;
begin
    Result := TFitTask.Create(nil);
end;

procedure TFitServer.CreateTasks;
var i, j: LongInt;
    TF: TFitTask;
    Data, Temp: TPointsSet;
    BegIndex, EndIndex, PosIndex: LongInt;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(RFactorIntervals));
    Assert(Assigned(CurvePositions));
    //  zadachu nuzhno vypolnyat' nastol'ko, naskol'ko vozmozhno;
    //  dlya poslednego nezakrytogo intervala podzadacha ne sozdaetsya;
    //  eto proshe, chem zhestko ogranichivat', delat' proverki i
    //  vyvodit' soobscheniya
    //Assert(RFactorIntervals.PointsCount mod 2 = 0);
    
    if FSelectedAreaMode then Data := SelectedArea
    else Data := ExpProfile;
    Assert(Assigned(Data));
    Data.Sort;
    
    RFactorIntervals.Sort;      //  !!! tochki, ogranichivayuschie intervaly m.b.
                                //  peredany izvne, poetomu sortirovka ne
                                //  pomeshaet !!!
    CurvePositions.Sort;        //  !!! to zhe samoe !!!
    
    TaskList.Free; TaskList := nil;
    TaskList := TSelfCheckedComponentList.Create(nil);

    //  sozdanie i zapolnenie podzadach
    //  odna podzadacha sozdaetsya dazhe kogda intervaly ne opredeleny;
    //  !!! odna tochka v nabore granits - interval ne opredelen !!!
    if RFactorIntervals.PointsCount < 2 then
    begin
        (*  v kachestve intervala beretsya ves' nabor dannyh -
        ne ochen' horosho, t.k. posle vyzova avtomaticheskoy
        generatsii intervalov rezul'tat ob'edinyaetsya s dannym,
        pri etom mogut voznikat' lishnie tochki
        TF := CreateTaskObject();
        try
            BegIndex := 0;
            EndIndex := Data.PointsCount - 1;
            //  delayutsya sootvet. dobavleniya v nabor granits intervala
            RFactorIntervals.AddNewPoint(
                Data.PointXCoord[BegIndex], Data.PointYCoord[BegIndex]);
            RFactorIntervals.AddNewPoint(
                Data.PointXCoord[EndIndex], Data.PointYCoord[EndIndex]);

            TF.BegIndex := BegIndex;
            TF.EndIndex := EndIndex;
            //  kopirovanie i ustanovka uchastka profilya
            Temp := TPointsSet(Data.GetCopy);
            try
                TF.SetProfilePointsSet(Temp);
            except
                Temp.Free; raise;
            end;
            //  kopirovanie i ustanovka tochek dlya raspolozheniya
            //  ekzemplyarov patterna
            Temp := TPointsSet(CurvePositions.GetCopy);
            try
                TF.SetCurvePositions(Temp);
            except
                Temp.Free; raise;
            end;
            //  ustanovka dop. parametrov
            TF.MaxRFactor := MaxRFactor;
            TF.CurveType := CurveType;
            if CurveType = Special then
                TF.SetSpecialCurve(FCurveExpr, Curve_parameters(Params.GetCopy));
            TF.ShowCurMinExternal := ShowCurMin;
            TF.DoneProcExternal := DoneProc;

            TaskList.Add(TF);
        except
            TF.Free; raise;
        end;
        *)
        //  avtomaticheskiy poisk granits intervalov
        //  avtomaticheskiy poisk meschaet udalyat' tochki,
        //  poetomu poka otklyuchen
        //RFactorIntervals.Clear;
        //FindPeakBoundsAlg;
    end;
    //else
    //begin
        j := 0;
        while j <= RFactorIntervals.PointsCount - 1 do
        begin
            //  chislo tochek mozhet byt' ne chetnym, kogda pol'zovatel' izmenyaet
            //  granitsy intervalov posle sozdaniya ekzemplyarov patterna -
            //  nuzhno korrektno obrabatyvat' takuyu situatsiyu;
            //  dlya nezakrytogo intervala podzadacha ne sozdayetsya
            if j + 1 > RFactorIntervals.PointsCount - 1 then Break;
            TF := CreateTaskObject();
            try
                BegIndex := Data.IndexOfValueX(RFactorIntervals.PointXCoord[j]);
                EndIndex := Data.IndexOfValueX(RFactorIntervals.PointXCoord[j + 1]);
                Assert(BegIndex <> -1);
                Assert(EndIndex <> -1);

                TF.BegIndex := BegIndex;
                TF.EndIndex := EndIndex;
                //  kopirovanie i ustanovka uchastka profilya
                Temp := TPointsSet.Create(nil);
                try
                    for i := BegIndex to EndIndex do
                        Temp.AddNewPoint(Data.PointXCoord[i], Data.PointYCoord[i]);
                    TF.SetProfilePointsSet(Temp);
                except
                    Temp.Free; raise;
                end;
                //  kopirovanie i ustanovka chasti tochek dlya raspolozheniya
                //  krivyh popadayuschih v zadannyy interval
                Temp := TPointsSet.Create(nil);
                try
                    for i := 0 to CurvePositions.PointsCount - 1 do
                    begin
                        PosIndex := Data.IndexOfValueX(
                            CurvePositions.PointXCoord[i]);
                        Assert(PosIndex <> -1);
                        if (PosIndex >= BegIndex) and (PosIndex <= EndIndex) then
                            Temp.AddNewPoint(
                                CurvePositions.PointXCoord[i],
                                CurvePositions.PointYCoord[i]
                                );
                    end;
                    TF.SetCurvePositions(Temp);
                except
                    Temp.Free; raise;
                end;
                //  ustanovka dop. parametrov
                TF.MaxRFactor := MaxRFactor;
                TF.CurveType := CurveType;
                if CurveType = Special then
                    TF.SetSpecialCurve(FCurveExpr, Curve_parameters(Params.GetCopy));
                TF.ShowCurMinExternal := ShowCurMin;
                TF.DoneProcExternal := DoneProc;

                TaskList.Add(TF);
            except
                TF.Free; raise;
            end;

            j := j + 2;
        end;
    //end;
end;

procedure TFitServer.InitTasks;
var i: LongInt;
    FT: TFitTask;
begin
    //  metod vnutrenniy - ne vybrasyvaet isklyucheniya nedopustimogo sostoyaniya
    Assert(Assigned(TaskList));
    for i := 0 to TaskList.Count - 1 do
    begin
        FT := TFitTask(TaskList.Items[i]);
        //  rabotaet ne optimal'no, no podhodit dlya
        //  povtornoy initsializatsii pri dobavlenii /
        //  udalenii tochek privyazki ekzemplyarov patterna
        FT.UpdateCurves(SpecimenList);
        FT.CalculateProfile;
    end;
end;

procedure TFitServer.CreateSpecimenListAlg;
var NS: TCurvePointsSet;
    StartPointIndex, StopPointIndex: LongInt;
    i, j: LongInt;
begin
    Assert(Assigned(CurvesList));
    Assert(Assigned(SpecimenList));
    SpecimenList.Clear;

    for i := 0 to CurvesList.Count - 1 do
    begin
        NS := TCurvePointsSet(CurvesList.Items[i]);
        //  opredelenie indeksov granichnyh tochek sravneniem s porogom
        StartPointIndex := -1; StopPointIndex := -1;
        for j := 0 to NS.PointsCount - 1 do
        begin
            if StartPointIndex = -1 then
            begin
                if Abs(NS.PointYCoord[j]) >= CurveThresh then
                    StartPointIndex := j;
            end
            else
            begin
                if Abs(NS.PointYCoord[j]) < CurveThresh then
                begin
                    StopPointIndex := j - 1;
                    Break;
                end;
            end;
        end;
        
        if StartPointIndex <> -1 then
        begin
            //  krivye so slishkom maloy intensivnost'yu ne vklyuchayutsya v spisok
            if StopPointIndex = -1 then StopPointIndex := NS.PointsCount - 1;
            AddSpecimenToList(NS, StartPointIndex, StopPointIndex);
        end;
    end;
end;

procedure TFitServer.CreateSpecimenList;
begin
    //  interfeysnyy metod, poetomu proveryaet sostoyanie
    if not FitDone then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            StillNotDone);
    try
        CreateSpecimenListAlg;
    except
        SetState(ProfileWaiting);
        raise;
    end;
end;

procedure TFitServer.SetMaxRFactor(AMaxRFactor: Double);
var i: LongInt;
    FT: TFitTask;
begin
    FMaxRFactor := AMaxRFactor;
    if Assigned(TaskList) then
        for i := 0 to TaskList.Count - 1 do
        begin
            FT := TFitTask(TaskList.Items[i]);
            FT.MaxRFactor := AMaxRFactor;
        end;
end;

procedure TFitServer.SetCurveThresh(ACurveThresh: Double);
begin
    FCurveThresh := ACurveThresh;
end;

procedure TFitServer.SetCurveType(ACurveType: TCurveType);
var i: LongInt;
    FT: TFitTask;
begin
    FCurveType := ACurveType;
    if Assigned(TaskList) then
        for i := 0 to TaskList.Count - 1 do
        begin
            FT := TFitTask(TaskList.Items[i]);
            FT.CurveType := ACurveType;
        end;
end;

procedure TFitServer.SetSpecialCurveParameters(
    ACurveExpr: string; CP: Curve_parameters);
var i: LongInt;
    FT: TFitTask;
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    if not Assigned(CP) then            //  pervonach. initsializatsiya
        CreateParameters(ACurveExpr)
    else
    begin
        //  zdes' eto uzhe ne yavl. dopustimoy oshibkoy pol'zovatelya -
        //  eto fatal'n. oshibka programmy
        Assert(Length(ACurveExpr) <> 0);
        Params.Free; Params := CP;
    end;
    //  esli ne proizoshlo isklyucheniya zapol. znachenie
    FCurveExpr := ACurveExpr;

    if Assigned(TaskList) then
        for i := 0 to TaskList.Count - 1 do
        begin
            FT := TFitTask(TaskList.Items[i]);
            FT.SetSpecialCurve(FCurveExpr, Curve_parameters(Params.GetCopy));
        end;
end;

function TFitServer.AsyncOper: Boolean;
begin
    if State = AsyncOperation then Result := True else Result := False;
end;

function TFitServer.GetRFactorStr: string;
var F: Double;
begin
    if GetAllInitialized then
    begin
        F := GetRFactor;
        Result := //FloatToStr(F);
                    FloatToStrF(F, ffFixed, 10, 8);
    end else Result := RFactorStillNotCalculated;
end;

function TFitServer.GetAbsRFactorStr: string;
var F: Double;
begin
    if GetAllInitialized then
    begin
        F := GetAbsRFactor;
        Result := //FloatToStr(F);
                    FloatToStrF(F, ffFixed, 10, 8);
    end else Result := RFactorStillNotCalculated;
end;

function TFitServer.GetSqrRFactorStr: string;
var F: Double;
begin
    if GetAllInitialized then
    begin
        F := GetSqrRFactor;
        Result := //FloatToStr(F);
                    FloatToStrF(F, ffFixed, 10, 8);
    end else Result := RFactorStillNotCalculated;
end;

function TFitServer.GetCalcTimeStr: string;
var Day, Hour, Min, Sec: LongInt;
    TimeStr: string;
    TotalTime: TDateTime;
begin
    //  https://www.evernote.com/shard/s132/nl/14501366/6dd2bdde-01b1-481b-adf2-665e1af55e51
    TotalTime := Now - StartTime;

    Sec := Trunc(TotalTime * 86400);
    Day := Sec div 86400;
    Sec := Sec mod 86400;
    Hour := Sec div 3600;
    Sec := Sec mod 3600;
    Min := Sec div 60;
    Sec := Sec mod 60;

    //  The date is counted since 12/30/1899.
    TimeStr := IntToStr(Day) + ' day(s) ';

    if Hour < 10 then TimeStr := TimeStr + '0';
    TimeStr := TimeStr + IntToStr(Hour) + ':';
    if Min < 10 then TimeStr := TimeStr + '0';
    TimeStr := TimeStr + IntToStr(Min) + ':';
    if Sec < 10 then TimeStr := TimeStr + '0';
    TimeStr := TimeStr + IntToStr(Sec);
    Result := TimeStr;
end;

procedure TFitServer.CreateParameters(ACurveExpr: string);
var Result: LongInt;
    ExprResult: Double;
    (* ??? peredelat' bez ispol'zovaniya
    Symbols, Saved: LPCSTR;
    *)
    P: TSpecialCurveParameter;
    Index: LongInt;
begin
(*  ???
    Assert(Assigned(Params));
    Assert(Assigned(Params.Params));
    
    if Length(ACurveExpr) = 0 then
        //  eto dopustimaya fatal'naya oshibka pol'zovatelya
        raise EUserException.Create('Inadmissible or invalid expression.');

    Result := ParseAndCalcExpression(PChar(ACurveExpr), '', @ExprResult);

    if (Result = 1)         //  razobrano polnost'yu
        or (Result = -1)    //  est' parametry (znacheniya kot. esche ne opredeleny)
        then
    begin
        //  pervonachal'noe zapolnenie parametrov
        Params.Params.Clear;
        
        Symbols := GetSymbols;
        Saved := Symbols;
        try
            Index := 0;
            while Assigned(Symbols) and (Length(Symbols) <> 0) do
            begin
                P := TSpecialCurveParameter.Create(Params.Params);
                P.Name := Symbols;
                //  raspoznaetsya imya argumenta
                if UpperCase(P.Name) = 'X' then P.Type_ := Argument
                else
                //  raspoznaetsya tipichnyy fiksirovannyy parametr polozheniya
                if UpperCase(P.Name) = 'X0' then
                    P.Type_ := InvariablePosition
                else
                    P.Type_ := Variable;
                    
                Symbols := Symbols + Length(Symbols) + 1;
                Inc(Index);
            end;
        finally
            FreeSymbols(Saved);
        end;
        if Params.Params.Count = 0 then
            //  argument-to dolzhen byt'
            raise EUserException.Create('Lack of argument.');
        if  Params.Params.Count = 1 then
            //  edinstvennyy parametr m.b. tol'ko argumentom
        begin
            P := TSpecialCurveParameter(Params.Params.Items[0]);
            P.Type_ := Argument;
        end;
    end
    else
    begin
        //  eto dopustimaya fatal'naya oshibka pol'zovatelya -
        //  sostoyanie d. sohranit'sya, pol'zovatelyu d.b.
        //  sdelano soobschenie
        raise EUserException.Create('Inadmissible or invalid expression.');
    end;
    *)
end;

// !!! povtornyy vyzov dlya dannyh koordinat udalyaet tochku iz spiska !!!
procedure TFitServer.AddPoint(
    var Points: TTitlePointsSet; XValue, YValue: Double);
var i: LongInt;
begin
    Assert(Assigned(Points));

    // ischem zadannuyu tochku v vybrannom spiske tochek
    for i := 0 to Points.PointsCount - 1 do
    begin
        if Abs(XValue - Points.PointXCoord[i]) <= TINY then
        begin
            if Abs(YValue - Points.PointYCoord[i]) <= TINY then
                Points.DeletePoint(XValue)
            //  zamena znacheniya
            else Points.PointYCoord[i] := YValue;
            Exit;
        end;
    end;
    // tochka ne naydena - dobavlyaem novuyu
    Points.AddNewPoint(XValue, YValue);
end;

procedure TFitServer.AddPointToData(XValue, YValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);

    Assert(Assigned(ExpProfile));
    AddPoint(ExpProfile, XValue, YValue);   //  dobavlyaet i udalyaet tochki
    
    if ExpProfile.PointsCount = 0 then SetState(ProfileWaiting)
    else SetState(BackNotRemoved);
end;

procedure TFitServer.AddPointToBackground(XValue, YValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(BackgroundPoints));
    AddPoint(BackgroundPoints, XValue, YValue);
end;

procedure TFitServer.GoToReadyForFit;
begin
    if State = ProfileWaiting then Exit;
    SetState(ReadyForAutoFit);      //  !!! udalyaet podzadachi !!!
    
    if  //  proverka nuzhna, t.k. imenno takomy
        //  sochetaniyu sootvetstvuet gotovnost'
        //  k podgonke s parametrami pol'zovatelya
       (RFactorIntervals.PointsCount <> 0) and
       (CurvePositions.PointsCount <> 0) then
    begin
        //  trebuetsya peresozdanie podzadach i ekzemplyarov patterna,
        //  potomu chto menyayutsya granitsy
        CreateTasks;                //  !!! sozdayutsya vremenno !!!
        InitTasks;

        CreateResultedCurvesList;
        //  tochki privyazki ne dolzhny sobirat'sya iz podzadach,
        //  tak kak pri etom budut propadat' tochki ne voschedschie
        //  v podzadachi, a eto mozhet ozadachivat' pol'zovatelya
        //CreateResultedCurvePositions;
        CreateResultedProfile;
        CreateDeltaProfile;
        CreateSpecimenListAlg;

        SetState(ReadyForFit);      //  !!! udalyaet podzadachi !!!
    end;
end;

procedure TFitServer.AddPointToRFactorIntervals(XValue, YValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(RFactorIntervals));
    AddPoint(RFactorIntervals, XValue, YValue);
    GoToReadyForFit;
end;

procedure TFitServer.AddPointToCurvePositions(XValue, YValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(CurvePositions));
    AddPoint(CurvePositions, XValue, YValue);
    //  mozhno sdelat' optimal'nee, no dlya etogo podzadachi
    //  d.b. uzhe sozdany i spisok granits intervalov d.b. nepustym
    GoToReadyForFit;
end;

procedure TFitServer.ReplacePointInData(
    PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    //  dopolnyat' dannye vsegda mozhno
    //if State = ProfileWaiting then
    //    raise EUserException.Create(InadmissibleServerState + CRLF +
    //        DataMustBeSet);

    if FSelectedAreaMode then
    begin
        Assert(Assigned(SelectedArea));
        SelectedArea.ReplacePoint(PrevXValue, PrevYValue, NewXValue, NewYValue);
    end
    else
    begin
        Assert(Assigned(ExpProfile));
        ExpProfile.ReplacePoint(PrevXValue, PrevYValue, NewXValue, NewYValue);
    end;
    //  dannye zdes' mogut byt' tol'ko dobavleny ili izmeneny,
    //  poetomu ExpProfile.PointsCount = 0 mozhno ne proveryat'
    SetState(BackNotRemoved);
end;

procedure TFitServer.ReplacePointInBackground(
    PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(BackgroundPoints));
    BackgroundPoints.ReplacePoint(PrevXValue, PrevYValue, NewXValue, NewYValue);
    //  dannye zdes' mogut byt' tol'ko dobavleny ili izmeneny,
    //  poetomu BackgroundPoints.PointsCount = 0 mozhno ne proveryat'
    SetState(BackNotRemoved);
end;

procedure TFitServer.ReplacePointInRFactorIntervals(
    PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(RFactorIntervals));
    RFactorIntervals.ReplacePoint(PrevXValue, PrevYValue, NewXValue, NewYValue);
end;

procedure TFitServer.ReplacePointInCurvePositions(
    PrevXValue, PrevYValue, NewXValue, NewYValue: Double);
begin
    if State = AsyncOperation then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            NowCalculation);
    if State = ProfileWaiting then
        raise EUserException.Create(InadmissibleServerState + CRLF +
            DataMustBeSet);

    Assert(Assigned(CurvePositions));
    CurvePositions.ReplacePoint(PrevXValue, PrevYValue, NewXValue, NewYValue);
end;

procedure TFitServer.RecreateMainCalcThread(
    ACurrentTask: TCurrentTask; ADoneProc: TDoneProc);
begin
    Assert(Assigned(ACurrentTask));
    Assert(Assigned(ADoneProc));
    ACurrentTask;
    ADoneProc;
end;

end.



