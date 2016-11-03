defmodule ExStripZip.Strip do
  require Logger
  alias ExStripZip.Util
  @exclude_list []

  def main({switches, argv, errs}) do
    case {switches, argv, errs} do
      {[], ["strip", lib_path], []} -> run_strip_libs(lib_path)
      _                             -> show_help()
    end
  end

  def show_help() do
    IO.puts """

    Usage: ex_strip_zip strip [PATH_TO_RELEASE]
    """
  end

  def run_strip_libs(erl_release_path) do
    Logger.debug("stripping #{inspect erl_release_path}")
    erl_lib_list = File.ls!(erl_release_path)
    {:ok, before_bytes} = Util.get_disk_usage(erl_release_path)
    {:ok, modules} = strip_release(erl_release_path)
    :ok = remove_extras(erl_release_path)
    {:ok, after_bytes} = Util.get_disk_usage(erl_release_path)
    Logger.info("success")
    Logger.debug("{before, after, difference}: {#{Util.bytes_to_mb(before_bytes)}M, #{Util.bytes_to_mb(after_bytes)}M, #{Util.bytes_to_mb(after_bytes-before_bytes)}M}")
  end

  def strip_release(erl_release_path) do
    convert_to_strip_release(erl_release_path)
  end

  def strip_libs([], _cwd), do: :ok
  def strip_libs([head|tail], cwd) do
    cond do
      File.dir?("#{cwd}/#{head}") == false ->
        Logger.debug("skipping: #{head}, not a directory")
        strip_libs(tail, cwd)
      exlude?(@exclude_list, head) == true ->
        Logger.debug("skipping: #{head}, found in exclude list")
        strip_libs(tail, cwd)
      true ->
        strip_path = "#{cwd}/#{head}"
        {:ok, before_bytes} = Util.get_disk_usage("#{cwd}/#{head}")
        {:ok, created_strip_path} = convert_to_strip_lib(strip_path, head, cwd)
        {:ok, after_bytes} = Util.get_disk_usage(strip_path)
        Logger.debug("{before, after, difference}: {#{Util.bytes_to_mb(before_bytes)}M, #{Util.bytes_to_mb(after_bytes)}M, #{Util.bytes_to_mb(after_bytes-before_bytes)}M}")
        strip_libs(tail, cwd)
    end
  end

  def convert_to_strip_lib(strip_path, lib_name, cwd) do
    case :beam_lib.strip(String.to_char_list(strip_path)) do
      {:ok, modules} ->
        Logger.debug("stripped_modules: #{inspect modules}")
        {:ok, modules}
      {:error, error_lib, reason} ->
        {:error, "#{inspect error_lib}: #{inspect reason}"}
    end
  end

  def convert_to_strip_release(erl_release_path) do
    :beam_lib.strip_release(String.to_char_list(erl_release_path))
  end

  def exlude?([], _lib_name), do: false
  def exlude?([head|tail], lib_name) do
    case String.contains?(lib_name, head) do
      false -> exlude?(tail, lib_name)
      true  -> true
    end
  end

  def remove_extras(erl_release_path) do
    {:ok, libraries} = File.ls("#{erl_release_path}/lib/")
    remove_extras_helper(libraries, "#{erl_release_path}/lib", "examples")
    remove_extras_helper(libraries, "#{erl_release_path}/lib", "src")
    remove_extras_helper(libraries, "#{erl_release_path}/lib", "c_src")
    :ok
  end

  def remove_extras_helper([], _, _), do: :ok
  def remove_extras_helper([head|tail], base_path, extra_target) do
    target_path = "#{base_path}/#{head}/#{extra_target}"
    if File.exists?(target_path) do
      {:ok, removed_paths} = File.rm_rf(target_path)
      Logger.debug("removed_paths: #{inspect removed_paths}")
    end
    remove_extras_helper(tail, base_path, extra_target)
  end
  
end
