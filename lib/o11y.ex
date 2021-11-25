defmodule O11y do
  require OpenTelemetry.Span, as: Span
  require OpenTelemetry.Tracer, as: Tracer
  require OpenTelemetry.Ctx, as: Ctx

  def add_span_attributes(attrs) do
    Span.set_attributes(Tracer.current_span_ctx(), attrs)
  end

  def pipe_span_attribute(attr_value, attr_name) do
    Span.set_attribute(Tracer.current_span_ctx(), attr_name, attr_value)
    attr_value
  end

  def add_context_attributes(attrs) do
    current_context = Ctx.get_current()

    Enum.map(attrs, fn {key, value} ->
      Ctx.set_value(current_context, key, value)
    end)
  end

  def get_context do
    Ctx.get_current()
  end

  def get_span_context do
    Tracer.current_span_ctx()
  end
end
