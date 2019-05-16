defmodule Lasso.Request do
  defstruct headers: [],
            method: "",
            body: "",
            query_params: %{},
            request_path: "",
            timestamp: DateTime.utc_now(),
            ip: ""
end
