defmodule ViralSpiral.S3 do
  def bg(filename) do
    "https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/bg/#{filename}"
  end
end
