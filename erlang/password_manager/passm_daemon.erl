-module(passm_daemon).
-behaviour(gen_server).

%% The daemon holds the decrypted vault in memory and serves queries
%% over a Unix domain socket at ?SOCKET_PATH.
%% It auto-exits after ?IDLE_TIMEOUT ms of inactivity.

-export([start_link/1, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-define(SOCKET_PATH, "/tmp/passm.sock").
-define(IDLE_TIMEOUT, 900000).  %% 15 minutes in ms
-define(CLIP_CLEAR_TIMEOUT, 30000).  %% 30 seconds

-record(state, {
    vault      :: map(),
    listener   :: port() | undefined,
    idle_timer :: reference() | undefined
}).

start_link(Vault) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Vault], []).

stop() ->
    gen_server:cast(?MODULE, stop).

init([Vault]) ->
    %% Remove stale socket file if it exists
    file:delete(?SOCKET_PATH),
    %% Start listening on Unix socket
    {ok, Listener} = gen_tcp:listen(0, [
        binary,
        {packet, 4},
        {active, false},
        {reuseaddr, true},
        {ifaddr, {local, ?SOCKET_PATH}}
    ]),
    %% Accept connections in a separate process
    self() ! accept,
    Timer = reset_idle_timer(undefined),
    {ok, #state{vault = Vault, listener = Listener, idle_timer = Timer}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info(accept, #state{listener = Listener} = State) ->
    %% Spawn acceptor — this blocks until a client connects
    spawn_link(fun() -> accept_loop(Listener) end),
    {noreply, State};

handle_info({client_request, From, Request}, State) ->
    NewTimer = reset_idle_timer(State#state.idle_timer),
    Response = handle_request(Request, State#state.vault),
    From ! {response, Response},
    {noreply, State#state{idle_timer = NewTimer}};

handle_info(idle_timeout, State) ->
    io:format("passm daemon: idle timeout, shutting down~n"),
    {stop, normal, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{listener = Listener}) ->
    catch gen_tcp:close(Listener),
    file:delete(?SOCKET_PATH),
    ok.

%% ---- Request handling ----

handle_request({get, Name}, Vault) ->
    case passm_vault:lookup(Name, Vault) of
        {ok, Password}    -> {ok, Password};
        {error, not_found} -> {error, not_found}
    end;

handle_request(list, Vault) ->
    Names = maps:keys(Vault),
    {ok, Names};

handle_request(ping, _Vault) ->
    pong;

handle_request(_, _) ->
    {error, unknown_command}.

%% ---- Accept loop (runs in its own process) ----

accept_loop(Listener) ->
    case gen_tcp:accept(Listener) of
        {ok, Socket} ->
            spawn(fun() -> handle_client(Socket) end),
            accept_loop(Listener);
        {error, closed} ->
            ok;
        {error, Reason} ->
            io:format("passm daemon: accept error: ~p~n", [Reason]),
            ok
    end.

handle_client(Socket) ->
    case gen_tcp:recv(Socket, 0, 5000) of
        {ok, Data} ->
            Request = binary_to_term(Data, [safe]),
            passm_daemon ! {client_request, self(), Request},
            receive
                {response, Response} ->
                    Encoded = term_to_binary(Response),
                    gen_tcp:send(Socket, Encoded)
            after 5000 ->
                gen_tcp:send(Socket, term_to_binary({error, timeout}))
            end;
        {error, _} ->
            ok
    end,
    gen_tcp:close(Socket).

%% ---- Helpers ----

reset_idle_timer(OldTimer) ->
    catch erlang:cancel_timer(OldTimer),
    erlang:send_after(?IDLE_TIMEOUT, self(), idle_timeout).

socket_path() -> ?SOCKET_PATH.
