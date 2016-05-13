defmodule ExStripZip.Zip do
  require Logger
  alias ExStripZip.Util
  @exclude_list [
    "asn1-",
    "crypto-",
    "runtime_tools-"
  ]

  def main({switches, argv, errs}) do
    case {switches, argv, errs} do
      {[], ["zip", lib_path], []} -> run_zip_libs(lib_path)
      _                           -> show_help()
    end
  end

  def show_help() do
    IO.puts """

    Usage: ex_strip_zip zip [PATH_TO_RELEASE]
    """
  end

  def run_zip_libs(erl_release_path) do
    Logger.debug("zipping erl_release_path")
    {:ok, erl_lib_path} = lookup_lib_folder(erl_release_path)
    erl_lib_list = File.ls!(erl_lib_path)
    {:ok, before_bytes} = Util.get_disk_usage(erl_lib_path)
    zip_libs(erl_lib_list, erl_lib_path)
    {:ok, after_bytes} = Util.get_disk_usage(erl_lib_path)
    Logger.info("success")
    Logger.debug("{before, after, difference}: {#{Util.bytes_to_mb(before_bytes)}M, #{Util.bytes_to_mb(after_bytes)}M, #{Util.bytes_to_mb(after_bytes-before_bytes)}M}")
  end

  def lookup_lib_folder(erl_release_path) do
    expected_lib_path = "#{erl_release_path}/lib"
    case File.dir?(expected_lib_path) do
      true  -> {:ok, expected_lib_path}
      false -> {:error, "not a directory: #{expected_lib_path}"}
    end
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
        {:ok, before_bytes} = Util.get_disk_usage("#{cwd}/#{head}")
        {:ok, created_zip_path} = convert_to_zip_lib(zip_path, head, cwd)
        {:ok, after_bytes} = Util.get_disk_usage(zip_path)
        verify_zip_file(zip_path)
        Logger.debug("{before, after, difference}: {#{Util.bytes_to_mb(before_bytes)}M, #{Util.bytes_to_mb(after_bytes)}M, #{Util.bytes_to_mb(after_bytes-before_bytes)}M}")
        zip_libs(tail, cwd)
    end
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
    case String.starts_with?(lib_name, head) do
      false -> exlude?(tail, lib_name)
      true  -> true
    end
  end
  
end
