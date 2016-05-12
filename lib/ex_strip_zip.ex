defmodule ExStripZip do
  require Logger

  def main(args) do
    Logger.info("Hello, World!")
    case OptionParser.parse(args) do
      {switches, ["zip", lib_path], errs} ->
        Logger.debug("running: zip")
        ExStripZip.Zip.main({switches, ["zip", lib_path], errs})
      other ->
        Logger.debug("no match: #{inspect other}")
        show_help()
    end
  end

  def show_help() do
    IO.puts """

    Usage: ex_strip_zip [zip|strip] [PATH_TO_LIBS]
    """
  end
end
