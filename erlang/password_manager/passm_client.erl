-module(passm_client).

%% Client side: sends requests to the running daemon.
%% If daemon is not running, prompts for master password and starts it.

-export([
    get_password/2,
    list_passwords/1,
    ping/0,
    lock/0
]).

-define(SOCKET_PATH, "/tmp/passm.sock").
-define(VAULT_FILE, "vault.enc").

%% Get a password by name. VaultFile is the path to vault.enc
get_password(Name, VaultFile) ->
    ensure_daemon(VaultFile),
    case send_request({get, list_to_binary(Name)}) of
        {ok, Password} ->
            {ok, Password};
        {error, not_found} ->
            {error, not_found};
        Other ->
            Other
    end.

list_passwords(VaultFile) ->
    ensure_daemon(VaultFile),
    send_request(list).

ping() ->
    case send_request(ping) of
        pong  -> running;
        _     -> not_running
    end.

lock() ->
    case send_request(stop) of
        _ -> ok
    end.

%% ---- Internal ----

ensure_daemon(VaultFile) ->
    case is_daemon_running() of
        true  -> ok;
        false -> start_daemon(VaultFile)
    end.

is_daemon_running() ->
    case connect() of
        {ok, Socket} ->
            gen_tcp:close(Socket),
            true;
        {error, _} ->
            false
    end.

start_daemon(VaultFile) ->
    Password = prompt_password("Enter master password: "),
    case passm_vault:read_encrypted(VaultFile) of
        {ok, Salt, IV, Tag, Ciphertext} ->
            case passm_crypto:decrypt(Password, Salt, {IV, Tag, Ciphertext}) of
                {ok, Plaintext} ->
                    Vault = passm_vault:parse(Plaintext),
                    %% Start daemon in a separate OS process
                    %% (spawn_daemon forks so the CLI process can exit)
                    spawn_daemon(Vault),
                    timer:sleep(300);  %% wait for daemon socket to come up
                {error, bad_password} ->
                    io:format("Error: wrong master password~n"),
                    halt(1)
            end;
        {error, enoent} ->
            io:format("Error: vault file not found: ~s~n", [VaultFile]),
            halt(1);
        {error, bad_format} ->
            io:format("Error: vault file is corrupted~n"),
            halt(1);
        {error, Reason} ->
            io:format("Error reading vault: ~p~n", [Reason]),
            halt(1)
    end.

spawn_daemon(Vault) ->
    %% Detach a new Erlang node that runs the daemon.
    %% In a real Burrito-packaged binary you'd re-invoke self with a flag.
    %% Here we use spawn to keep it in-process for the prototype.
    %% NOTE: in production this should be a proper detached process.
    Pid = spawn(fun() ->
        {ok, _} = passm_daemon:start_link(Vault),
        receive
            shutdown -> ok
        end
    end),
    register(passm_daemon_host, Pid),
    ok.

send_request(Request) ->
    case connect() of
        {ok, Socket} ->
            Data = term_to_binary(Request),
            ok = gen_tcp:send(Socket, Data),
            case gen_tcp:recv(Socket, 0, 5000) of
                {ok, ResponseData} ->
                    gen_tcp:close(Socket),
                    binary_to_term(ResponseData, [safe]);
                {error, Reason} ->
                    gen_tcp:close(Socket),
                    {error, Reason}
            end;
        {error, _} ->
            {error, daemon_not_running}
    end.

connect() ->
    gen_tcp:connect({local, ?SOCKET_PATH}, 0, [
        binary,
        {packet, 4},
        {active, false}
    ]).

prompt_password(Prompt) ->
    %% Disable echo for password input
    io:format("~s", [Prompt]),
    %% On Linux we can use stty to disable echo
    os:cmd("stty -echo"),
    Password = case io:get_line("") of
        eof  -> <<>>;
        Line -> iolist_to_binary(string:trim(Line))
    end,
    os:cmd("stty echo"),
    io:format("~n"),
    Password.
