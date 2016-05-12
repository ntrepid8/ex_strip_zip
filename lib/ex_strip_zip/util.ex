defmodule ExStripZip.Util do

  def bytes_to_mb(bytes) do
    bytes/:math.pow(2, 10)
    |> Float.round(2)
  end

  def get_disk_usage(path) do
    case System.cmd("du", ["-s", "#{path}"]) do
      {resp, 0} ->
        [bytes, _target_path] = String.split(resp, "\t", pargs: 2, trim: true)
        {:ok, String.to_integer(bytes)}
      {reason, err_code} ->
        {:error, reason, err_code}
    end
  end
  
end
