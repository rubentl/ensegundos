-module(ensegundos).

%%%================================================================
%%% Establece la diferencia entre dos time.
%%% ej. "01:56:30" "02:10:40"
%%% Devuelve la diferencia en Segundos
%%%================================================================

%% API exports
-export([main/1]).

-type mis_horas() :: [{atom(), non_neg_integer()}].

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.
%%====================================================================
%% API functions
%%====================================================================


%% Recibimos los time en la línea de comandos
%% y le pasamos los filtros para asegurarnos que
%% tienen el formato correcto.
-spec main([string()]) -> none().
main([D1]) ->
  main(filtro(D1), D1);
main([D1,D2]) ->
  main(filtro(D1), filtro(D2), D1, D2);
main(_) ->
  usage().

%% Si sólo hay un time y pasa el filtro devolvemos su valor 
%% en segundos
-spec main(boolean(), string()) -> none().
main(true, Date) ->
  Segundos = en_segundos(Date),
  io:format(<<"~p -> ~w segundos~n">>,[Date,Segundos]);
main(false, _) ->
  usage().

%% Si los dos parámetros pasan el filtro los procesamos
-spec main(atom(), atom(), string(), string()) -> none().
main(true, true, Data1, Data2) ->
  Segund1 = en_segundos(Data1),
  Segund2 = en_segundos(Data2),
  Result  = comparacion(Segund1, Segund2),
  io:format(<<"~p y ~p -> la diferencia es ~w segundos~n">>,
              [Data1,Data2,Result]);
main(_, false, _, _) -> usage();
main(false, _, _, _) -> usage().

%%====================================================================
%% Internal functions
%%====================================================================

%% Algo fue mal y damos ayuda
-spec usage() -> none().
usage() ->
  io:format(<<"¡Error!, baby.~n">>),
  io:format(<<"Necesito uno o dos tiempos.~nhh:mm:ss hh:mm:ss~n">>).

%% Compara las fechas en segundos y devuelve la diferencia
-spec comparacion(integer(), integer()) -> integer().
comparacion(Date1, Date2) when Date1  >  Date2   -> Date1 - Date2;
comparacion(Date1, Date2) when Date1  <  Date2   -> Date2 - Date1;
comparacion(Date1, Date2) when Date1 =:= Date2   -> 0.

%% Convierte en integer el formato "00:00:00"
-spec en_numero(string()) -> mis_horas().
en_numero(String) ->
  Result  = [string:to_integer(X) || X <- string:tokens(String, ":")],
  Numeros = [Y || {Y, _} <- Result],
  lists:zip([horas,minutos,segundos],Numeros).

%% Devuelve el parámetro "00:00:00" en segundos
-spec en_segundos(string()) -> integer().
en_segundos(String) ->
  Dict     = en_numero(String),
  Horas    = proplists:get_value(horas,Dict),
  Minutos  = proplists:get_value(minutos,Dict),
  Segundos = proplists:get_value(segundos,Dict),
  horas_en_segundos(Horas) + minutos_en_segundos(Minutos) + Segundos.

%% Devuelve las horas en segundos
-spec horas_en_segundos(integer()) -> integer().
horas_en_segundos(Horas) ->
  minutos_en_segundos(Horas*60).

%% Devuelve los minutos en segundos
-spec minutos_en_segundos(integer()) -> integer().
minutos_en_segundos(Minutos) ->
  Minutos*60.

%% ¿Está el argumento en forma "00:00:00"? 
-spec filtro(string() | tuple() | atom()) -> boolean().
filtro(String) when is_list(String) ->
  filtro(re:run(String,<<"^\\d+:\\d+:\\d+$">>));
filtro({match, _}) -> true;
filtro(nomatch)    -> false.

%%============================================================
%% Tests
%% ===========================================================

-ifdef(TEST).

main_test() ->
  ?assertCmdOutput("\"01:03:50\" y \"01:04:50\" -> la diferencia es 60 segundos\n","ensegundos 01:03:50 01:04:50"),
  ?assertCmdOutput("\"01:45:30\" -> 6330 segundos\n","ensegundos 01:45:30").

filtro_test() ->
  ?assertNot(filtro("hola")),
  ?assertNot(filtro("1")),
  ?assertNot(filtro("01:45")),
  ?assert(filtro("01:34:10")).

horas_en_segundos_test() ->
  ?assertEqual(horas_en_segundos(1),3600),
  ?assertEqual(horas_en_segundos(7),25200).

minutos_en_segundos_test() ->
  ?assertEqual(minutos_en_segundos(1),60),
  ?assertEqual(minutos_en_segundos(7),420).

en_numero_test() ->
  ?assertEqual([{horas,1},{minutos,34},{segundos,10}],en_numero("01:34:10")).

en_segundos_test() ->
  ?assertEqual(6330,en_segundos("1:45:30")).

-endif.
