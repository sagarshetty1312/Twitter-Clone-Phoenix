defmodule ChatWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat

  socket "/socket", ChatWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :chat,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_chat_key",
    signing_salt: "rIqiDxPj"

  plug ChatWeb.Router

  def init(_key,config) do
    :ets.new(:tweetsMade, [:set,:named_table,:public])
    :ets.new(:followers,[:set,:named_table,:public])
    :ets.new(:following,[:set,:named_table,:public])
    :ets.new(:allUsers,[:set,:named_table,:public])
    :ets.new(:mentionsHashtags, [:set, :public, :named_table])
    :ets.new(:userTable,[:set,:public,:named_table])
    :ets.new(:userSockets,[:set,:public,:named_table])
    :ets.new(:myHome,[:set,:public,:named_table])
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || 4000
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
