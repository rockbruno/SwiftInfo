class Swiftinfo < Formula
  desc "Extract and analyze the evolution of an iOS app's code."
  homepage "https://github.com/rockbruno/SwiftInfo"
  version "2.2.1"
  url "https://github.com/rockbruno/SwiftInfo/releases/download/#{version}/swiftinfo.zip"
  # TODO: Try something to provide a SHA automatically

  def install
    bin.install "bin/swiftinfo"
    include.install Dir["include/*"]
  end

  test do
    system "false"
  end
end