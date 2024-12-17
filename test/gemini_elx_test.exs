defmodule GeminiElxTest do
  use ExUnit.Case
  doctest GeminiElx

  use Plug.Test

  alias GeminiElx

  @opts GeminiElx.init([])

  test "POST /gen_shader responds with valid content" do
    payload = %{prompt: "a circle"}
    body = Jason.encode!(payload)

    conn =
      conn(:post, "/gen_shader", body)
      |> put_req_header("content-type", "application/json")
      |> GeminiElx.call(@opts)

    assert conn.status == 200

    response = Jason.decode!(conn.resp_body)

    assert "result" in Map.keys(response)
  end

end
