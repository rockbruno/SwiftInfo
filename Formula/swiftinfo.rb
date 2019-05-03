class Swiftinfo < Formula
  desc "📊 Extract and analyze the evolution of an iOS app's code."
  homepage "https://github.com/rockbruno/SwiftInfo"
  url "https://github.com/rockbruno/SwiftInfo.git", :tag => "2.2.0", :revision => "4dc083130a0b519307436c7083e3d417d1aea870"
  head "https://github.com/rockbruno/SwiftInfo.git"

  depends_on :xcode => ["10.2", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end
end
