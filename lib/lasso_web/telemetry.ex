defmodule LassoWeb.Telemetry do
  @moduledoc """
  Metrics for the admin live dashboard
  """

  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Lasso specifics
      summary("lasso.action.stop.duration",
        tags: [:action],
        tag_values: &action_tag_value/1,
        unit: {:native, :millisecond}
      ),
      counter("lasso.action.stop.duration", tags: [:action], tag_values: &action_tag_value/1),
      counter("lasso.request.stop.duration", tags: [:method], tag_values: &request_method_value/1),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    []
  end

  defp action_tag_value(metadata) do
    Map.take(metadata, [:action])
  end

  defp request_method_value(metadata) do
    Map.take(metadata.request, [:method])
  end
end
