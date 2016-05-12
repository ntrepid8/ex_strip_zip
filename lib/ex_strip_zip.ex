defmodule ExStripZip do
  require Logger

  def main(args) do
    case OptionParser.parse(args) do
      {switches, ["zip"|tail], errs} ->
        ExStripZip.Zip.main({switches, ["zip"|tail], errs})
      {switches, ["strip"|tail], errs} ->
        ExStripZip.Strip.main({switches, ["strip"|tail], errs})
      other ->
        show_help()
    end
  end

  def show_help() do
    IO.puts """

    Usage: ex_strip_zip [zip|strip] [PATH_TO_RELEASE]

    Note: when running both strip and zip functions, always run strip first.
    """
  end
end
