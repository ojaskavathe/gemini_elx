defmodule GeminiElx do
  use Plug.Router

  plug CORSPlug, origin: ["https://assignment.ojaskavathe.com"]

  plug :match
  plug :dispatch

  post "/gen_shader" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    prompt = body |> Jason.decode!() |> Map.get("prompt")

    result = send_to_gemini(prompt)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{result: result}))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp send_to_gemini(prompt) do
    Finch.start_link(name: MyFinch)

    url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=#{System.get_env("GEMINI_API_KEY")}"

    headers = [{"Content-Type", "application/json"}]

    full_prompt = """
      Forget everything from the previous prompts and follow:
      Generate WebGL fragment shader code based on the following input: 

      The shader must:
      1. Start with the following lines:
      #version 300 es
      precision highp float;

      uniform vec2 u_resolution;
      uniform float u_time;

      out vec4 fragColor;

      2. Implement the visual effect described in the input prompt:
      - The fragment shader is rendering to a quad.
      - If the effect involves 3D objects, make sure projection and depth testing are handled properly.

      3. Use GLSL ES 3.0:
      - Do NOT use multidimensional arrays.
      - Do not use gl_FragColor or any other variables not supported by GLSL ES 3.0.

      Rules:
      - The output must ONLY contain valid GLSL code for the fragment shader.
      - Do NOT include any extra messages, comments, or explanations.
      - Do NOT use multidimensional arrays.

      Here’s the input for this request:
      #{prompt}
      """

    body =
      Jason.encode!(%{
        "contents" => [
          %{
            "parts" => [
              %{"text" => full_prompt}
            ]
          }
        ]
      })

    case Finch.build(:post, url, headers, body) |> Finch.request(MyFinch) do
      {:ok, %Finch.Response{status: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"candidates" => candidates}} ->
            candidates
            |> Enum.map(fn %{"content" => %{"parts" => parts}} ->
              Enum.map(parts, & &1["text"])
            end)
            |> List.flatten()

          {:error, _} -> "Error decoding JSON response"
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        "Error: Received HTTP status #{status} with response: #{body}"

      {:error, reason} ->
        "Error: #{inspect(reason)}"
    end
  end
end
