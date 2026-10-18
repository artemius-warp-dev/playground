-module(passm_clipboard).

-export([copy/1, copy/2]).

-define(DEFAULT_CLEAR_AFTER_MS, 30000).

%% Copy password to clipboard, clear after default timeout
copy(Password) ->
    copy(Password, ?DEFAULT_CLEAR_AFTER_MS).

%% Copy password to clipboard, clear after TimeoutMs milliseconds
copy(Password, TimeoutMs) ->
    case detect_clipboard_tool() of
        {ok, Tool} ->
            do_copy(Tool, Password),
            io:format("Password copied to clipboard. Will clear in ~w seconds.~n",
                      [TimeoutMs div 1000]),
            spawn(fun() ->
                timer:sleep(TimeoutMs),
                do_copy(Tool, <<>>),
                io:format("Clipboard cleared.~n")
            end),
            ok;
        {error, no_tool} ->
            %% Fallback: print to stdout
            io:format("No clipboard tool found. Password: ~s~n", [Password]),
            {error, no_clipboard_tool}
    end.

%% ---- Internal ----

detect_clipboard_tool() ->
    %% Detect Wayland vs X11 and available tools
    IsWayland = os:getenv("WAYLAND_DISPLAY") =/= false,
    Tools = case IsWayland of
        true  -> ["wl-copy", "xclip", "xsel"];
        false -> ["xclip", "xsel", "wl-copy"]
    end,
    find_tool(Tools).

find_tool([]) ->
    {error, no_tool};
find_tool([Tool | Rest]) ->
    case os:find_executable(Tool) of
        false -> find_tool(Rest);
        Path  -> {ok, {Tool, Path}}
    end.

do_copy({Tool, Path}, Text) ->
    Port = open_port({spawn_executable, Path}, [
        {args, tool_args(Tool, Text)},
        {env, []},
        binary,
        exit_status,
        use_stdio,
        stderr_to_stdout
    ]),
    %% Send text to stdin of the clipboard tool
    case Text of
        <<>> -> ok;
        _    -> port_command(Port, Text)
    end,
    port_close(Port),
    ok.

tool_args("xclip", <<>>) -> ["-selection", "clipboard", "-in", "/dev/null"];
tool_args("xclip", _)    -> ["-selection", "clipboard"];
tool_args("xsel", <<>>)  -> ["--clipboard", "--clear"];
tool_args("xsel", _)     -> ["--clipboard", "--input"];
tool_args("wl-copy", <<>>) -> ["--clear"];
tool_args("wl-copy", _)    -> [];
tool_args(_, _)            -> [].
