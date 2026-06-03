class Brandywine < Formula
  desc "Wine wrapper for running Windows apps on macOS"
  homepage "https://github.com/sasobhabha/Brandywine"
  url "https://github.com/sasobhabha/Brandywine/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "<insert-sha256-of-tarball>"
  license "MIT"

  depends_on "wine"
  depends_on "crossover" => :optional

  def install
    bin.install "brandywine"
  end

  test do
    system "#{bin}/brandywine", "--version"
  end
end
