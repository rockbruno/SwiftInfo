class Swiftinfo < Formula
  desc "📊 Extract and analyze the evolution of an iOS app's code."
  homepage "https://github.com/rockbruno/SwiftInfo"
  version "2.3.11"
  url "https://github.com/rockbruno/SwiftInfo/releases/download/#{version}/swiftinfo.zip"
  # TODO: Try something to provide a SHA automatically

  depends_on :xcode => ["11.4", :build]

  def install
    bin.install Dir["bin/*"]
    include.install Dir["include/*"]
  end

  test do
    system bin/"swiftinfo", "-version"
  end
end
