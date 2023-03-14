class LtexLs < Formula
  desc "LSP for LanguageTool with support for Latex, Markdown and Others"
  homepage "https://valentjn.github.io/ltex/"
  url "https://github.com/valentjn/ltex-ls/archive/refs/tags/nightly.tar.gz"
  sha256 "5b7ecc9996087af631ec080dc959348e6f04708619dc489c56dda1b18ef7da36"
  license "MPL-2.0"
  version "16.0.0-alpha.1.develop"
  head "https://github.com/valentjn/ltex-ls.git", branch: "develop"

  depends_on "maven" => :build
  depends_on "python@3.11" => :build
  depends_on "openjdk"

  def install
    inreplace "pom.xml", "python", "python3"

    ENV.prepend_path "PATH", Formula["python@3.11"].opt_libexec/"bin"
    ENV["JAVA_HOME"] = Formula["openjdk"].opt_prefix
    ENV["TMPDIR"] = buildpath

    system "python3.11", "-u", "tools/createCompletionLists.py"

    system "mvn", "-B", "-e", "-DskipTests", "package"

    mkdir "build" do
      system "tar", "xzf", "../target/ltex-ls-#{version}.tar.gz", "-C", "."

      # remove Windows files
      rm Dir["ltex-ls-#{version}/bin/*.bat"]
      bin.install Dir["ltex-ls-#{version}/bin/*"]
      libexec.install Dir["ltex-ls-#{version}/*"]
    end

    bin.env_script_all_files libexec/"bin", Language::Java.overridable_java_home_env
  end

  test do
    (testpath/"test").write <<~EOS
      She say wrong.
    EOS

    (testpath/"expected").write <<~EOS
      #{testpath}/test:1:5: info: The pronoun 'She' is usually used with a third-person or a past tense verb. [HE_VERB_AGR]
      She say wrong.
          Use 'says'
          Use 'said'
    EOS

    got = shell_output("#{bin}/ltex-cli '#{testpath}/test'", 3)
    assert_equal (testpath/"expected").read, got
  end
end
