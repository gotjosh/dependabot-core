defmodule MixfileParser do
  def parse(dir) do
    Path.join(dir, "mix.exs")
    |> File.read!()
    |> Code.string_to_quoted!
    |> extract_module
    |> extract_calls
    |> extract_deps
  end

  defp extract_module({:defmodule, _, content}), do: content

  defp extract_calls([_|[[do: {:__block__, _, calls}]|_]]), do: calls

  defp extract_deps({:defp, _, [{:deps, _, _}, [do: dependencies]]}, _) do
    Enum.map(dependencies, &extract_dep/1)
  end
  defp extract_deps(_, tail), do: extract_deps(tail)
  defp extract_deps([head|tail]), do: extract_deps(head, tail)

  defp extract_dep({name, version}) do
    {name, %{version: version}}
  end
  defp extract_dep({_, _, [name, version, opts]}) do
    {name, %{version: version, only: opts[:only]}}
  end
end

defmodule LockfileParser do
  def parse(dir) do
    Path.join(dir, "mix.lock")
    |> File.read!()
    |> Code.string_to_quoted!
    |> extract_deps
  end

  defp extract_deps({_, _, deps}) do
    Enum.map(deps, &extract_dep/1)
  end

  defp extract_dep({_dep, {_, _, [source, name, version, _, _build, _, _]}}) do
    {name, %{
      source: source,
      version: version
    }}
  end
end

input = IO.read(:stdio, :all)
%{"function" => function, "args" => [dir]} = Poison.decode!(input)

case function do
  "parse" ->
    mix_dependencies = MixfileParser.parse(dir)
    lock_dependencies = LockfileParser.parse(dir)

    dependencies =
      Enum.map(mix_dependencies, fn {name, _} ->
        {_, %{version: version}} = Enum.find(lock_dependencies, fn {dep, _} -> dep == name end)
        %{"name" => name, "version" => version}
      end)

    Poison.encode!(%{"result" => dependencies})
    |> IO.puts
end
