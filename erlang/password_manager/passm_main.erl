-module(passm_main).

%% Main entry point for the passm password manager.
%% This module is called by Burrito (or escript) on startup.
%%
%% Usage:
%%   passm seal [file]        Encrypt vault.txt → vault.enc, securely wipe vault.txt
%%   passm unseal [file]      Decrypt vault.enc → vault.txt
%%   passm get <name>         Copy password to clipboard (starts daemon if needed)
%%   passm list               List all password names
%%   passm lock               Shutdown the running daemon
%%   passm help               Show this help

-export([main/1]).

-define(VAULT_ENC, "vault.enc").
-define(VAULT_TXT, "vault.txt").

main(Args) ->
    %% Ensure crypto application is started
    application:ensure_all_started(crypto),
    run(Args).

run(["seal"]) ->
    run(["seal", ?VAULT_TXT]);
run(["seal", TxtFile]) ->
    EncFile = ?VAULT_ENC,
    case file:read_file(TxtFile) of
        {error, enoent} ->
            die("File not found: ~s~n", [TxtFile]);
        {ok, Plaintext} ->
            Password = prompt_password_twice(),
            {Salt, IV, Tag, Ciphertext} = passm_crypto:encrypt(Password, Plaintext),
            case passm_vault:write_encrypted(EncFile, Salt, IV, {Tag, Ciphertext}) of
                ok ->
                    passm_crypto:secure_wipe(TxtFile),
                    io:format("Vault sealed: ~s~n", [EncFile]),
                    io:format("Plaintext file securely wiped: ~s~n", [TxtFile]);
                {error, Reason} ->
                    die("Failed to write ~s: ~p~n", [EncFile, Reason])
            end
    end;

run(["unseal"]) ->
    run(["unseal", ?VAULT_ENC]);
run(["unseal", EncFile]) ->
    TxtFile = ?VAULT_TXT,
    case filelib:is_file(TxtFile) of
        true ->
            die("~s already exists. Move or delete it first.~n", [TxtFile]);
        false ->
            ok
    end,
    Password = prompt_password("Enter master password: "),
    case passm_vault:read_encrypted(EncFile) of
        {ok, Salt, IV, Tag, Ciphertext} ->
            case passm_crypto:decrypt(Password, Salt, {IV, Tag, Ciphertext}) of
                {ok, Plaintext} ->
                    file:write_file(TxtFile, Plaintext),
                    io:format("Vault unsealed: ~s~n", [TxtFile]),
                    io:format("Edit it, then run: passm seal~n");
                {error, bad_password} ->
                    die("Wrong master password.~n", [])
            end;
        {error, enoent} ->
            die("Vault file not found: ~s~n", [EncFile]);
        {error, bad_format} ->
            die("Vault file is corrupted.~n", []);
        {error, Reason} ->
            die("Error: ~p~n", [Reason])
    end;

run(["get", Name]) ->
    case passm_client:get_password(Name, ?VAULT_ENC) of
        {ok, Password} ->
            passm_clipboard:copy(Password);
        {error, not_found} ->
            die("No entry found for: ~s~n", [Name])
    end;

run(["list"]) ->
    case passm_client:list_passwords(?VAULT_ENC) of
        {ok, Names} ->
            io:format("Stored passwords:~n"),
            lists:foreach(fun(N) ->
                io:format("  ~s~n", [N])
            end, lists:sort(Names));
        {error, Reason} ->
            die("Error: ~p~n", [Reason])
    end;

run(["lock"]) ->
    passm_client:lock(),
    io:format("Daemon stopped.~n");

run(["help"]) ->
    print_help();

run(["--help"]) ->
    print_help();

run([]) ->
    print_help();

run(Unknown) ->
    io:format("Unknown command: ~p~n~n", [Unknown]),
    print_help(),
    halt(1).

%% ---- Helpers ----

print_help() ->
    io:format(
        "passm - a minimal password manager~n~n"
        "Usage:~n"
        "  passm seal [file]      Encrypt vault.txt → vault.enc, wipe plaintext~n"
        "  passm unseal [file]    Decrypt vault.enc → vault.txt for editing~n"
        "  passm get <name>       Copy password to clipboard~n"
        "  passm list             List all stored password names~n"
        "  passm lock             Shutdown the background daemon~n"
        "  passm help             Show this help~n"
        "~n"
        "Vault format (vault.txt):~n"
        "  github: mypassword~n"
        "  work_email: another_password~n"
        "  ssh_server: yet_another~n"
    ).

prompt_password(Prompt) ->
    io:format("~s", [Prompt]),
    os:cmd("stty -echo"),
    Password = case io:get_line("") of
        eof  -> <<>>;
        Line -> iolist_to_binary(string:trim(Line))
    end,
    os:cmd("stty echo"),
    io:format("~n"),
    Password.

prompt_password_twice() ->
    P1 = prompt_password("Enter master password: "),
    P2 = prompt_password("Confirm master password: "),
    case P1 =:= P2 of
        true  -> P1;
        false ->
            io:format("Passwords do not match. Try again.~n"),
            prompt_password_twice()
    end.

die(Fmt, Args) ->
    io:format("Error: " ++ Fmt, Args),
    halt(1).
