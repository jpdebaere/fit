{ Server application. }
program FitServer_;

{$MODE Delphi}

{$INCLUDE wst.inc}

uses
{$ifdef unix}
  cthreads,     //  for linux
{$endif}
  Interfaces,   //  LCL widgetset
  Forms,
  Variants,
  data_loader,
  math_3d,
  obj_saving_string_list,
  simple_minimizer,
  int_minimizer,
  mscr_specimen_list,
downhill_simplex_minimizer, main_calc_thread,
  fit_server_stub, fit_server_app,
  data_classes, fit_server_with_thread, fit_task,
  fit_server_multithreaded, TurboPowerIPro,
  FitGrids, fit_task_with_thread
{$ifdef windows}
  ,ta
{$else}
  ,TA_LINUX
{$endif}
  ,
{$IFDEF FPC}
  {$IFDEF UNIX}
    {$DEFINE UseCThreads}
  {$ENDIF}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
{$ENDIF}
  Sysutils, Dialogs, metadata_service_imp, server_listener, int_fit_server,
  server_binary_formatter, server_service_soap, server_service_xmlrpc,
  fit_server_binder, fit_server_imp, synapse_tcp_server, fit_server, app, fit_server_aux,
  int_fit_service, component_list, fit_server_proxy, form_main;

{$R manifest.res}

var listener : TwstListener;

{$R FitServer_.res}

begin
  Application.Title:='FitServer';
  Application.Initialize;
  //Form1.ApplicationProperties1.Title := 'fit_server';

  Server_service_RegisterBinaryFormat();
  Server_service_RegisterSoapFormat();
  Server_service_RegisterXmlRpcFormat();

  RegisterWSTMetadataServiceImplementationFactory();
  //RegisterWSTMetadataServiceImplementationFactory();
  RegisterWSTMetadataServiceImplementationFactory();

  RegisterFitServerImplementationFactory();
  Server_service_RegisterFitServerService();

  //  ispol`zuetsya ShowMessage vmesto MessageBox, poskol`ku
  //  ne zavisit ot platformy
  WriteLog('fit_server listening on TCP-port ' + InternalPort, Notification_);
    
  listener := TwstSynapseTcpListener.Create(
        InternalIP, StrToInt(InternalPort), 25000, 'Fit Service'
        );
  listener.Start();
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;  //  neobhodima dlya obrabotki soobschenii sinhronizatsii
  listener.Free;
end.
