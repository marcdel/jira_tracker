defmodule O11y do
  require OpenTelemetry.Span, as: Span
  require OpenTelemetry.Tracer, as: Tracer

  def span_attributes(attrs) do
    Span.set_attributes(Tracer.current_span_ctx(), attrs)
  end
end
