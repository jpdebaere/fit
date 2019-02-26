{
This software is distributed under GPL
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the warranty of FITNESS FOR A PARTICULAR PURPOSE.

@abstract(Contains definition of TInputBackFactorDlg.)

@author(Dmitry Morozov dvmorozov@hotmail.com, 
LinkedIn https://ru.linkedin.com/pub/dmitry-morozov/59/90a/794, 
Facebook https://www.facebook.com/profile.php?id=100004082021870)
}
unit Unit5;

{$MODE Delphi}

interface

uses LCLIntf, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, LResources;

type
  TInputBackFactorDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    ValueEdit: TEdit;
    Label1: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
  private

  public
    Value: Double;
  end;

var
  InputBackFactorDlg: TInputBackFactorDlg;

implementation

uses Unit4;

procedure TInputBackFactorDlg.FormCloseQuery(Sender: TObject;
    var CanClose: Boolean
    );
const Msg: string = 'Improper factor input. Factor should be more than 1.';
begin
    CanClose := True;
    //  posle uspeshnogo zakrytiya okna d. b.
    //  garantirovano, chto znachenie korrektno
    if ModalResult = mrOk then
    begin
        try
            Value := StringToValue(ValueEdit.Text);
            if Value <= 1 then raise Exception.Create(' ');
        except
{$ifdef windows}
            ShowBalloon(ValueEdit.Handle, WideString(Msg),
                ''          //vmesto Error - tak luchshe smotritsya
                );
{$else}
            MessageDlg(Msg, mtError, [mbOk], 0);
{$endif}
            ActiveControl := ValueEdit;
            CanClose := False;
        end;
    end;{if ModalResult = mrOk then...}
end;

procedure TInputBackFactorDlg.FormActivate(Sender: TObject);
begin
    ValueEdit.Text := FloatToStr(Value);
    ActiveControl := ValueEdit;
end;

initialization
    {$i Unit5.lrs}
end.

