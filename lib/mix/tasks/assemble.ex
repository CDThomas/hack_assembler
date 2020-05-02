defmodule Mix.Tasks.Assemble do
  use Mix.Task

  alias HackAssembler.Parser
  alias HackAssembler.Code

  @output_extension ".hack"

  @impl Mix.Task
  def run([input_file]) do
    rootname = Path.rootname(input_file, ".asm")
    output_file = File.open!(rootname <> @output_extension, [:write])

    input_file
    |> File.stream!()
    |> Stream.each(&assemble_line(&1, output_file))
    |> Stream.run()

    File.close(output_file)
  end

  defp assemble_line(line, output_file) do
    case Parser.parse(line) do
      {:ok, instruction} when not is_nil(instruction) ->
        IO.puts(output_file, Code.to_hack(instruction))

      {:ok, nil} ->
        :noop

      {:error, _} = error ->
        Mix.shell().error(inspect(error))
    end
  end
end
