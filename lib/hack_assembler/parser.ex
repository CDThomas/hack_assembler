defmodule HackAssembler.Parser do
  defmodule AInstruction do
    @type t :: %__MODULE__{address: non_neg_integer()}

    @enforce_keys [:address]
    defstruct [:address]
  end

  @type error_reason :: :invalid_address
  @type parser_error :: {:error, error_reason()}

  @spec parse(line :: binary()) :: {:ok, AInstruction.t()} | parser_error()
  def parse("@" <> rest) do
    with {:ok, address} <- parse_address(rest) do
      {:ok, %AInstruction{address: address}}
    end
  end

  defp parse_address(address) do
    case Integer.parse(address) do
      {address, ""} when address >= 0 -> {:ok, address}
      _ -> {:error, :invalid_address}
    end
  end
end
