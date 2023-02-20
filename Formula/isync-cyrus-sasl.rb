class IsyncCyrusSasl < Formula
  desc "Synchronize a maildir with an IMAP server"
  homepage "https://isync.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/isync/isync/1.4.4/isync-1.4.4.tar.gz"
  sha256 "7c3273894f22e98330a330051e9d942fd9ffbc02b91952c2f1896a5c37e700ff"
  license "GPL-2.0-or-later"
  revision 1

  head do
    url "https://git.code.sf.net/p/isync/isync.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "berkeley-db@5"
  depends_on "openssl@1.1"
  depends_on "cyrus-sasl"

  uses_from_macos "zlib"

  def install
    system "./autogen.sh" if build.head?
    # mbsync throws: 'SASL(-1): generic failure: Unable to find a callback: 18948' on xaouth2
    # solution found: https://github.com/moriyoshi/cyrus-sasl-xoauth2/issues/9
    system "./configure", *std_configure_args, "--disable-silent-rules",
      "--with-sasl=#{Formula["cyrus-sasl"]}", "--with-ssl=#{Formula["openssl@1.1"]}"
    system "make", "install"
  end

  service do
    run [opt_bin/"mbsync", "-a"]
    run_type :interval
    interval 300
    keep_alive false
    environment_variables PATH: std_service_path_env
    log_path "/dev/null"
    error_log_path "/dev/null"
  end

  test do
    system bin/"mbsync-get-cert", "duckduckgo.com:443"
  end
end
