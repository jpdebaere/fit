unit configurable_user_points_set;

{$mode delphi}

interface

uses
  Classes, SysUtils, configurable_points_set;

type
  { Special implementation used by TUserPointsSet. }
  TConfigurableUserPointsSet = class(TConfigurablePointsSet)
  public
      { Returns true if curve type has parameters which should be configured
        by user, otherwise returns false. }
      class function HasConfigurableParameters: Boolean; override;
{$IF NOT DEFINED(SERVER) AND NOT DEFINED(CLIENT_PROXY)}
      { Displays dialog for set up user configurable parameters. Returns true
        if dialog was confirmed and false if it was cancelled. }
      class function ShowConfigurationDialog: Boolean; override;
{$ENDIF}
      { Returns true if user configurable parameters have default values,
        otherwise returns false. }
      class function HasDefaults: Boolean; override;
      { Sets up default values for user configurable parameters. }
      class procedure SetDefaults; override;
  end;

implementation

uses
{$IF NOT DEFINED(SERVER) AND NOT DEFINED(CLIENT_PROXY)}
{$IFNDEF FPC OR IFDEF WINDOWS}
    user_points_set_prop_dialog, expression_parser_adapter, curve_type_storage_adapter,
    curve_type_parameters_factory, create_user_points_set_dlg_adapter, app_settings,
{$ENDIF}
{$ENDIF}
    Controls, app, Dialogs;

class function TConfigurableUserPointsSet.HasConfigurableParameters: Boolean;
begin
    Result := True;
end;

{$IF NOT DEFINED(SERVER) AND NOT DEFINED(CLIENT_PROXY)}
class function TConfigurableUserPointsSet.ShowConfigurationDialog: Boolean;
{$IFNDEF FPC OR IFDEF WINDOWS}
var ct: Curve_type;
    ep: TExpressionParserAdapter;
    da: TCreateUserPointsSetDlgAdapter;
    cf: TCurveTypeParametersFactory;
    ca: TCurveTypeStorageAdapter;

label dlg1, dlg2;
{$ENDIF}
begin
{$IFNDEF FPC OR IFDEF WINDOWS}
    ep := TExpressionParserAdapter.Create;
    da := TCreateUserPointsSetDlgAdapter.Create;
    cf := TCurveTypeParametersFactory.Create;
    ca := TCurveTypeStorageAdapter.Create;

dlg1:
    Result := False;
    ct := nil;
    case da.ShowModal of
        mrOk:
            begin
                ct := cf.CreateUserCurveType(da.GetName, da.GetExpression,
                    ep.ParseExpression(ct.Expression));

                ca.AddCurveType(ct);
                goto dlg2;
            end;
        else Exit;
    end;

dlg2:
    UserPointsSetPropDlg.ct := ct;
    case UserPointsSetPropDlg.ShowModal of
        mrOk:
            begin
                //  Rewrites selected settings.
                ca.UpdateCurveType(ct);
            end;

        mrRetry:
            begin
                //  Deletes curve on retry.
                ca.DeleteCurveType(ct);
                goto dlg1;
            end;
    else Exit;
    end;
{$ENDIF}
end;
{$ENDIF}

class function TConfigurableUserPointsSet.HasDefaults: Boolean;
begin
    Result := False;
end;

class procedure TConfigurableUserPointsSet.SetDefaults;
begin
    //  Do nothing.
end;

end.

