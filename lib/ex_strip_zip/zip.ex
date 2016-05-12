defmodule ExStripZip.Zip do
  require Logger
  @exclude_list [
    "asn1",
    "crypto",
    "runtime_tools"
  ]

  def main({switches, ["zip", lib_path], errs}) do
    case {switches, ["zip", lib_path], errs} do
      {[], ["zip", lib_path], []} -> do_zip_libs(lib_path)
      _                           -> show_help()
    end
  end

  def show_help() do
    IO.puts """

    Usage: ex_strip_zip zip [PATH_TO_LIBS]
    """
  end

  def do_zip_libs(erl_lib_path) do
    Logger.debug("zipping erl_lib_path")
    erl_lib_list = File.ls!(erl_lib_path)
    {:ok, before_bytes} = get_disk_usage(erl_lib_path) 
    zip_libs(erl_lib_list, erl_lib_path)
    {:ok, after_bytes} = get_disk_usage(erl_lib_path)
    Logger.info("success")
    Logger.debug("{before, after, difference}: {#{bytes_to_mb(before_bytes)}M, #{bytes_to_mb(after_bytes)}M, #{bytes_to_mb(after_bytes-before_bytes)}M}")
  end

  def zip_libs([], _cwd), do: :ok
  def zip_libs([head|tail], cwd) do
    cond do
      File.dir?("#{cwd}/#{head}") == false ->
        Logger.debug("skipping: #{head}, not a directory")
        zip_libs(tail, cwd)
      exlude?(@exclude_list, head) == true ->
        Logger.debug("skipping: #{head}, found in exclude list")
        zip_libs(tail, cwd)
      true ->
        zip_path = "#{cwd}/#{head}.ez"
        {:ok, before_bytes} = get_disk_usage("#{cwd}/#{head}")
        {:ok, created_zip_path} = convert_to_zip_lib(zip_path, head, cwd)
        {:ok, after_bytes} = get_disk_usage(zip_path)
        verify_zip_file(zip_path)
        Logger.debug("{before, after, difference}: {#{bytes_to_mb(before_bytes)}M, #{bytes_to_mb(after_bytes)}M, #{bytes_to_mb(after_bytes-before_bytes)}M}")
        zip_libs(tail, cwd)
    end
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

  def bytes_to_mb(bytes) do
    bytes/:math.pow(2, 10)
    |> Float.round(2)
  end

  def convert_to_zip_lib(zip_path, lib_name, cwd) do
    zip_resp = :zip.create(
      String.to_char_list(zip_path),
      [String.to_char_list(lib_name)],
      [{:cwd, String.to_char_list(cwd)}])
    case zip_resp do
      {:ok, new_zip_path} ->
        File.rm_rf!("#{cwd}/#{lib_name}")
        {:ok, Kernel.to_string(new_zip_path)}
      other ->
        other
    end
  end

  def verify_zip_file(zip_path) do
    case File.exists?(zip_path) do
      false ->
        Logger.error("zip file not created: #{zip_path}")
      true ->
        Logger.debug("zip file created: #{zip_path}")
    end
  end

  def exlude?([], _lib_name), do: false
  def exlude?([head|tail], lib_name) do
    case String.contains?(lib_name, head) do
      false -> exlude?(tail, lib_name)
      true  -> true
    end
  end
  
end
