defmodule HackAssembler.SymbolTable do
  @type t :: %__MODULE__{symbols: map()}

  @enforce_keys [:symbols]
  defstruct [:symbols]

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

  @spec new :: t()
  def new do
    %__MODULE__{symbols: @predefined_symbols}
  end

  @spec put(symbol_table :: t(), symbol :: binary(), value :: non_neg_integer) :: t()
  def put(%__MODULE__{symbols: symbols} = symbol_table, symbol, value) do
    %{symbol_table | symbols: Map.put(symbols, symbol, value)}
  end
end
