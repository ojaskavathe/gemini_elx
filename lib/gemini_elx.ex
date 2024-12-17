defmodule GeminiElx do
  use Plug.Router

  plug CORSPlug, origin: ["http://localhost:5173/"]

  plug :match
  plug :dispatch

  post "/gen_shader" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    prompt = body |> Jason.decode!() |> Map.get("prompt")

    result = """
      precision highp float;
      
      uniform vec2 u_resolution;
      uniform float u_time;
      
      // Plot a line on Y using a value between 0.0-1.0
      float plot(vec2 st) {    
          return smoothstep(0.02, 0.0, abs(st.y - st.x));
      }
      
      void main() {
        vec2 st = gl_FragCoord.xy/u_resolution;
      
          float y = st.x;
      
          vec3 color = vec3(y);
      
          // Plot a line
          float pct = plot(st);
          color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);
      
      	gl_FragColor = vec4(color,1.0);
      }
      """

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{result: result}))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
