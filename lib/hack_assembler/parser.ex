defmodule HackAssembler.Parser do
  defmodule AInstruction do
    @type t :: %__MODULE__{address: non_neg_integer()}

    @enforce_keys [:address]
    defstruct [:address]
  end

  @type result :: AInstruction.t() | nil
  @type error_reason :: :invalid_address
  @type parser_error :: {:error, error_reason()}

  @spec parse(line :: binary()) :: {:ok, result()} | parser_error()
  def parse(line) do
    line
    |> String.trim()
    |> do_parse()
  end

  defp do_parse("") do
    {:ok, nil}
  end

  defp do_parse("@" <> rest) do
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
