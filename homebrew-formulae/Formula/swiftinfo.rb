class Swiftinfo < Formula
  desc "Extract and analyze the evolution of an iOS app's code."
  homepage "https://github.com/rockbruno/SwiftInfo"
  url "https://github.com/rockbruno/SwiftInfo.git", :revision => "4dc083130a0b519307436c7083e3d417d1aea870"
  version "2.2.0"

  def install
    bin.install "swiftinfo"
    include.install Dir["*"]
  end

  test do
    system "false"
  end
end
