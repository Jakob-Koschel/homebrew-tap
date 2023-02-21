class CyrusSaslXoauth2 < Formula
  desc "XOAUTH2 mechanism plugin for cyrus-sasl"
  homepage "https://github.com/moriyoshi/cyrus-sasl-xoauth2"
  url "https://github.com/moriyoshi/cyrus-sasl-xoauth2/archive/refs/tags/v0.2.tar.gz"
  sha256 "a62c26566098100d30aa254e4c1aa4309876b470f139e1019bb9032b6e2ee943"
  license "MIT"

  depends_on "coreutils" => :build
  depends_on "autoconf"  => :build
  depends_on "automake"  => :build
  depends_on "libtool"   => :build
  depends_on "cyrus-sasl"
  depends_on "libtool"

  uses_from_macos "zlib"

  def install
    # force autogen.sh to look for and use our glibtoolize
    inreplace "autogen.sh", "libtoolize", "glibtoolize"

    system "./autogen.sh"
    system "./configure", *std_configure_args, "--disable-silent-rules",
      "--with-cyrus-sasl=#{Formula["cyrus-sasl"].opt_prefix}"

    inreplace "Makefile",
      "pkglibdir = ${CYRUS_SASL_PREFIX}/lib/sasl2", "pkglibdir = ${libdir}/sasl2"

    system "make",
      "INSTALL=ginstall",
      "install"
  end

  def caveats
    <<~EOS
      To use cyrus-sasl-xoauth2, you should link it into your cyrus-sasl installation.

        ln -s #{lib}/sasl2/libxoauth2.so #{Formula["cyrus-sasl"].opt_lib}/sasl2/libxoauth2.so
    EOS
  end

  test do
    system "#{lib}/sasl2/libxoauth2.0.so"
  end
end
