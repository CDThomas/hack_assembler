defmodule HackAssembler.SymbolTable do
  @moduledoc """
  A data structure for keeping track of symbols used in a Hack assembly program.

  Symbols include predefined symbols (e.g. `R0`), labels (e.g. `(LOOP)`), and variables (e.g. `@i`).

  Symbols are stored in a `Map` in under the `symbols` property. `next_address` is used internally to keep track of the next available address to use for variables.
  """

  @type t :: %__MODULE__{symbols: map(), next_address: non_neg_integer()}

  @enforce_keys [:symbols, :next_address]
  defstruct [:symbols, :next_address]

  @predefined_symbols %{
    "R0" => 0,
    "R1" => 1,
    "R2" => 2,
    "R3" => 3,
    "R4" => 4,
    "R5" => 5,
    "R6" => 6,
    "R7" => 7,
    "R8" => 8,
    "R9" => 9,
    "R10" => 10,
    "R11" => 11,
    "R12" => 12,
    "R13" => 13,
    "R14" => 14,
    "R15" => 15,
    "SCREEN" => 16_384,
    "KBD" => 24_576,
    "SP" => 0,
    "LCL" => 1,
    "ARG" => 2,
    "THIS" => 3,
    "THAT" => 4
  }

  @doc "Returns a new symbol table containing the predefined symbols."
  @spec new :: t()
  def new do
    %__MODULE__{symbols: @predefined_symbols, next_address: 16}
  end

  @doc """
  Puts `symbol` in the given `symbol_table` with the value `value`.

  Returns the updated symbol table.

  This is used for adding labels to the symbol table.
  """
  @spec put_symbol(symbol_table :: t(), symbol :: binary(), value :: non_neg_integer) :: t()
  def put_symbol(%__MODULE__{symbols: symbols} = symbol_table, symbol, value) do
    %{symbol_table | symbols: Map.put(symbols, symbol, value)}
  end

  @doc """
  Gets `symbol` from the given `symbol_table`. If the symbol is new, the symbol will be added to the symbol table with the next available address (starting at RAM[16]).

  Returns a tuple containing the symbol table and the address of the symbol.

  This is used for getting and adding variables.
  """
  @spec get_symbol(symbol_table :: t(), symbol :: binary) ::
          {symbol_table :: t(), value :: non_neg_integer()}
  def get_symbol(%__MODULE__{symbols: symbols, next_address: next_address} = symbol_table, symbol) do
    if Map.has_key?(symbols, symbol) do
      {symbol_table, symbols[symbol]}
    else
      updated_symbol_table =
        symbol_table
        |> put_symbol(symbol, next_address)
        |> Map.put(:next_address, next_address + 1)

      {updated_symbol_table, next_address}
    end
  end
end
