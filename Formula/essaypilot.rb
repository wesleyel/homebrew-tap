# Written by GoReleaser from wesleyel/EssayPilot on each release; see docs/release-automation.md.
class Essaypilot < Formula
  desc "Workbench for grading and annotating essays with your own AI agent over MCP"
  homepage "https://github.com/wesleyel/EssayPilot"
  url "https://github.com/wesleyel/EssayPilot/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "663df77229b3fe3600447a095ba43ae06ee6bbcea4912e24eabea44d6c7011fc"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/essaypilot"
  end

  post_install_steps do
    mkdir_p "essaypilot", base: :var
  end

  service do
    run [opt_bin/"essaypilot", "-mcp", "-db", var/"essaypilot/essaypilot.db"]
    keep_alive true
    log_path var/"log/essaypilot.log"
    error_log_path var/"log/essaypilot.log"
  end

  def caveats
    <<~EOS
      Start it in the background (data in #{var}/essaypilot):

        brew services start essaypilot

      Then open http://127.0.0.1:8790 and connect your agent, for example:

        claude mcp add --transport http essaypilot http://127.0.0.1:8790/mcp
    EOS
  end

  test do
    port = free_port
    pid = spawn bin/"essaypilot", "-mcp", "-addr", "127.0.0.1:#{port}", "-db", testpath/"test.db"
    begin
      sleep 2
      assert_match "part-a", shell_output("curl -fsS http://127.0.0.1:#{port}/api/meta")
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
