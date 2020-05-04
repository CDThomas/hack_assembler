defmodule Mix.Tasks.Assemble do
  use Mix.Task

  alias HackAssembler.Code
  alias HackAssembler.Parser
  alias HackAssembler.Parser.AInstruction
  alias HackAssembler.Parser.CInstruction
  alias HackAssembler.Parser.Label
  alias HackAssembler.SymbolTable

  @input_extension ".asm"
  @output_extension ".hack"

  @impl Mix.Task
  def run([input_file]) do
    rootname = Path.rootname(input_file, @input_extension)
    output_file = File.open!(rootname <> @output_extension, [:write])

    {symbol_table, _instruction_count} =
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
    |> Enum.reduce(symbol_table, fn instruction, symbol_table ->
      case instruction do
        {:ok, %Label{}} ->
          symbol_table

        {:ok, %AInstruction{} = instruction} ->
          {instruction, updated_symbol_table} =
            resolve_symbolic_address(instruction, symbol_table)

          IO.puts(output_file, Code.to_hack(instruction))
          updated_symbol_table

        {:ok, %CInstruction{} = instruction} ->
          IO.puts(output_file, Code.to_hack(instruction))
          symbol_table
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

  defp build_label_symbols({:ok, %Label{name: name}}, {symbol_table, instruction_count}) do
    {
      SymbolTable.put_symbol(symbol_table, name, instruction_count),
      instruction_count
    }
  end

  defp build_label_symbols({:ok, _}, {symbol_table, instruction_count}) do
    {symbol_table, instruction_count + 1}
  end

  defp resolve_symbolic_address(%AInstruction{address: address} = instruction, symbol_table)
       when is_binary(address) do
    {updated_symbol_table, value} = SymbolTable.get_symbol(symbol_table, address)
    instruction = %{instruction | address: value}

    {instruction, updated_symbol_table}
  end

  defp resolve_symbolic_address(%AInstruction{address: address} = instruction, symbol_table)
       when is_integer(address) do
    {instruction, symbol_table}
  end
end
