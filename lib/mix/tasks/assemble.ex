defmodule Mix.Tasks.Assemble do
  use Mix.Task

  alias HackAssembler.Code
  alias HackAssembler.Parser
  alias HackAssembler.Parser.AInstruction
  alias HackAssembler.Parser.CInstruction
  alias HackAssembler.Parser.Label
  alias HackAssembler.SymbolTable

  @output_extension ".hack"

  @impl Mix.Task
  def run([input_file]) do
    rootname = Path.rootname(input_file, ".asm")
    output_file = File.open!(rootname <> @output_extension, [:write])

    {symbol_table, _} =
      input_file
      |> File.stream!()
      |> Stream.map(&Parser.parse/1)
      |> Stream.each(&raise_on_error!/1)
      |> Stream.filter(&not_empty?/1)
      |> Enum.reduce({SymbolTable.new(), 0}, &build_label_symbols/2)

    input_file
    |> File.stream!()
    |> Stream.map(&Parser.parse/1)
    |> Stream.each(&raise_on_error!/1)
    |> Stream.filter(&not_empty?/1)
    |> Enum.reduce({symbol_table, 0}, fn instruction, {symbol_table, count} ->
      case instruction do
        {:ok, %Label{}} ->
          {symbol_table, count}

        {:ok, %AInstruction{} = instruction} ->
          {symbol_table, instruction} = resolve_symbolic_address(instruction, symbol_table)
          IO.puts(output_file, Code.to_hack(instruction))
          {symbol_table, count + 1}

        {:ok, %CInstruction{} = instruction} ->
          IO.puts(output_file, Code.to_hack(instruction))
          {symbol_table, count + 1}
      end
    end)

    File.close(output_file)
  end

  defp raise_on_error!({:error, _} = error) do
    Mix.raise(inspect(error))
  end

  defp raise_on_error!({:ok, _} = instruction) do
    instruction
  end

  defp not_empty?({:ok, instruction}) do
    not is_nil(instruction)
  end

  defp build_label_symbols({:ok, %Label{name: name}}, {symbol_table, count}) do
    {SymbolTable.put_symbol(symbol_table, name, count), count}
  end

  defp build_label_symbols({:ok, _}, {symbol_table, count}) do
    {symbol_table, count + 1}
  end

  defp resolve_symbolic_address(%AInstruction{address: address} = instruction, symbol_table)
       when is_binary(address) do
    {symbol_table, value} = SymbolTable.get_symbol(symbol_table, address)
    instruction = %{instruction | address: value}

    {symbol_table, instruction}
  end

  defp resolve_symbolic_address(%AInstruction{address: address} = instruction, symbol_table)
       when is_integer(address) do
    {symbol_table, instruction}
  end
end
