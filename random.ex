defmodule Random do
  @moduledoc """
  Documentation for Project1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project1.hello
      :world

  """
  def base62(num_bytes \\ 16) do
    random_bytes(num_bytes)
    |> Base.encode64(padding: false)
    |> String.replace(~r/[+\/]/, random_char())
  end
  
  @base62_alphabet 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  
  defp random_char do
    [Enum.random(@base62_alphabet)] |> to_string
  end

  def generateInput() do
    IO.puts "gererating random inputs inside random"
    "kanikagupta"<>base62()
  end

  def calculateHash(input) do
    :crypto.hash(:sha256, input) |> Base.encode16
  end

  defp random_bytes(num) do
    :crypto.strong_rand_bytes(num)
  end
  
  def check_leading_zeros(input, tzero,lzero) do
    linput=String.slice(input,0..lzero-1)
    if tzero==linput do
      true
    else
      false 
    end
  end

  
  
end
